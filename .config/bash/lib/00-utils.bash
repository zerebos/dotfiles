# Shared helpers used across the bash config.
# Ported from the zsh lib/00-utils.zsh (minus the zsh-only zcompile helper).

# Ensure a variable number of commands exist, printing an error if they don't
#
# Usage: __ensure_commands <cmd> [...]
# Returns: 0 if all commands exist, 1 if any are missing (with error message)
# Example: __ensure_commands git fzf
__ensure_commands() {
    [[ $# -gt 0 ]] || { echo "Usage: __ensure_commands <cmd> [...]"; return 1; }
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: Command not found: $cmd"
            return 1
        fi
    done
}

# Prepend a directory to $PATH only if it exists and isn't already present.
# This is the bash equivalent of zsh's `path+=(...)` with `typeset -U path`.
#
# Usage: __path_prepend <dir> [...]
__path_prepend() {
    local dir
    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        case ":$PATH:" in
            *":$dir:"*) ;;                 # already present, skip
            *) PATH="$dir:$PATH" ;;
        esac
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
# Example: source "$(__get_remote_resource "https://example.com/script.sh" "myscript.sh" "30d")"
__get_remote_resource() {
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
    [[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"

    local url="$1"
    local filename="${2:-$(basename "$url")}"
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
