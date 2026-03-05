# ================= #
# LISTING & VIEWING #
# ================= #

alias ll="ls -lh"
alias la="ls -ah"
alias ld="ll --only-dirs"
alias lla="ls -lah"
alias search="find . -name "
alias mdv="glow"
alias jj="jq ."

# If eza is installed, use that instead of ls
if command -v eza &> /dev/null; then
    alias ls="eza -h --icons --color=always --hyperlink"
else
    alias ls="ls -h --color=always --hyperlink"
fi

# Replace cat and less with calls to bat
if command -v bat &> /dev/null; then
    alias catt="bat"
    alias cat="bat --paging=never --style=plain"
    alias less="bat --paging=always"
fi

# Use erd instead of tree if it's installed
if command -v erd &> /dev/null; then
    alias erd="erd --dir-order=last --sort=name --layout=inverted --icons  --hidden --no-git"
    alias tree="erd --level=2"
fi

# Make sure presenterm uses the kitty protocol for images
alias presenterm="presenterm --image-protocol=kitty-local"

# Grep with colors by default
alias grep="grep --color=auto"

# Set nano to whatever editor is
alias nano="${EDITOR:-nano}"

# Pretty print json files with jq if available
json() {
    [[ -f "$1" ]] || { echo "File not found: $1"; return 1; }
    if command -v jq &>/dev/null; then
        jq . "$1"
    else
        cat "$1" # This will default to bat if available, or plain cat otherwise
    fi
}

# Pretty print yaml files with yq if available
yaml() {
    [[ -f "$1" ]] || { echo "File not found: $1"; return 1; }
    if command -v yq &>/dev/null; then
        yq . "$1"
    else
        cat "$1" # This will default to bat if available, or plain cat otherwise
    fi
}

# Hexdump a file with hexdump or xxd
hex() {
    [[ -f "$1" ]] || { echo "File not found: $1"; return 1; }
    if command -v hexdump &>/dev/null; then
        hexdump . "$1"
    else
        xxd "$1"
    fi
}

# Use fzf to find dirs and cd into them
zz() {
    __ensure_commands fzf zoxide || return
    zoxide query -l | fzf | xargs z
}



# =============== #
# FILE & PATH OPS #
# =============== #

# Make mkdir use -p and -v by default
alias mkdir="mkdir -pv"

# Make a directory and cd into it
function mkcd(){
    mkdir -p -- "$1";
    cd -- "$1";
}

# Create file and parent directories
touchd() {
    mkdir -p "$(dirname "$1")" && touch "$1"
}

# Move with confirmation and verbose output
mvf() {
    mv -iv "$@"
}

# Copy with confirmation and verbose output
cpf() {
    cp -iv "$@"
}

# Safely delete to trash first if it exists
rip() {
    local t="$1"
    [[ -z "$t" ]] && { echo "Usage: rip <file|dir>"; return 1; }

    if [[ "$OSTYPE" == darwin* ]]; then
        mv -vn "$t" ~/.Trash/
    elif [[ -d "$HOME/.local/share/Trash/files" ]]; then
        mv -vn "$t" "$HOME/.local/share/Trash/files/"
    else
        rm -iv "$t"
    fi
}



# =============== #
# SEARCH & FILTER #
# =============== #

# Recursive fdupes if it exists
if command -v fdupes &>/dev/null; then
    alias fdupes="fdupes -r"
fi


# Use ripgrep to find in files but pipe to fzf
fif() {
    __ensure_commands rg fzf || return
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

# Use fd to find files and pipe to fzf
ff() {
    __ensure_commands fd fzf || return
    fd . | fzf
}

# Use fd to find files with a given extension and pipe to fzf
fext() {
    __ensure_commands fd fzf || return
    [[ -n "$1" ]] || { echo "Usage: fext <ext>"; return 1; }
    fd -e "$1" | fzf
}



# ==================== #
# METADATA & TRANSFORM #
# ==================== #

# Get size of a directory in a human readable format, sorted by size
fsize() {
    DIR=${1:-.}
    DIR="$(realpath "$DIR")"
    echo "Getting size of $DIR"
    echo ""
    du -hd 1 "$DIR" | sort -k 1 -n
}

# Get detailed info about a file or directory
finfo() {
    [[ -e "$1" ]] || { echo "File not found: $1"; return 1; }
    stat "$1"
}

# Get a dataurl version of a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Count lines in a file
lines() {
    [[ -f "$1" ]] || { echo "File not found: $1"; return 1; }
    wc -l "$1"
}

# Disk usage of current directory sorted by size
duh() {
    du -ah . | sort -h
}



# ====================== #
# ARCHIVING & EXTRACTING #
# ====================== #

alias ou="ouch"

# Extract nearly anything
x() {
    local file="$1"
    [[ -f "$file" ]] || { echo "No such file: $file" >&2; return 1; }
    case "$file" in
        *.tar.bz2)   tar xjf "$file" ;;
        *.tar.gz)    tar xzf "$file" ;;
        *.tar.xz)    tar xJf "$file" ;;
        *.tar.zst)   tar --zstd -xf "$file" ;;
        *.bz2)       bunzip2 "$file" ;;
        *.rar)       unrar x "$file" ;;
        *.gz)        gunzip "$file" ;;
        *.xz)        xz -d "$file" ;;
        *.zst)       unzstd "$file" ;;
        *.lz4)       unlz4 "$file" ;;
        *.tar)       tar xf "$file" ;;
        *.tbz2)      tar xjf "$file" ;;
        *.tgz)       tar xzf "$file" ;;
        *.zip)       unzip "$file" ;;
        *.Z)         uncompress "$file" ;;
        *.7z)        7z x "$file" ;;
        *)           echo "Don't know how to extract: $file" ;;
    esac
}

# Compress nearly anything
c() {
    local out="$1"
    shift

    if [[ -z "$out" || -z "$@" ]]; then
        echo "Usage: c <output.(zip|tar.gz|tar.xz|tar.zst|7z|tar.bz2|gz|xz|zst)> <files...>"
        return 1
    fi

    case "$out" in
        *.tar.gz|*.tgz)   tar -czf "$out" "$@" ;;
        *.tar.bz2|*.tbz2) tar -cjf "$out" "$@" ;;
        *.tar.xz)         tar -cJf "$out" "$@" ;;
        *.tar.zst)        tar --zstd -cf "$out" "$@" ;;
        *.tar)            tar -cf "$out" "$@" ;;
        *.zip)            zip -r "$out" "$@" ;;
        *.7z)             7z a "$out" "$@" ;;
        *.gz)
            # single file gzip (not tar)
            if [[ $# -ne 1 ]]; then
                echo "Error: .gz compresses only one file, not directories"
                return 1
            fi
            gzip -c "$1" > "$out"
            ;;
        *.xz)
            if [[ $# -ne 1 ]]; then
                echo "Error: .xz compresses only one file, not directories"
                return 1
            fi
            xz -c "$1" > "$out"
            ;;
        *.zst)
            if [[ $# -ne 1 ]]; then
                echo "Error: .zst compresses only one file, not directories"
                return 1
            fi
            zstd -c "$1" > "$out"
            ;;
        *) echo "Don't know how to create: $out" ;;
    esac
}
