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