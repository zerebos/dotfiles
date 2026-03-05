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
# These functions provide convenient ways to work with package.json scripts.
# They use jq to parse package.json and fzf for interactive selection.
# All execute scripts using "bun run" - replace with "npm run" if preferred.

# Get a random UUID
uuid() {
    __ensure_commands bun || return 1
    bun -e "import { randomUUID } from \"node:crypto\"; console.log(randomUUID())"
}

# Helper: Parse package.json scripts and display in a format for fzf
# Returns: "script_name\tcommand" format for fzf --delimiter
__pick_pkg_script() {
    __ensure_commands jq fzf || return
    jq -r '.scripts | to_entries[] | "\(.key)\t\(.value)"' package.json \
        | fzf --with-nth=1 --delimiter="\t" --preview 'echo -e "\033[1mCommand:\033[0m {2}"'
}


# Interactively select and RUN a package.json script
# Uses fzf to pick the script, then executes it with bun run
#
# Usage: rpkg
# Example: Shows scripts, pick one, it runs immediately
rpkg() {
    __ensure_commands jq bun fzf || return
    local script=$(__pick_pkg_script) || return
    bun run "${script%%$'\t'*}"
}

# Interactively select a package.json script and print command to prompt
# Allows editing before running (good for adding flags)
#
# Usage: fpkg
# Example: Shows scripts, pick one, command appears in prompt for editing
fpkg() {
    __ensure_commands jq bun fzf || return
    local script=$(__pick_pkg_script) || return

    # print -z sets the command line buffer without running the command
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

# Run a specific test from the current package with fzf picker
# Lists all available Test functions and lets you select which to run
#
# Usage: gotf
# Example: Shows list of tests like "TestMain", "TestFoo", etc., pick one
gotf() {
    __ensure_commands fzf go || return
    local test

    # Parse test names from "go test -list ." output and filter for functions starting with "Test"
    test=$(go test -list . | grep -E '^Test' | fzf) || return

    # Run just the selected test
    go test -run "$test"
}

# Browse go module dependencies with preview showing why module is needed
# Helps understand dependency chains and indirect dependencies
#
# Usage: gomodf
# Preview shows the output of "go mod why" for the selected module
gomodf() {
    __ensure_commands fzf go || return

    # List ALL dependencies (direct and indirect with -m all)
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

# Pick an emoji from the latest list of gitmojis, cached for 30 days, with fzf search and preview
#
# Usage: emoji
# Returns: The selected emoji character (e.g. "✨") which can be used in commit messages or elsewhere
emoji() {
    __ensure_commands fzf || return 1
    local url='https://git.io/JXXO7'
    local file=$(__get_remote_resource "$url" "emojis.txt" "30d")
    fzf < "$file"
}

# Gitmoji picker for commit messages that fetches the latest gitmojis
# from the GitHub repo, caches for 30 days, and allows searching with fzf
#
# Usage: git commit -m "$(gitmoji) Your commit message"
# Returns: The selected emoji code (e.g. ":sparkles:") which can be used in commit messages or elsewhere
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
