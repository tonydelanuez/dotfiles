#!/bin/sh

# Mirror Discord Canary's macOS Dock badge. This uses Accessibility metadata
# only; it never reads Discord's local storage or authentication state.
BADGE="$(osascript 2>/dev/null <<'APPLESCRIPT'
tell application "System Events"
  tell application process "Dock"
    set dockItems to every UI element of list 1 whose name is "Discord Canary"
    if (count of dockItems) is 0 then return ""
    set badge to value of attribute "AXStatusLabel" of item 1 of dockItems
    if badge is missing value then return ""
    return badge
  end tell
end tell
APPLESCRIPT
)"

COUNT="$(printf '%s' "$BADGE" | grep -Eo '[0-9]+' | head -1)"

if [ -z "$COUNT" ]; then
  sketchybar --set discord \
    drawing=off \
    label.color=0xffd3d9e2 \
    icon.color=0xffd3d9e2 \
    background.color=0xe0000000 \
    background.border_color=0x00000000 \
    background.shadow.drawing=off
else
  sketchybar --set discord \
    drawing=on \
    label="$COUNT" \
    icon=":discord:" \
    label.color=0xffff5f68 \
    icon.color=0xffb9a7ff \
    background.border_color=0x00000000 \
    background.shadow.drawing=on \
    background.shadow.color=0xb06f5cff \
    background.shadow.distance=3
  sketchybar --animate sin 30 \
    --set discord \
      icon.color=0xffb9a7ff icon.color=0xff6655b8 \
      background.shadow.angle=0 background.shadow.angle=360 background.shadow.angle=0
fi
