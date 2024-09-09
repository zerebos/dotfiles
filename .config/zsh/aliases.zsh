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
  rm -f /tmp/rg-fzf-{r,f}
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
        echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
        echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt '1. ripgrep> ' \
      --delimiter : \
      --header 'CTRL-T: Switch between ripgrep/fzf' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'border-left,+{2}+3/3,~3' \
      --bind 'enter:become(vim {1} +{2})'
}

# Get a dataurl version of a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
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
if command -v erd &> /dev/null; then
  alias erd="erd --dir-order=last --sort=name --layout=inverted --icons  --hidden --no-git"
  alias tree="erd --level=2"
fi




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




# ======== #
# HOMEBREW #
# ======== #

# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]ackage
bip() {
  local inst=$(brew search "$@" | fzf -m)

  if [[ $inst ]]; then
    for prog in $(echo $inst);
    do; brew install $prog; done;
  fi
}

# Update (one or multiple) selected application(s)
# mnemonic [B]rew [U]pdate [P]ackage
bup() {
  local upd=$(brew leaves | fzf -m)

  if [[ $upd ]]; then
    for prog in $(echo $upd);
    do; brew upgrade $prog; done;
  fi
}

# Delete (one or multiple) selected application(s)
# mnemonic [B]rew [C]lean [P]ackage (e.g. uninstall)
bcp() {
  local uninst=$(brew leaves | fzf -m)

  if [[ $uninst ]]; then
    for prog in $(echo $uninst);
    do; brew uninstall $prog; done;
  fi
}




# ===== #
# OTHER #
# ===== #

# emoji picker
emoji() {
  emojis=$(curl -sSL 'https://git.io/JXXO7')
  selected_emoji=$(echo $emojis | fzf)
  echo $selected_emoji
}

# Run npm script (requires jq)
rnpm() {
  if ! command -v jq &> /dev/null; then echo "Need jq to run this!"; return 1; fi
  local script
  script=$(cat package.json | jq -r '.scripts | keys[] ' | sort | fzf) && npm run $(echo "$script")
}

# Print every path in $PATH on its own line
alias path="echo -e ${PATH//:/\\n}"

# Load local custom aliases from separate file
# Mostly used for work PCs with private stuff
if [ -f $ZDOTDIR/aliases.local.zsh ]; then
    . $ZDOTDIR/aliases.local.zsh
fi
