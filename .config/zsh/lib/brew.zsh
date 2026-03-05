# Have homebrew add itself to path if it exists
# Also add the bash completion function to fpath
# This needs to be done before compsys init
# --- Cached brew shellenv (macOS/Linuxbrew) ---
__brew_cache_init() {
    local brew_bin
    if [[ -x /opt/homebrew/bin/brew ]]; then
        brew_bin=/opt/homebrew/bin/brew
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        brew_bin=/home/linuxbrew/.linuxbrew/bin/brew
    else
        return 0
    fi

    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/shellenv"
    local cache_file="$cache_dir/brew_shellenv.zsh"

    mkdir -p -- "$cache_dir"

    # Rebuild cache if missing or brew binary is newer
    if [[ ! -f "$cache_file" || "$brew_bin" -nt "$cache_file" ]]; then
        "$brew_bin" shellenv >| "$cache_file"
    fi

    # Source the cached shellenv (fast)
    source "$cache_file"

    # Ensure zsh completions are on fpath
    local brew_prefix
    brew_prefix="$("$brew_bin" --prefix)"
    fpath=("$brew_prefix/share/zsh/site-functions" $fpath)
}

__brew_cache_init
unset -f __brew_cache_init
