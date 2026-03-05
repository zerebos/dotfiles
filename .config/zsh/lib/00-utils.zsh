# Setup function that compiles zsh script to zsh word binaries
function __zcompile_many() {
    local f
    for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Ensure a variable number of commands exist, printing an error if they don't
#
# Usage: __ensure_commands <cmd> [...]
# Returns: 0 if all commands exist, 1 if any are missing (with error message)
# Example: __ensure_commands git fzf
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


# Get and cache a remote resource to a local file and return the file path,
# re-downloading if it's older than a given age (default 7 days)
#
# Usage: __get_remote_resource <url> [filename] [max_age]
#   url      - URL to download from
#   filename - Optional: Name to save as (defaults to basename of URL)
#   max_age  - Optional: Cache duration like "7d" (defaults to 7 days)
#
# Returns: Prints the path to the cached file
# Example: source "$(__get_remote_resource "https://example.com/script.zsh" "myscript.zsh" "30d")"
__get_remote_resource() {

    # Get the cache directory, preferring $ZSH_CACHE_DIR, then $XDG_CACHE_HOME/zsh, then ~/.cache/zsh
    # The ${VAR:+value} syntax means: if VAR is set and non-empty, use "value", otherwise use nothing
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
