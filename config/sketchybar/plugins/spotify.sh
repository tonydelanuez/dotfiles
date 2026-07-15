#!/bin/sh

TRACK_INFO="$(osascript 2>/dev/null <<'APPLESCRIPT'
tell application "Spotify"
  if player state is playing or player state is paused then
    set currentTrack to current track
    return (player state as string) & tab & (artist of currentTrack) & tab & (name of currentTrack)
  end if
end tell
APPLESCRIPT
)"

if [ -z "$TRACK_INFO" ]; then
  sketchybar --set now_playing drawing=off
  exit 0
fi

IFS="$(printf '\t')" read -r state artist title <<EOF
$TRACK_INFO
EOF

sketchybar --set now_playing \
  drawing=on \
  icon= \
  label="$artist — $title"
