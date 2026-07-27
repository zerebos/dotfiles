#!/usr/bin/env sh
# Slim base installer.
#
# Adds a single guarded `source` line to your shell rc so the slim base loads
# in new shells. It does NOT overwrite your rc, install packages, or clone
# anything — it just wires up the file that already sits next to this script.
#
# Usage:
#   ./install.sh            # auto-detect your shell from $SHELL
#   ./install.sh bash       # force the bash base
#   ./install.sh zsh        # force the zsh base
#
# Re-running is safe: it detects an existing install and won't add a duplicate.

set -eu

# Resolve the directory this script lives in (so the source line uses an
# absolute path and keeps working no matter where you run it from).
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

MARKER="# >>> slim base >>>"
ENDMARKER="# <<< slim base <<<"

# --- Pick the shell --------------------------------------------------------
shell="${1:-}"
if [ -z "$shell" ]; then
    case "${SHELL:-}" in
        *zsh)  shell=zsh ;;
        *bash) shell=bash ;;
        *)
            printf 'Could not detect your shell from $SHELL (%s).\n' "${SHELL:-unset}"
            printf 'Re-run as: ./install.sh bash   or   ./install.sh zsh\n'
            exit 1
            ;;
    esac
fi

case "$shell" in
    bash) rc="$HOME/.bashrc"; base="$SCRIPT_DIR/base.bash" ;;
    zsh)  rc="$HOME/.zshrc";  base="$SCRIPT_DIR/base.zsh" ;;
    *)    printf 'Unknown shell: %s (expected bash or zsh)\n' "$shell"; exit 1 ;;
esac

if [ ! -r "$base" ]; then
    printf 'Cannot find %s next to this script.\n' "$base"
    exit 1
fi

# --- Wire it up ------------------------------------------------------------
touch "$rc"
if grep -qF "$MARKER" "$rc" 2>/dev/null; then
    printf 'Slim base is already installed in %s — nothing to do.\n' "$rc"
else
    {
        printf '\n%s\n' "$MARKER"
        printf '[ -r "%s" ] && . "%s"\n' "$base" "$base"
        printf '%s\n' "$ENDMARKER"
    } >> "$rc"
    printf 'Added the slim base to %s\n' "$rc"
fi

# On macOS, Terminal.app starts login shells, which read .bash_profile but not
# .bashrc. Make sure .bash_profile pulls in .bashrc so the base actually loads.
if [ "$shell" = bash ]; then
    profile="$HOME/.bash_profile"
    if [ ! -f "$profile" ] || ! grep -q 'bashrc' "$profile" 2>/dev/null; then
        {
            printf '\n%s\n' "$MARKER"
            printf '[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"\n'
            printf '%s\n' "$ENDMARKER"
        } >> "$profile"
        printf 'Ensured %s sources ~/.bashrc (needed for macOS login shells)\n' "$profile"
    fi
fi

printf '\nDone! Open a new terminal, or run:  exec %s\n' "$shell"
printf 'Then run  slimhelp  to see what is active and what to install next.\n'
