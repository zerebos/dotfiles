# ================ #
# HTTP & API TOOLS #
# ================ #

# Get headers response
alias hh='curl -sI'

# Get a JSON response prettily
curlj() {
    __ensure_commands curl jq || return 1
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
    __ensure_commands bun || return 1
    bun -e "import { randomUUID } from \"node:crypto\"; console.log(randomUUID())"
}

# Pick a package.json script with fzf and run it with bun
__pick_pkg_script() {
    __ensure_commands jq fzf || return
    jq -r '.scripts | to_entries[] | "\(.key)\t\(.value)"' package.json \
        | fzf --with-nth=1 --delimiter="\t" --preview 'echo -e "\033[1mCommand:\033[0m {2}"'
}


# Run package.json script using bun (requires jq)
rpkg() {
    __ensure_commands jq bun fzf || return
    local script=$(__pick_pkg_script) || return
    bun run "${script%%$'\t'*}"
}

# Run package.json script using bun with fzf previewing the command
fpkg() {
    __ensure_commands jq bun fzf || return
    local script=$(__pick_pkg_script) || return
    print -z "bun run ${script%%$'\t'*}"
}

# List package.json scripts
lspkg() {
    __ensure_commands jq || return
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
    __ensure_commands go || return
    local target="${1:-.}"
    go run "$target"
}

# Build a go program to ./bin (targets current dir by default)
gob() {
    __ensure_commands go || return
    mkdir -p bin
    local target="${1:-.}"
    go build -o bin/ "$target"
}

# Run a go test with fzf to select the test
gotf() {
    __ensure_commands fzf go || return
    local test
    test=$(go test -list . | grep -E '^Test' | fzf) || return
    go test -run "$test"
}

# List all dependencies (both direct and indirect) with fzf
gomodf() {
    __ensure_commands fzf go || return
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
    __ensure_commands fzf || return
    printenv | fzf --query="$1"
}

# Search for a command in $PATH with fzf
fcmd() {
    __ensure_commands fzf || return
    local cmd
    cmd=$(print -l ${(ko)commands} | fzf --query="$1" --preview 'whence -a {}' --height=40% --border) || return
    print -z "$cmd"
}

# Search for an alias with fzf
falias() {
    __ensure_commands fzf || return
    local cmd
    cmd=$(alias | sed 's/=/\t/' | fzf --query="$1" --delimiter="\t" --with-nth=1 --preview 'echo -e "\033[1mAlias:\033[0m {1}\n\n\033[1mExpands to:\033[0m {2}"' --preview-window=up:3:wrap) || return
    print -z "${cmd%%$'\t'*}"
}

# Search for a brew with fzf
fbrew() {
    __ensure_commands brew fzf || return
    local cmd
    cmd=$(brew list | fzf --query="$1" --preview 'echo -e "\033[1mFormula/Cask:\033[0m {}\n"; HOMEBREW_COLOR=1 brew info {}' --border) || return
    print -z "$cmd"
}



# ================== #
# WORKFLOW UTILITIES #
# ================== #

alias hf="hyperfine"

# emoji picker
emoji() {
    __ensure_commands fzf || return 1
    local url='https://git.io/JXXO7'
    local file=$(__get_remote_resource "$url" "emojis.txt" "30d")
    fzf < "$file"
}

# TODO: consider using gitmoji-cli
# gitmoji picker
gitmoji() {
    __ensure_commands jq fzf || return 1
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
