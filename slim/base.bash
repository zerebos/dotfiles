# ============================================================== #
#  Slim bash base — a friendly starting point for a raw bash shell #
# ============================================================== #
#
# A small, self-contained slice of a much larger dotfiles setup. It gives you
# the good parts (fuzzy history search, a git-aware prompt, sensible defaults,
# a handful of aliases, optional ghost-text suggestions) without cloning
# anything in the background or taking over your machine.
#
# Everything here degrades gracefully: if an optional tool isn't installed,
# the related feature is quietly skipped. Run `slimhelp` any time to see what's
# active and what you can install to unlock more.
#
# Install: see this folder's README.md (one line added to your ~/.bashrc).

# Only do anything for interactive shells.
case $- in *i*) ;; *) return ;; esac


# --------------------------------------------------------------------------- #
# History — remember more, remember it well
# --------------------------------------------------------------------------- #
HISTFILE="${HISTFILE:-$HOME/.bash_history}"
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups   # ignore dupes + leading-space commands
shopt -s histappend                # append instead of overwriting on exit
# Write each command as you run it so new shells see it (multi-shell friendly)
case "$PROMPT_COMMAND" in
    *'history -a'*) ;;
    *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac


# --------------------------------------------------------------------------- #
# Sensible interactive behaviour
# --------------------------------------------------------------------------- #
shopt -s autocd 2>/dev/null        # type a directory name to cd into it
shopt -s cdspell 2>/dev/null       # autocorrect small typos in cd paths
shopt -s checkwinsize              # keep $LINES/$COLUMNS right after a resize
shopt -s globstar 2>/dev/null      # ** matches across directories


# --------------------------------------------------------------------------- #
# Completion + keys — a case-insensitive menu and reachable history
# --------------------------------------------------------------------------- #
# Load bash-completion if present (brew or system paths)
if [[ -n "$HOMEBREW_PREFIX" && -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
    source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
elif [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

bind 'set completion-ignore-case on'   # typing "foo" matches "Foo"/"FOO"
bind 'set show-all-if-ambiguous on'    # one Tab reveals all matches
bind 'set colored-stats on'            # colour completions by file type
bind 'TAB: menu-complete'              # Tab cycles through matches
bind '"\e[Z": menu-complete-backward'  # Shift-Tab cycles backward

# Type the start of a command, then press Up: you cycle through only the
# history entries that begin with what you typed. The zero-install cousin of
# autosuggestions, and it works in every bash.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'


# --------------------------------------------------------------------------- #
# fzf — the Ctrl-R searchable history menu (and more)
# --------------------------------------------------------------------------- #
# With fzf installed you get:
#   Ctrl-R  fuzzy-search your command history in a live menu
#   Ctrl-T  fuzzy-pick a file path into the current command
#   Alt-C   fuzzy-cd into a subdirectory
if command -v fzf &>/dev/null; then
    _fzf_loaded=0
    if fzf --bash &>/dev/null; then
        # Modern fzf (>= 0.48): generate the integration inline, no files needed.
        eval "$(fzf --bash)"
        _fzf_loaded=1
    else
        for _d in "$HOMEBREW_PREFIX/opt/fzf/shell" /usr/local/opt/fzf/shell \
                  /usr/share/fzf /usr/share/fzf/shell /usr/share/doc/fzf/examples \
                  "$HOME/.fzf/shell"; do
            if [[ -r "$_d/key-bindings.bash" ]]; then
                source "$_d/key-bindings.bash"
                [[ -r "$_d/completion.bash" ]] && source "$_d/completion.bash"
                _fzf_loaded=1
                break
            fi
        done
        unset _d
    fi

    # Ultimate fallback: fzf is installed but its official Ctrl-R integration
    # wasn't found (some minimal distros don't ship it). Wire up a small history
    # widget ourselves so the searchable menu always works.
    if [[ $_fzf_loaded -eq 0 ]]; then
        __fzf_history_slim() {
            local line
            line=$(HISTTIMEFORMAT='' history | fzf --tac --no-sort --query="$READLINE_LINE" +m |
                   sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//')
            READLINE_LINE="$line"
            READLINE_POINT=${#READLINE_LINE}
        }
        bind -x '"\C-r": __fzf_history_slim'
    fi
    unset _fzf_loaded
fi


# --------------------------------------------------------------------------- #
# zoxide — a smarter cd that learns your habits (optional, `z <partial-name>`)
# --------------------------------------------------------------------------- #
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"


# --------------------------------------------------------------------------- #
# A clean, git-aware prompt (no theme engine required)
# --------------------------------------------------------------------------- #
__slim_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    printf ' \001\e[35m\002⌥ %s\001\e[0m\002' "$branch"
}

__slim_prompt() {
    local exit=$?
    local reset='\[\e[0m\]' blue='\[\e[34m\]' green='\[\e[32m\]' red='\[\e[31m\]'
    local sym="${green}❯${reset}"
    [[ $exit -ne 0 ]] && sym="${red}❯${reset}"
    PS1="${blue}\w${reset}\$(__slim_git_branch)\n${sym} "
}
# Prepend so we don't clobber the `history -a` set above.
PROMPT_COMMAND="__slim_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"


# --------------------------------------------------------------------------- #
# Autosuggestions + syntax highlighting via ble.sh (optional)
# --------------------------------------------------------------------------- #
# bash's answer to zsh-autosuggestions is ble.sh, which adds BOTH grey ghost
# text AND syntax highlighting. We source it only if you've installed it; we
# never fetch it for you. To set it up once:
#   git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh ~/.local/share/blesh-src
#   make -C ~/.local/share/blesh-src install PREFIX=~/.local
for _ble in "$HOME/.local/share/blesh/ble.sh" \
            "${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh" \
            "$HOMEBREW_PREFIX/share/blesh/ble.sh"; do
    if [[ -r "$_ble" ]]; then
        source "$_ble"
        break
    fi
done
unset _ble


# --------------------------------------------------------------------------- #
# A small, tasteful set of aliases
# --------------------------------------------------------------------------- #
# Navigation
alias ..="cd .."
alias ...="cd ../.."

# Listing — use eza if it's around, otherwise plain ls with colour
if command -v eza &>/dev/null; then
    alias ls="eza --icons --color=always --group-directories-first"
else
    alias ls="ls --color=auto"
fi
alias ll="ls -lh"
alias la="ls -a"
alias lla="ls -lah"

# Nicer cat via bat, if installed (Debian/Ubuntu ship it as `batcat`)
if command -v bat &>/dev/null; then
    alias cat="bat --paging=never --style=plain"
elif command -v batcat &>/dev/null; then
    alias cat="batcat --paging=never --style=plain"
fi

# Colourful grep
alias grep="grep --color=auto"

# Git shortcuts (the ones you'll actually type all day)
alias gs="git status"
alias ga="git add"
alias gp="git pull"
alias gd="git diff"
alias gcm="git commit -m"
alias gpu="git push"
alias glog="git log --oneline"
alias glg="git log --graph --decorate --oneline --all"

# Make a directory and cd into it in one go
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Extract almost any archive by extension: `extract file.tar.gz`
extract() {
    [[ -f "$1" ]] || { echo "No such file: $1"; return 1; }
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.tar.zst)        tar --zstd -xf "$1" ;;
        *.tar)            tar xf  "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip  "$1" ;;
        *.xz)             xz -d   "$1" ;;
        *.zip)            unzip   "$1" ;;
        *.7z)             7z x    "$1" ;;
        *.rar)            unrar x "$1" ;;
        *) echo "Don't know how to extract: $1" ;;
    esac
}

