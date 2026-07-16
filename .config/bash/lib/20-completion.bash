# Completion setup for bash.
#
# zsh's compsys (compinit + zstyle) has no direct bash equivalent, so this
# approximates the important behaviours from lib/compinit.zsh using the
# bash-completion package plus readline settings:
#   - case-insensitive matching
#   - a navigable menu you can Tab through
#   - coloured completion lists

# Load bash-completion if it's installed (brew or system paths).
if ! shopt -oq posix; then
    if [[ -n "$HOMEBREW_PREFIX" && -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
        source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
    elif [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# Readline behaviour (equivalent-ish to zsh's menu select + case-insensitive
# matcher-list). `bind` only makes sense in an interactive shell.
if [[ $- == *i* ]]; then
    bind 'set completion-ignore-case on'      # typing "foo" matches "Foo"/"FOO"
    bind 'set completion-map-case on'         # treat - and _ as interchangeable
    bind 'set show-all-if-ambiguous on'       # one Tab shows all matches
    bind 'set show-all-if-unmodified on'
    bind 'set menu-complete-display-prefix on'
    bind 'set colored-stats on'               # colour matches by file type
    bind 'set colored-completion-prefix on'
    bind 'set mark-symlinked-directories on'

    # Tab / Shift-Tab cycle through matches like zsh's `menu select`.
    bind 'TAB: menu-complete'
    bind '"\e[Z": menu-complete-backward'
fi
