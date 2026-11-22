#!/bin/zsh

input=$(cat)
jqr() { print -r -- "$input" | jq -r "$1 // empty"; }
dir=$(jqr '.workspace.current_dir // .cwd')
model=$(jqr '.model.display_name')
pct=$(jqr '.context_window.used_percentage')
cost=$(jqr '.cost.total_cost_usd')

fg() { print -n "\e[38;2;$1m"; }
pink='215;135;175' teal='0;175;175' green='111;211;165' yellow='214;195;90'
red='242;139;110' dim='138;143;158' text='225;226;230'
sep=" $(fg $dim)"$''" "

out="$(fg $pink)"$''" $model"
out+="$sep$(fg $teal)"$''" ${dir:t}"

branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
if [[ -n $branch ]]; then
  st=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(print -r -- "$st" | grep -c '^[MADRC]')
  unstaged=$(print -r -- "$st" | grep -c '^.[MD]')
  untracked=$(print -r -- "$st" | grep -c '^??')
  flags=''
  (( staged )) && flags+=" +$staged"
  (( unstaged )) && flags+=" *$unstaged"
  (( untracked )) && flags+=" ?$untracked"
  [[ -n $flags ]] && color=$yellow || color=$green
  out+="$sep$(fg $color)"$''" $branch$flags"
fi

if [[ -n $pct ]]; then
  color=$dim
  (( pct >= 70 )) && color=$yellow
  (( pct >= 90 )) && color=$red
  out+="$sep$(fg $color)"$''" $(printf "%.0f" $pct)%"
fi

[[ -n $cost ]] && out+="$sep$(fg $text)"$''"$(printf '%.2f' $cost)"

print -r -- "$out"$'\e[0m'
