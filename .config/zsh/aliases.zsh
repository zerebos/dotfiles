alias ls="eza --icons --color=always --hyperlink"
alias cat="bat"
alias less="bat"
alias cd="z"
alias presenterm="presenterm --image-protocol=kitty-local"
alias nano="micro"

alias ll="ls -lh"
alias la="ls -ah"
alias lla="ls -lah"
alias ld="ll --only-dirs --ignore-glob go"
alias cd..="cd .."
alias ..="cd .."
alias search="find . -name "
alias mkdir="mkdir -pv"
#alias rm="rm -i"
alias grep="grep --color=auto"
alias hs="history | grep"
alias python="python3"


alias g="git"
alias gs="git status"
alias ga="git add"
alias gp="git pull"

#alias chist='git log --pretty=format:"%ci %h: %an (%cn): %s"'
alias chist='git log --pretty=format:"%Cblue%ci %Creset| %Cgreen%h %Creset| %Cred%an (%cn) %Creset| %s %s"'
alias glog="git log"
alias glogo="git log --oneline"
alias gstatus="git status"

function mkcd(){
  mkdir -p "$1";
  cd "$1";
}
