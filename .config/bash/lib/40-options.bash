# Shell options, history, and keybindings.
# Ported from lib/options.zsh using bash's shopt / set / HISTCONTROL.

# --- History ---------------------------------------------------------------
[[ -d "$XDG_DATA_HOME/bash" ]] || mkdir -p "$XDG_DATA_HOME/bash"
export HISTFILE="$XDG_DATA_HOME/bash/history"
export HISTSIZE=10000          # entries kept in memory
export HISTFILESIZE=10000      # entries kept on disk (zsh SAVEHIST equivalent)

# ignoreboth = ignorespace (leading-space commands not stored) + ignoredups
# erasedups  = drop older duplicates of the current command
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%F %T '  # timestamp history entries

shopt -s histappend            # append instead of overwriting on exit
shopt -s cmdhist               # keep multi-line commands as one entry
shopt -s lithist               # ...preserving embedded newlines

# Write each command to the history file immediately so new shells see it
# (bash equivalent of zsh's INC_APPEND_HISTORY). Prepended so it doesn't
# clobber any PROMPT_COMMAND set earlier (e.g. the Tabby title hook).
case "$PROMPT_COMMAND" in
    *'history -a'*) ;;
    *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

# --- Behaviour (bash analogues of the zsh setopts) -------------------------
shopt -s autocd 2>/dev/null    # 'foo' becomes 'cd foo' if it's a directory
shopt -s cdspell               # autocorrect minor typos in `cd` paths (~CORRECT)
shopt -s dirspell 2>/dev/null
shopt -s extglob               # advanced globbing: !(), @(), +(), etc.
shopt -s globstar              # ** matches across directories (EXTENDED_GLOB)
shopt -s nocaseglob            # case-insensitive globbing
shopt -s checkwinsize          # keep $LINES/$COLUMNS correct after resize
set -o noclobber               # '>' won't clobber files; use >| to force
set -o pipefail                # a pipeline fails if any stage fails
# (INTERACTIVE_COMMENTS is on by default for interactive bash.)

# --- Keybindings -----------------------------------------------------------
if [[ $- == *i* ]]; then
    # Prefix history search: type part of a command, then Up/Down walks through
    # only the matching history entries. This is the zero-dependency cousin of
    # autosuggestions and works in every bash.
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind '"\eOA": history-search-backward'   # some terminals send SS3
    bind '"\eOB": history-search-forward'

    # Consistent Home / End / Delete (mirrors options.zsh)
    bind '"\e[H": beginning-of-line'
    bind '"\e[F": end-of-line'
    bind '"\e[3~": delete-char'
fi
