# Personal macOS shell configuration.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="edvardm"
plugins=(git)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/gems/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)
export PATH

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export GEM_HOME="$HOME/gems"

[[ -r "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
[[ -r "$HOME/.ssh_agent" ]] && source "$HOME/.ssh_agent"
