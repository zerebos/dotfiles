# ============= #
# GIT SHORTCUTS #
# ============= #
alias g="git"
alias gs="git status"
alias ga="git add"
alias gp="git pull"

alias chist='git log --pretty=format:"%Cblue%ci %Creset| %Cgreen%h %Creset| %Cred%an (%cn) %Creset| %s"'
alias glog="git log"
alias glogo="git log --oneline"
alias gstatus="git status"

# easier way to deal with stashes
fstash() {
    git stash list --color=always --pretty="%C(brightblack)%gd %C(magenta)%h %>(14)%C(cyan)%cr %C(yellow)%gs" |
    fzf --ansi --no-sort --tiebreak=index --bind=ctrl-s:toggle-sort \
        --preview 'git stash show --color=always -p {1}' \
        --bind "ctrl-m:execute:(git stash show --color=always -p {1})"
}

fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --preview 'git show --color=always -p $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1)' \
        --bind 'ctrl-m:execute:(LESS=RSX git -p show --color=always -p $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1))'
}