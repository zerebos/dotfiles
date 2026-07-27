# Autosuggestions + syntax highlighting for bash.
#
# zsh gets these from zsh-autosuggestions and fast-syntax-highlighting. The
# bash-world equivalent is ble.sh (https://github.com/akinomyoga/ble.sh), which
# provides BOTH inline history autosuggestions and syntax highlighting in one
# package. We source it if it's installed rather than cloning anything.
#
# Install it once with:
#   git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh ~/.local/share/blesh-src
#   make -C ~/.local/share/blesh-src install PREFIX=~/.local
#
# Note: ble.sh must be sourced near the TOP of an interactive rc to attach,
# with a matching `ble-attach` at the very end. The main bashrc handles the
# attach; here we only source the library.

[[ $- == *i* ]] || return 0

for __ble in \
    "$XDG_DATA_HOME/blesh/ble.sh" \
    "$HOME/.local/share/blesh/ble.sh" \
    "$HOMEBREW_PREFIX/share/blesh/ble.sh"; do
    if [[ -r "$__ble" ]]; then
        source "$__ble" --attach=none
        # Style the suggestion to match zsh-autosuggestions' dim grey ghost text.
        declare -F bleopt &>/dev/null && bleopt auto_complete_face='fg=242'
        break
    fi
done
unset __ble
