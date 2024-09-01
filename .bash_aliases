alias homelab="ssh homelab"
alias bdssh="ssh bd"
alias graylog="ssh -L 9000:localhost:9000 bd"
alias contabo="ssh contabo"

alias eza="eza --icons"
alias ls="eza"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"

alias cd="z"
alias cat="bat"
alias less="bat"
export PAGER="bat"
alias nano="micro"

alias blockip='sudo iptables -A INPUT -s $1 -j DROP'
alias unblockip='sudo iptables -D INPUT -s $1 -j DROP'

fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}
