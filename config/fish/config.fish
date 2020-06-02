thefuck --alias | source 
eval (starship init fish)
alias gh='open (git config remote.origin.url | sed "s/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/")/tree/(git symbolic-ref --quiet --short HEAD )'