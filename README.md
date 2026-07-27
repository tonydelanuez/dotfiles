# dotfiles

Personal shell & tool configuration for **macOS** and **Linux** (remote dev).

Managed as a normal Git repository and installed with symlinks.

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
- links yabai and skhd config into `$HOME`;
- starts SketchyBar, yabai, and skhd.

Existing files are moved aside with a `.dotfiles-backup-YYYYMMDDHHMMSS` suffix before linking.

## macOS permissions

Grant Accessibility permissions to `yabai`, `skhd`, and `SketchyBar` in System Settings → Privacy & Security → Accessibility. Yabai's scripting addition (for window animations + better space management) requires a sudoers entry — see `brew info yabai`.

## Bootstrap a Linux remote dev box

```sh
git clone https://github.com/tonydelanuez/dotfiles.git ~/dotfiles
~/dotfiles/scripts/install-linux
```

The Linux installer:

- installs system packages from `packages.apt` (zsh, git, neovim, ripgrep, fzf, etc.);
- installs Oh My Zsh and sets zsh as the default shell;
- installs nvm, Rust, herdr (terminal multiplexer), and bun;
- links cross-platform dotfiles (zsh, git, vim, herdr, ssh_agent);
- **skips** macOS-only tools (yabai, skhd, sketchybar, ghostty, amethyst, vx).

After install:

```sh
exec zsh                    # reload shell
herdr                       # start terminal multiplexer
nvm install --lts           # install Node LTS
```

Create `~/.gitconfig.local` with your name and email — `.gitconfig` will include it.

## Remote dev workflow (phone + Tailscale)

```sh
# From your phone (or any device on your tailnet):
ssh oci-box          # SSH over Tailscale
tmux attach          # or: herdr
```

`herdr --remote` on the phone will connect you to the remote herdr session.

## Syncing

```sh
dotfiles pull --rebase
dotfiles add -A
dotfiles commit -m "Update dotfiles"
dotfiles push
```

Machine-specific secrets and runtime state should stay outside this repository.
