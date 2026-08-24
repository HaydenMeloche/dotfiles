export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export PAGER="less"
export EDITOR="nvim"
export VISUAL="$EDITOR"

setopt noclobber
setopt auto_cd

path_prepend() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in *":$1:"*) ;; *) export PATH="$1:$PATH" ;; esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$DOTFILES/bin"
path_prepend "$HOME/.npm-global/bin"
path_prepend "$HOME/.bun/bin"

# Keep navigation and display helpers available even if shell plugins fail to load.
[[ -f "$DOTFILES/lib/aliases.zsh" ]] && source "$DOTFILES/lib/aliases.zsh"
[[ -f "$DOTFILES/lib/lscolors.zsh" ]] && source "$DOTFILES/lib/lscolors.zsh"
[[ -f "$DOTFILES/lib/smartdots.zsh" ]] && source "$DOTFILES/lib/smartdots.zsh"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if [[ -d "$DOTFILES/custom" ]]; then
  for file in "$DOTFILES"/custom/*.zsh(N); do source "$file"; done
fi

# This file is intentionally untracked: tokens, work endpoints, and local paths go here.
[[ -f "$HOME/.zshlocal" ]] && source "$HOME/.zshlocal"
