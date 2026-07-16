# Prefill an editable command line and run it on Enter. This is the bash
# stand-in for zsh's `print -z` (which pushes text onto the next prompt buffer);
# bash can't do that from a normal function, so we read an editable line
# pre-filled with the command instead.
__edit_run() {
    local line
    read -e -i "$1" -p '❯ ' line || return
    [[ -n "$line" ]] || return
    history -s "$line"
    eval "$line"
}


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
    if command -v uuidgen &>/dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif command -v bun &>/dev/null; then
        bun -e "import { randomUUID } from \"node:crypto\"; console.log(randomUUID())"
    else
        cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "No UUID generator found"
    fi
}

# Helper: parse package.json scripts into "name\tcommand" for fzf
__pick_pkg_script() {
    __ensure_commands jq fzf || return
    jq -r '.scripts | to_entries[] | "\(.key)\t\(.value)"' package.json \
        | fzf --with-nth=1 --delimiter="\t" --preview 'echo -e "\033[1mCommand:\033[0m {2}"'
}

# Interactively select and RUN a package.json script
rpkg() {
    __ensure_commands jq bun fzf || return
    local script
    script=$(__pick_pkg_script) || return
    bun run "${script%%$'\t'*}"
}

# Interactively select a package.json script and print it to the prompt for
# editing (add flags, etc.) before running.
fpkg() {
    __ensure_commands jq bun fzf || return
    local script
    script=$(__pick_pkg_script) || return
    __edit_run "bun run ${script%%$'\t'*}"
}

# List package.json scripts
lspkg() {
    __ensure_commands jq || return
    {
        echo -e "\033[1mSCRIPT\tCOMMAND\033[0m"
        jq -r '.scripts | to_entries[] | "[\(.key)]\t\(.value)"' package.json
    } | column -t -s $'\t'
}



# ============ #
# GO WORKFLOWS #
# ============ #

# Run a go program (targets current dir by default)
gor() {
    __ensure_commands go || return
    go run "${1:-.}"
}

# Build a go program to ./bin (targets current dir by default)
gob() {
    __ensure_commands go || return
    mkdir -p bin
    go build -o bin/ "${1:-.}"
}

# Run a specific test from the current package with an fzf picker
gotf() {
    __ensure_commands fzf go || return
    local test
    test=$(go test -list . | grep -E '^Test' | fzf) || return
    go test -run "$test"
}

# Browse go module dependencies with a "go mod why" preview
gomodf() {
    __ensure_commands fzf go || return
    go list -m all 2>/dev/null | fzf --preview 'go mod why {1}' --preview-window=wrap
}



# ====================== #
# ENVIRONMENT INSPECTION #
# ====================== #

# Print every path in $PATH on its own line
paths() {
    local -a arr
    IFS=: read -ra arr <<< "$PATH"
    printf '%s\n' "${arr[@]}"
}

# Same but with line numbers
pathsn() {
    local -a arr
    IFS=: read -ra arr <<< "$PATH"
    local i
    for i in "${!arr[@]}"; do
        printf '%2d  %s\n' $((i + 1)) "${arr[i]}"
    done
}

# Show detailed info about a command, including all paths it appears in
whichp() {
    [[ -n "$1" ]] || { echo "Usage: whichp <command>"; return 1; }
    type -a "$1"
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

# Search for a command in $PATH with fzf, then edit/run it
fcmd() {
    __ensure_commands fzf || return
    local cmd
    cmd=$(compgen -c | sort -u | fzf --query="$1" --preview 'type -a {}' --height=40% --border) || return
    __edit_run "$cmd"
}

# Search for an alias with fzf, then edit/run its expansion
falias() {
    __ensure_commands fzf || return
    local cmd
    cmd=$(alias | sed -E 's/^alias //; s/=/\t/' \
        | fzf --query="$1" --delimiter="\t" --with-nth=1 \
              --preview 'echo -e "\033[1mAlias:\033[0m {1}\n\n\033[1mExpands to:\033[0m {2}"' \
              --preview-window=up:3:wrap) || return
    __edit_run "${cmd%%$'\t'*}"
}

# Search for a brew formula/cask with fzf
fbrew() {
    __ensure_commands brew fzf || return
    local cmd
    cmd=$(brew list | fzf --query="$1" \
        --preview 'echo -e "\033[1mFormula/Cask:\033[0m {}\n"; HOMEBREW_COLOR=1 brew info {}' --border) || return
    __edit_run "$cmd"
}



# ================== #
# WORKFLOW UTILITIES #
# ================== #

command -v hyperfine &>/dev/null && alias hf="hyperfine"

# Pick an emoji from the latest gitmoji list (cached 30 days) with fzf
emoji() {
    __ensure_commands fzf || return 1
    local url='https://git.io/JXXO7'
    local file
    file=$(__get_remote_resource "$url" "emojis.txt" "30d")
    fzf < "$file"
}

# Gitmoji picker for commit messages.
# Usage: git commit -m "$(gitmoji) Your commit message"
gitmoji() {
    __ensure_commands jq fzf || return 1
    local url='https://raw.githubusercontent.com/carloscuesta/gitmoji/refs/heads/master/packages/gitmojis/src/gitmojis.json'
    local file
    file="$(__get_remote_resource "$url" "gitmojis.json" "30d")"

    jq -r '.gitmojis[] | "\(.emoji)  \(.code)  \(.description)"' "$file" \
        | fzf --preview 'echo {}' \
        | awk '{print $1}'
}

# Get current timestamp in unix and ISO format
ts() {
    echo "unix: $(date +%s)"
    echo "iso:  $(date -Iseconds)"
}

# Take a screenshot of source to share using silicon
ssf() {
    __ensure_commands silicon || return 1
    silicon "$1" -o "${1%.*}.png"
}
