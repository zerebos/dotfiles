# ============================================================= #
#  Slim zsh base — a friendly starting point for a raw zsh shell #
# ============================================================= #
#
# A small, self-contained slice of a much larger dotfiles setup. It gives you
# the good parts (fuzzy history search, autosuggestions, a git-aware prompt,
# sensible defaults, a handful of aliases) without cloning anything in the
# background or taking over your machine.
#
# Everything here degrades gracefully: if an optional tool isn't installed,
# the related feature is quietly skipped. Run `slimhelp` any time to see what's
# active and what you can install to unlock more.
#
# Install: see this folder's README.md (one line added to your ~/.zshrc).


# --------------------------------------------------------------------------- #
# History — remember more, remember it well
# --------------------------------------------------------------------------- #
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS        # don't store consecutive duplicate commands
setopt HIST_IGNORE_SPACE       # a leading space hides a command from history
setopt HIST_REDUCE_BLANKS      # tidy up whitespace before saving
setopt APPEND_HISTORY          # append on exit instead of overwriting
setopt INC_APPEND_HISTORY      # write commands as you run them (multi-shell)
setopt SHARE_HISTORY           # new shells see history from other open shells


# --------------------------------------------------------------------------- #
# Sensible interactive behaviour
# --------------------------------------------------------------------------- #
setopt AUTO_CD                 # type a directory name to cd into it
setopt INTERACTIVE_COMMENTS    # allow # comments at the prompt


# --------------------------------------------------------------------------- #
# Completion — a navigable, case-insensitive menu
# --------------------------------------------------------------------------- #
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
zstyle ':completion:*' menu select                       # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors ''                    # colourful matches


# --------------------------------------------------------------------------- #
# Keys — history you can actually reach
# --------------------------------------------------------------------------- #
# Type the start of a command, then press Up: you cycle through only the
# history entries that begin with what you typed. This is the zero-install
# cousin of autosuggestions and works everywhere.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# Make Home / End / Delete behave the same everywhere
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char


# --------------------------------------------------------------------------- #
# fzf — the Ctrl-R searchable history menu (and more)
# --------------------------------------------------------------------------- #
# With fzf installed you get:
#   Ctrl-R  fuzzy-search your command history in a live menu
#   Ctrl-T  fuzzy-pick a file path into the current command
#   Alt-C   fuzzy-cd into a subdirectory
if command -v fzf &>/dev/null; then
    _fzf_loaded=0
    if fzf --zsh &>/dev/null; then
        # Modern fzf (>= 0.48): generate the integration inline, no files needed.
        source <(fzf --zsh)
        _fzf_loaded=1
    else
        # Older fzf: source the packaged shell integration if we can find it.
        for _d in "$HOMEBREW_PREFIX/opt/fzf/shell" /usr/local/opt/fzf/shell \
                  /usr/share/fzf /usr/share/fzf/shell /usr/share/doc/fzf/examples \
                  "$HOME/.fzf/shell"; do
            if [[ -r "$_d/key-bindings.zsh" ]]; then
                source "$_d/key-bindings.zsh"
                [[ -r "$_d/completion.zsh" ]] && source "$_d/completion.zsh"
                _fzf_loaded=1
                break
            fi
        done
        unset _d
    fi

    # Ultimate fallback: fzf is installed but its official Ctrl-R integration
    # wasn't found (some minimal distros don't ship it). Wire up a small history
    # widget ourselves so the searchable menu always works.
    if (( ! _fzf_loaded )); then
        fzf-history-slim() {
            local selected
            selected=$(fc -rl 1 | fzf --tac --no-sort --query="$LBUFFER" +m |
                       sed -E 's/^[[:space:]]*[0-9]+\*?[[:space:]]+//')
            [[ -n "$selected" ]] && { BUFFER="$selected"; CURSOR=$#BUFFER; }
            zle reset-prompt
        }
        zle -N fzf-history-slim
        bindkey '^R' fzf-history-slim
    fi
    unset _fzf_loaded
fi


# --------------------------------------------------------------------------- #
# Autosuggestions — the grey "ghost text" from your history
# --------------------------------------------------------------------------- #
# Sourced from a normal package install (brew/apt) if present. Nothing is
# cloned or downloaded here. Install with:
#   brew install zsh-autosuggestions      (macOS)
#   sudo apt install zsh-autosuggestions  (Debian/Ubuntu)
for _p in \
    "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
    if [[ -r "$_p" ]]; then
        source "$_p"
        break
    fi
done
unset _p


# --------------------------------------------------------------------------- #
# zoxide — a smarter cd that learns your habits (optional, `z <partial-name>`)
# --------------------------------------------------------------------------- #
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"


# --------------------------------------------------------------------------- #
# A clean, git-aware prompt (no theme engine required)
# --------------------------------------------------------------------------- #
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:git:*' formats ' %F{magenta}⌥ %b%f'
add-zsh-hook precmd vcs_info
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f${vcs_info_msg_0_}
%(?.%F{green}.%F{red})❯%f '


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

    printf '\033[1mSlim zsh base\033[0m — feature status\n\n'
    printf '  Always on:\n'
    printf '    • Up-arrow prefix history search (type, then press Up)\n'
    printf '    • Case-insensitive completion menu\n'
    printf '    • Git-aware prompt, sensible history, handy aliases\n\n'
    printf '  Optional tools (install to unlock more):\n'
    printf '    %s fzf     Ctrl-R fuzzy history, Ctrl-T files, Alt-C dirs\n' "$(_has fzf)"
    printf '    %s zoxide  '"'"'z <name>'"'"' smart jumping between dirs\n' "$(_has zoxide)"
    printf '    %s eza     prettier '"'"'ls'"'"' with icons\n' "$(_has eza)"
    local _bat=$no
    { command -v bat &>/dev/null || command -v batcat &>/dev/null; } && _bat=$ok
    printf '    %s bat     prettier '"'"'cat'"'"' with syntax highlighting\n' "$_bat"
    local sug=$no _p
    for _p in "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
              /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
              /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
              /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
        [[ -r "$_p" ]] && sug=$ok && break
    done
    printf '    %s zsh-autosuggestions  grey ghost-text suggestions as you type\n\n' "$sug"
    printf '  macOS:  brew install fzf zoxide eza bat zsh-autosuggestions\n'
    printf '  Debian: sudo apt install fzf zoxide eza bat zsh-autosuggestions\n'
    unfunction _has
}
