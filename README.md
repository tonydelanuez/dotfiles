# dotfiles

Personal macOS configuration, managed as a normal Git repository and installed with symlinks.

## Bootstrap a Mac

```sh
git clone https://github.com/tonydelanuez/dotfiles.git ~/dotfiles
~/dotfiles/scripts/install
```

The installer:

- installs Homebrew dependencies from `Brewfile`;
- links shell configuration into `$HOME`;
- links SketchyBar into `~/.config/sketchybar`;
- installs the bundled SketchyBar app-symbol font;
- starts SketchyBar and Amethyst.

Existing files are moved aside with a `.dotfiles-backup-YYYYMMDDHHMMSS` suffix before linking.

## macOS permissions

Grant Accessibility permissions to `Amethyst` and `SketchyBar` in System Settings → Privacy & Security → Accessibility.

## Syncing

```sh
dotfiles pull --rebase
dotfiles add -A
dotfiles commit -m "Update dotfiles"
dotfiles push
```

Machine-specific secrets and runtime state should stay outside this repository.
