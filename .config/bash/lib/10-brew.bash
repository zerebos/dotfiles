# Have homebrew add itself to path if it exists, using a cached shellenv so we
# don't pay the cost of running `brew shellenv` on every shell startup.
# Ported from lib/brew.zsh (the fpath bit is zsh-only and dropped here; bash
# completions are wired up separately in 20-completion.bash).
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
    local cache_file="$cache_dir/brew_shellenv.bash"

    mkdir -p -- "$cache_dir"

    # Rebuild cache if missing or brew binary is newer.
    # `brew shellenv` output is plain `export` lines, so it works in bash as-is.
    if [[ ! -f "$cache_file" || "$brew_bin" -nt "$cache_file" ]]; then
        "$brew_bin" shellenv >| "$cache_file"
    fi

    source "$cache_file"
}

__brew_cache_init
unset -f __brew_cache_init
