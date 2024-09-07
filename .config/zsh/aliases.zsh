# ======== #
# FILE OPS #
# ======== #
alias ll="ls -lh"
alias la="ls -ah"
alias ld="ll --only-dirs"
alias lla="ls -lah"

# If eza is installed, use that instead of ls
if command -v eza &> /dev/null; then
  alias ls="eza -h --icons --color=always --hyperlink"
else
  alias ls="ls -h --color=always --hyperlink"
fi

# Set nano to whatever editor is
alias nano="${EDITOR:-nano}"

# Alias for yazi to cd into dir on exit
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Use ripgrep to find in files but pipe to fzf
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# Replace cat and less with calls to bat
if command -v bat &> /dev/null; then
  alias cat="bat"
  alias less="bat"
fi

# Add some nice defaults for some commands
alias presenterm="presenterm --image-protocol=kitty-local"
alias search="find . -name "
alias grep="grep --color=auto"




# ============= #
# DIRECTORY OPS #
# ============= #
alias cd..="cd .."
alias ..="cd .."
alias mkdir="mkdir -pv"

function mkcd(){
  mkdir -p "$1";
  cd "$1";
}

if command -v zoxide &> /dev/null; then
  alias cd="z"
fi




# ============= #
# GIT SHORTCUTS #
# ============= #
alias g="git"
alias gs="git status"
alias ga="git add"
alias gp="git pull"

alias chist='git log --pretty=format:"%Cblue%ci %Creset| %Cgreen%h %Creset| %Cred%an (%cn) %Creset| %s %s"'
alias glog="git log"
alias glogo="git log --oneline"
alias gstatus="git status"




# ===== #
# OTHER #
# ===== #

# Load local custom aliases from separate file
# Mostly used for work PCs with private stuff
if [ -f $ZDOTDIR/aliases.local.zsh ]; then
    . $ZDOTDIR/aliases.local.zsh
fi
