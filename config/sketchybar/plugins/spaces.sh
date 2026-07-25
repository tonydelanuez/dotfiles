#!/bin/sh

# Build a compact app-icon label for every Mission Control space.
# Uses a compiled CoreGraphics helper instead of yabai.

HELPER="$HOME/.config/sketchybar/helpers/query_spaces"
[ -x "$HELPER" ] || exit 0

DATA="$("$HELPER" 2>/dev/null)" || exit 0

source "$HOME/.config/sketchybar/helpers/icon_map.sh"

# Collect every active space index so we know which static items to hide.
ACTIVE_SPACES=""

printf '%s' "$DATA" | jq -c '.spaces[]' | while IFS= read -r space_json; do
  sid="$(printf '%s' "$space_json" | jq -r '.index')"
  focused="$(printf '%s' "$space_json" | jq -r '.focused')"

  # Collect up to 3 app icons.
  tmp="$TMPDIR/sketchybar_spaces_${sid}_$$"
  : > "$tmp"

  printf '%s' "$space_json" | jq -r '.apps[:3][]' 2>/dev/null | while IFS= read -r app; do
    [ -n "$app" ] || continue
    case "$app" in
      Asana) icon_result=":check_box:" ;;
      *) __icon_map "$app" ;;
    esac
    [ "$icon_result" = ":default:" ] && icon_result=":widget:"
    printf '%s ' "$icon_result" >> "$tmp"
  done

  icons="$(cat "$tmp" 2>/dev/null)"
  rm -f "$tmp"

  sketchybar --set "space.$sid" label="$icons" label.drawing=on

  if [ "$focused" = "true" ]; then
    sketchybar --set "space.$sid" icon.highlight=on label.highlight=on
  else
    sketchybar --set "space.$sid" icon.highlight=off label.highlight=off
  fi

  # app_icon items are no longer populated individually; hide them all.
  for slot in 1 2 3; do
    sketchybar --set "app_icon.$sid.$slot" drawing=off
  done

  sketchybar --set "space.$sid" drawing=on
  sketchybar --set "desktop.$sid" drawing=on
  sketchybar --set "desktop_spacer.$sid" drawing=on

  # Track active space indices
  echo "$sid" >> "$TMPDIR/sketchybar_active_spaces_$$"
done

# Hide static space items (1-10) that don't correspond to an actual space.
ACTIVE_FILE="$TMPDIR/sketchybar_active_spaces_$$"
for sid in $(seq 1 10); do
  if [ -f "$ACTIVE_FILE" ] && grep -qx "$sid" "$ACTIVE_FILE" 2>/dev/null; then
    continue
  fi
  sketchybar --set "space.$sid" drawing=off
  sketchybar --set "desktop.$sid" drawing=off
  sketchybar --set "desktop_spacer.$sid" drawing=off
  sketchybar --set "app_icon.$sid.1" drawing=off
  sketchybar --set "app_icon.$sid.2" drawing=off
  sketchybar --set "app_icon.$sid.3" drawing=off
done

rm -f "$ACTIVE_FILE"