# Show your current public IP
alias myip="curl -s https://ifconfig.me || curl -s https://api.ipify.org"


# --------------------------------------------------------------------------- #
# slimhelp — what's on, and how to unlock the rest
# --------------------------------------------------------------------------- #
slimhelp() {
    local ok=$'\033[32m✓\033[0m' no=$'\033[31m✗\033[0m'
    _has() { command -v "$1" &>/dev/null && printf '%s' "$ok" || printf '%s' "$no"; }

    printf '\033[1mSlim bash base\033[0m — feature status\n\n'
    printf '  Always on:\n'
    printf '    • Up-arrow prefix history search (type, then press Up)\n'
    printf '    • Case-insensitive Tab-completion menu\n'
    printf '    • Git-aware prompt, sensible history, handy aliases\n\n'
    printf '  Optional tools (install to unlock more):\n'
    printf '    %s fzf     Ctrl-R fuzzy history, Ctrl-T files, Alt-C dirs\n' "$(_has fzf)"
    printf '    %s zoxide  '"'"'z <name>'"'"' smart jumping between dirs\n' "$(_has zoxide)"
    printf '    %s eza     prettier '"'"'ls'"'"' with icons\n' "$(_has eza)"
    local _bat=$no
    { command -v bat &>/dev/null || command -v batcat &>/dev/null; } && _bat=$ok
    printf '    %s bat     prettier '"'"'cat'"'"' with syntax highlighting\n' "$_bat"
    local sug=$no
    for _p in "$HOME/.local/share/blesh/ble.sh" \
              "${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh" \
              "$HOMEBREW_PREFIX/share/blesh/ble.sh"; do
        [[ -r "$_p" ]] && sug=$ok && break
    done
    printf '    %s ble.sh  grey ghost-text suggestions + syntax highlighting\n\n' "$sug"
    printf '  macOS:  brew install fzf zoxide eza bat\n'
    printf '  Debian: sudo apt install fzf zoxide eza bat\n'
    printf '  ble.sh: https://github.com/akinomyoga/ble.sh#installation\n'
    unset -f _has
}
