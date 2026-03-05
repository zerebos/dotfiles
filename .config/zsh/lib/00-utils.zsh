# Setup function that compiles zsh script to zsh word binaries
function __zcompile_many() {
    local f
    for f; do zcompile -R -- "$f".zwc "$f"; done
}

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
