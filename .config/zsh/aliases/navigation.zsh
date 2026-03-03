# ==================== #
# SHORTCUTS & DEFAULTS #
# ==================== #

alias cd..="cd .."
alias ..="cd .."
alias prev='dirs -v'
alias back="cd -"
alias back2='cd ~2'
alias cc="clear && cd"

# Use zoxide if it's installed for smarter navigation
if command -v zoxide &> /dev/null; then
    alias cd="z"
fi

# Cd to nearest git root
cdg() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "Not inside a git repository"
        return 1
    }
    cd "$root"
}

# Cd to nearest project root (git, npm, go, or cargo)
cdp() {
    local markers=(".git" "package.json" "go.mod" "Cargo.toml" "$1")
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do
        for m in $markers; do
            [[ -e "$dir/$m" ]] && cd "$dir" && return 0
        done
        dir=$(dirname "$dir")
    done

    echo "No project root found"
    return 1
}

# Cd to nearest dir with a given name
cdup() {
    [[ -n "$1" ]] || { echo "Usage: cdup <dirname>"; return 1; }
    local target="$1"
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ "$(basename "$dir")" == "$target" ]]; then
            cd "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "No parent directory named '$target' found"
    return 1
}

# Cd to directory containing a given file or marker
cdm() {
    [[ -n "$1" ]] || { echo "Usage: cdm <marker>"; return 1; }
    local marker="$1"
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do
        if [[ -e "$dir/$marker" ]]; then
            cd "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done

    echo "No directory containing '$marker' found"
    return 1
}

# Cd to a directory selected with fzf, searching from current dir
cdfz() {
    local dir
    dir=$(fd -t d . | fzf) || return
    cd "$dir"
}

# Cd to the directory of a file
cdf() {
    [[ -f "$1" ]] || { echo "File not found: $1"; return 1; }
    cd "$(dirname "$(realpath "$1")")"
}



# ========= #
# UTILITIES #
# ========= #

# Alias for yazi to cd into dir on exit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}