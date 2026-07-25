#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

SID="${NAME#space.}"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    icon.highlight=on
  sketchybar --set "desktop.$SID" \
    background.drawing=on \
    background.color=0xffb8d4f1 \
    background.border_color=0xffe9f3ff
  for slot in 1 2 3; do
    sketchybar --set "app_icon.$SID.$slot" icon.color=0xff17202b
  done
else
  sketchybar --set "$NAME" \
    icon.highlight=off
  sketchybar --set "desktop.$SID" \
    background.drawing=on \
    background.color=0xe0000000 \
    background.border_color=0x253d4b5a
  for slot in 1 2 3; do
    sketchybar --set "app_icon.$SID.$slot" icon.color=0xffd3d9e2
  done
fi
