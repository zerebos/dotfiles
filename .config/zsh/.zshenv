# ZSH Specific envs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export LC_ALL=en_US.UTF-8

# Alias python to python3 if it exists.
# This is in zshenv rather than zshrc due to scripts/shebangs out of my control on read-only systems
if command -v python3 &> /dev/null; then
    alias python="python3"
fi