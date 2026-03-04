# ================ #
# HTTP & API TOOLS #
# ================ #

# Get headers response
alias hh='curl -sI'

# Get a JSON response prettily
curlj() {
    if ! command -v jq &> /dev/null; then echo "Need jq to run this!"; return 1; fi
    curl -s "$@" | jq .
}

# Serve a local directory temporarily
serve() {
    if command -v bunx &>/dev/null; then
        bunx --bun serve --port "${1:-8000}" --dir "${2:-.}"
    else
        python3 -m http.server "${1:-8000}"
    fi
}



# ==================== #
# NODE & BUN WORKFLOWS #
# ==================== #

# Get a random UUID
uuid() {
    if ! command -v bun &> /dev/null; then echo "Need bun to run this!"; return 1; fi
    bun -e "import { randomUUID } from \"node:crypto\"; console.log(randomUUID())"
}

# Pick a package.json script with fzf and run it with bun
__pick_pkg_script() {
    jq -r '.scripts | to_entries[] | "\(.key)\t\(.value)"' package.json \
        | fzf --with-nth=1 --delimiter="\t" --preview 'echo -e "\033[1mCommand:\033[0m {2}"'
}


# Run package.json script using bun (requires jq)
rpkg() {
    if ! command -v jq &> /dev/null; then echo "Need jq to run this!"; return 1; fi
    local script=$(__pick_pkg_script) || return
    bun run "${script%%$'\t'*}"
}

# Run package.json script using bun with fzf previewing the command
fpkg() {
    if ! command -v jq &> /dev/null; then echo "Need jq to run this!"; return 1; fi
    local script=$(__pick_pkg_script) || return
    print -z "bun run ${script%%$'\t'*}"
}

# List package.json scripts
lspkg() {
    if ! command -v jq &> /dev/null; then echo "Need jq to run this!"; return 1; fi
    {
        echo -e "\033[1mSCRIPT\tCOMMAND\033[0m";
        jq -r '.scripts | to_entries[] | "[\(.key)]\t\(.value)"' package.json;
    } | column -t -s $'\t'
}



# ============ #
# GO WORKFLOWS #
# ============ #

# Run a go program (targets current dir by default)
gor() {
    local target="${1:-.}"
    go run "$target"
}

# Build a go program to ./bin (targets current dir by default)
gob() {
    mkdir -p bin
    local target="${1:-.}"
    go build -o bin/ "$target"
}

# Run a go test with fzf to select the test
gotf() {
    local test
    test=$(go test -list . | grep -E '^Test' | fzf) || return
    go test -run "$test"
}

# List all dependencies (both direct and indirect) with fzf
gomodf() {
    go list -m all 2>/dev/null | fzf --preview 'go mod why {1}' --preview-window=wrap
}




# ====================== #
# ENVIRONMENT INSPECTION #
# ====================== #

# Print every path in $PATH on its own line
paths() {
    print -l -- $path
}

# Same but with line numbers
pathsn() {
    local i
    for i in {1..$#path}; do
        printf '%2d  %s\n' $i "$path[$i]"
    done
}

# Show detailed info about a command, including all paths it appears in
whichp() {
    [[ -n "$1" ]] || { echo "Usage: whichp <command>"; return 1; }
    whence -a -- "$1"
}

# Show the nearest .env
envcat() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.env" ]]; then
            cat "$dir/.env"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo "No .env file found"
    return 1
}

# Search env vars with fzf
fenv() {
    printenv | fzf --query="$1"
}

# Search for a command in $PATH with fzf
fcmd() {
    local cmd
    cmd=$(print -l ${(ko)commands} | fzf --query="$1" --preview 'whence -a {}' --height=40% --border) || return
    print -z "$cmd"
}

# Search for an alias with fzf
falias() {
    local cmd
    cmd=$(alias | sed 's/=/\t/' | fzf --query="$1" --delimiter="\t" --with-nth=1 --preview 'echo -e "\033[1mAlias:\033[0m {1}\n\n\033[1mExpands to:\033[0m {2}"' --preview-window=up:3:wrap) || return
    print -z "${cmd%%$'\t'*}"
}

# Search for a brew with fzf
fbrew() {
    local cmd
    cmd=$(brew list | fzf --query="$1" --preview 'echo -e "\033[1mFormula/Cask:\033[0m {}\n"; HOMEBREW_COLOR=1 brew info {}' --border) || return
    print -z "$cmd"
}



# ================== #
# WORKFLOW UTILITIES #
# ================== #

alias hf="hyperfine"

# TODO: these should move to a helper lib
# Ensure a command exists, printing an error if it doesn't
__ensure_commands() {
    [[ $# -gt 0 ]] || { echo "Usage: __ensure_command <cmd> [...]"; return 1; }
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: Command not found: $cmd"
            return 1
        fi
    done
}


# Get and cache a remote resource to a local file and return the file path, re-downloading if it's older than a given age (default 7 days)
__get_remote_resource() {

    # Get the cache directory, preferring $ZSH_CACHE_DIR, then $XDG_CACHE_HOME, then ~/.cache/zsh
    local cache_dir="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:+$XDG_CACHE_HOME/zsh}}"
    cache_dir="${cache_dir:-$HOME/.cache/zsh}"

    # Ensure the cache directory exists
    if [[ ! -d "$cache_dir" ]]; then
        mkdir -p "$cache_dir"
    fi

    local url="$1"
    local filename=${2:-$(basename "$url")}
    local max_age="${3:-7d}"
    local cache_file="$cache_dir/$filename"

    local days="${max_age%d}"
    if [[ -f "$cache_file" ]]; then
        if find "$cache_file" -mtime -"${days}" -print -quit | grep -q .; then
            echo "$cache_file"
            return 0
        fi
    fi
    curl -sSL "$url" -o "$cache_file"
    echo "$cache_file"
}

# emoji picker
emoji() {
    local url='https://git.io/JXXO7'
    local file=$(__get_remote_resource "$url" "emojis.txt" "30d")
    fzf < "$file"
}

# TODO: consider using gitmoji-cli
# gitmoji picker
gitmoji() {
    __ensure_commands jq || return 1
    local url='https://raw.githubusercontent.com/carloscuesta/gitmoji/refs/heads/master/packages/gitmojis/src/gitmojis.json'
    local file="$(__get_remote_resource "$url" "gitmojis.json" "30d")"

    jq -r '.gitmojis[] | "\(.emoji)  \(.code)  \(.description)"' "$file" \
        | fzf --preview 'echo {}' \
        | awk '{print $1}'
}

# Get current timestamp in unix and ISO format
ts() {
    echo "unix: $(date +%s)"
    echo "iso:  $(date -Iseconds)"
}

# Take a screenshot to share using silicon (requires silicon)
ssf() {
    __ensure_commands silicon || return 1
    silicon "$1" -o "${1%.*}.png"
}
