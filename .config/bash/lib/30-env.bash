# Environment variables and $PATH setup.
# Ported from .zshenv + lib/env.zsh. Bash has no .zshenv equivalent that is
# guaranteed to run for interactive shells, so the XDG vars live here too.

# XDG base directories (normally set by .zshenv for zsh)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Alias python -> python3 if only python3 exists (mirrors .zshenv)
if command -v python3 &>/dev/null && ! command -v python &>/dev/null; then
    alias python="python3"
fi

# Add important paths to $PATH (dedup + existence checked by the helper).
# Prepend in reverse of desired priority so $HOME/bin ends up first.
__path_prepend "$HOME/go/bin" "$HOME/.local/bin" "$HOME/bin"
export PATH

# Preferred editor: flow (flow-control) > micro > nano
if command -v flow &>/dev/null; then
    export EDITOR="flow"
elif command -v micro &>/dev/null; then
    export EDITOR="micro"
fi

export MICRO_TRUECOLOR=1          # force truecolor for micro
export DIRENV_LOG_FORMAT=''       # silence direnv output
export DISABLE_AUTO_TITLE="false" # ensure autotitle is enabled
export DELTA_PAGER="less --mouse" # force mouse support in delta

# Make the terminal title show the current directory when using Tabby terminal
# (bash port of the zsh precmd hook via PROMPT_COMMAND).
if [[ "$TERM_PROGRAM" == "Tabby" ]]; then
    __tabby_title() { printf '\e]2;%s\a' "${PWD/#$HOME/~}"; }
    case "$PROMPT_COMMAND" in
        *__tabby_title*) ;;
        *) PROMPT_COMMAND="__tabby_title${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
    esac
fi
