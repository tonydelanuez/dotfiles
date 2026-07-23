#!/usr/bin/env zsh

set -euo pipefail

defaults write com.amethyst.Amethyst "screen-padding-top" -int 40
defaults write com.amethyst.Amethyst "screen-padding-bottom" -int 0
defaults write com.amethyst.Amethyst "screen-padding-left" -int 0
defaults write com.amethyst.Amethyst "screen-padding-right" -int 0
defaults write com.amethyst.Amethyst "window-margins" -bool false
defaults write com.amethyst.Amethyst "window-margin-size" -int 6
defaults write com.amethyst.Amethyst "disable-padding-on-builtin-display" -bool true
defaults write com.amethyst.Amethyst "focus-follows-mouse" -bool false
defaults write com.amethyst.Amethyst "mouse-follows-focus" -bool false
defaults write com.amethyst.Amethyst "float-small-windows" -bool true
defaults write com.amethyst.Amethyst "new-windows-to-main" -bool false
defaults write com.amethyst.Amethyst "follow-space-thrown-windows" -bool true
defaults write com.amethyst.Amethyst "restore-layouts-on-launch" -bool true
defaults write com.amethyst.Amethyst "window-max-count" -int 0
defaults write com.amethyst.Amethyst layouts -array tall wide fullscreen column
defaults write com.amethyst.Amethyst mod1 -array option shift
defaults write com.amethyst.Amethyst mod2 -array option shift control

killall Amethyst 2>/dev/null || true
