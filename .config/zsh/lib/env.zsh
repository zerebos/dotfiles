# Add paths to $PATH before setting up environment vars
# so important binaries are discoverable via `command`.

# Add important paths to $PATH/path the zsh way
path+=( "$HOME/bin" "$HOME/.local/bin" "$HOME/go/bin" )
typeset -U path # Enforce uniqueness

# Setup some env vars
if command -v flow &> /dev/null; then
    export EDITOR="flow"
elif command -v micro &> /dev/null; then
    export EDITOR="micro"
fi
export MICRO_TRUECOLOR=1          # force truecolor for micro
export DIRENV_LOG_FORMAT=''       # silence direnv output
export DISABLE_AUTO_TITLE="false" # Ensure autotitle is enabled
export DELTA_PAGER="less --mouse" # Force mouse support in delta

# Disable auto rebind for autosuggestion widgets (performance++)
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1


# Make the terminal title show the current directory when using Tabby terminal
if [[ $TERM_PROGRAM == "Tabby" ]]; then
    set_terminal_title() { echo -en "\e]2;$*\a"; }
    tabby_precmd() { set_terminal_title "${${PWD/#$HOME/~}}"; }
    autoload -Uz add-zsh-hook && add-zsh-hook precmd tabby_precmd
fi