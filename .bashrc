# Entry point for interactive bash shells.
# The real configuration lives in $XDG_CONFIG_HOME/bash to mirror the zsh setup
# (which keeps everything under $ZDOTDIR). See .config/bash/ for the modules.

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
    *) return ;;
esac

BASH_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
[[ -r "$BASH_CONF_DIR/bashrc" ]] && source "$BASH_CONF_DIR/bashrc"
