# Shell configuration — macOS + Linux.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="edvardm"
plugins=(git)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# ── Platform detection ───────────────────────────────────────────────
_is_macos=false
_is_linux=false
case "$OSTYPE" in
  darwin*) _is_macos=true ;;
  linux*)  _is_linux=true ;;
esac

# ── PATH ─────────────────────────────────────────────────────────────
typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/gems/bin"
  $path
)

if $_is_macos; then
  path=(
    /opt/homebrew/bin
    /opt/homebrew/sbin
    $path
  )
fi

if $_is_linux; then
  path=(
    /home/linuxbrew/.linuxbrew/bin
    $path
  )
fi

export PATH

# ── Editor ───────────────────────────────────────────────────────────
if $_is_macos; then
  export EDITOR="${EDITOR:-vim}"
else
  export EDITOR="${EDITOR:-nvim}"
fi
export VISUAL="${VISUAL:-$EDITOR}"

# ── Language runtimes ────────────────────────────────────────────────
export GEM_HOME="$HOME/gems"

alias k='kubectl'

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi

# ── Platform-specific extras ─────────────────────────────────────────
if $_is_macos; then
  export PATH="$PATH:$HOME/.spicetify"
fi

if $_is_linux && [[ -r "$HOME/.zshrc.linux" ]]; then
  source "$HOME/.zshrc.linux"
fi

# ── Shared sources ───────────────────────────────────────────────────
[[ -r "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
[[ -r "$HOME/.ssh_agent" ]]   && source "$HOME/.ssh_agent"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
