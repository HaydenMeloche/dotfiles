export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export LANG="en_US.UTF-8"
export PAGER="less"
export EDITOR="nvim"
export VISUAL="$EDITOR"
export GIT_USERNAME="HaydenMeloche"

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
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh" --no-use
  _nvm_default="$NVM_DIR/versions/node/$(<"$NVM_DIR/alias/default")"
  if [[ -d "$_nvm_default/bin" ]]; then
    path_prepend "$_nvm_default/bin"
  else
    nvm use default --silent
  fi
  unset _nvm_default
fi

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Keep the Cloud CLI available without displaying its active account in the prompt.
export SPACESHIP_GCLOUD_SHOW=false

fpath=("$HOME/.docker/completions" $fpath)

plugins=()
ZSH_THEME=""
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Ctrl-R command-history search, Ctrl-T file search, and Alt-C directory search.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

if [[ -d "$DOTFILES/custom" ]]; then
  for file in "$DOTFILES"/custom/*.zsh(N); do source "$file"; done
fi

# Keep Herdr tab names in sync with the foreground command.
for _herdr_rename_hook in "$HOME"/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source "$_herdr_rename_hook"
  break
done
unset _herdr_rename_hook

# This file is intentionally untracked: tokens, work endpoints, and local paths go here.
[[ -f "$HOME/.zshlocal" ]] && source "$HOME/.zshlocal"
