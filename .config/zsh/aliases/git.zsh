# ============= #
# GIT SHORTCUTS #
# ============= #
alias gs="git status"
alias ga="git add"
alias gp="git pull"
alias gd="git diff"
alias gsw="git switch"
alias gcb="git switch -c"
alias gcm="git commit -m"
alias gpu="git push"
alias gss="git status -s"
alias gds="git diff --stat"

alias chist='git log --pretty=format:"%Cblue%ci %Creset| %Cgreen%h %Creset| %Cred%an (%cn) %Creset| %s"'
alias glg="git log --graph --decorate --oneline --all"
alias glog="git log --oneline"



# ============= #
# GIT UTILITIES #
# ============= #

# Fuzzy find and show git stashes
fstash() {
    __ensure_commands git fzf || return
    git stash list --color=always --pretty="%C(brightblack)%gd %C(magenta)%h %>(14)%C(cyan)%cr %C(yellow)%gs" |
    fzf --ansi --no-sort --tiebreak=index --bind=ctrl-s:toggle-sort \
        --preview 'git stash show --color=always -p {1}' \
        --bind "ctrl-m:execute:(git stash show --color=always -p {1})"
}

# Fuzzy find and checkout git commits
fshow() {
    __ensure_commands git fzf || return
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --preview 'git show --color=always -p $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1)' \
        --bind 'ctrl-m:execute:(LESS=RSX git -p show --color=always -p $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1))'
}