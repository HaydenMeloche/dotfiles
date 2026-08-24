if command -v eza >/dev/null 2>&1; then
  alias ll='eza -la --git'
else
  alias ll='ls -la'
fi
alias l='ls -CF'
alias la='ls -A'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --all --graph --decorate --oneline'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias reload='source ~/.zshrc'
