#!/bin/sh

# Build a compact context label for every Mission Control space.

SPACES="$(yabai -m query --spaces 2>/dev/null)" || exit 0
WINDOWS="$(yabai -m query --windows 2>/dev/null)" || exit 0
SPACE_COUNT="$(printf '%s' "$SPACES" | jq 'length')"
source "$HOME/.config/sketchybar/helpers/icon_map.sh"

for sid in $(printf '%s' "$SPACES" | jq -r '.[].index'); do
  display_id="$(printf '%s' "$SPACES" | jq -r --argjson sid "$sid" '.[] | select(.index == $sid) | .display')"
  apps="$(printf '%s' "$WINDOWS" | jq -r --argjson sid "$sid" '[.[] | select(.space == $sid) | .app] | unique | .[]')"
  icons=""
  slot=1
  while IFS= read -r app
  do
    [ -n "$app" ] || continue
    case "$app" in
      Asana) icon_result=":check_box:" ;;
      *) __icon_map "$app" ;;
    esac
    [ "$icon_result" = ":default:" ] && icon_result=":widget:"
    icons="$icons$icon_result "
    slot=$((slot + 1))
    [ "$slot" -le 3 ] || break
  done <<EOF
$apps
EOF

  sketchybar --set "space.$sid" label="$icons" label.drawing=on

  focused="$(printf '%s' "$SPACES" | jq -r --argjson sid "$sid" '.[] | select(.index == $sid) | .["has-focus"]')"
  if [ "$focused" = "true" ]; then
    sketchybar --set "space.$sid" icon.highlight=on label.highlight=on
  else
    sketchybar --set "space.$sid" icon.highlight=off label.highlight=off
  fi

  while [ "$slot" -le 3 ]
  do
    sketchybar --set "app_icon.$sid.$slot" drawing=off
    slot=$((slot + 1))
  done

  sketchybar --set "space.$sid" drawing=on
  sketchybar --set "desktop.$sid" drawing=on
  sketchybar --set "desktop_spacer.$sid" display="$display_id" drawing=on
done

# Hide unused slots from the static maximum in sketchybarrc.
for sid in $(seq 1 10); do
  if [ "$sid" -gt "$SPACE_COUNT" ]; then
    sketchybar --set "space.$sid" drawing=off
    sketchybar --set "desktop.$sid" drawing=off
    sketchybar --set "desktop_spacer.$sid" drawing=off
    sketchybar --set "app_icon.$sid.1" drawing=off
    sketchybar --set "app_icon.$sid.2" drawing=off
    sketchybar --set "app_icon.$sid.3" drawing=off
  fi
done
