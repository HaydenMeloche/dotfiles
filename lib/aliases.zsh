if command -v eza >/dev/null 2>&1; then
  alias ll='eza -la --git'
else
  alias ll='ls -la'
fi
alias l='ls -CF'
alias la='ls -A'
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --all --graph --decorate --oneline'
alias gst='git status'
alias gco='git checkout'
alias gcam='git commit -a -m'
alias gp='git push'
alias gf='git fetch'
alias gl='git pull'
alias grb='git rebase'
alias c='clear'
alias clr='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias e='$EDITOR'
alias o='open'
alias oo='open .'
alias git-root='cd "$(git rev-parse --show-toplevel)"'
alias dotfiles='cd "$DOTFILES"'
alias update='dotfiles-update'
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\\.){3}[0-9]*).*/\\2/p'"
alias path='echo ${PATH//:/\\n}'
alias reload='source ~/.zshrc'

# Usage: killport 3000
killport() {
  if [[ ! "$1" =~ '^[0-9]+$' ]]; then
    print -u2 'Usage: killport <port>'
    return 2
  fi

  local pids
  pids="$(command lsof -tiTCP:"$1" -sTCP:LISTEN)"
  if [[ -z "$pids" ]]; then
    print -u2 "No process is listening on port $1."
    return 1
  fi

  print "Killing process(es) on port $1: $pids"
  kill $pids
}
