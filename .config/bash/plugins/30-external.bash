# External tool integrations: fzf, zoxide, direnv.
# Ported from plugins/external.zsh — these tools are all shell-agnostic.

# Set theming for the fzf window (identical to the zsh config)
export FZF_DEFAULT_OPTS='
    --color=preview-fg:-1,preview-bg:-1
    --color=fg:-1,fg+:#f8f8f8,bg:-1,bg+:#383838
    --color=hl:red,hl+:red,info:green,marker:blue
    --color=prompt:blue,spinner:magenta,pointer:blue
    --color=border:#383838,separator:green
    --scrollbar="█"
    --pointer="█"
    --marker="►"
    --prompt="↪ "
    --border="rounded"
    --preview-window="border-rounded"'

# Use fd or rg for fzf file searching if available, with sensible defaults
if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
elif command -v rg >/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Enable fzf keybindings (Ctrl-R history, Ctrl-T files, Alt-C cd) and completion.
# Modern fzf ships `fzf --bash`; fall back to the packaged shell scripts for
# older versions.
if command -v fzf &>/dev/null; then
    __fzf_loaded=0
    if fzf --bash &>/dev/null; then
        eval "$(fzf --bash)"
        __fzf_loaded=1
    else
        for __d in "$HOMEBREW_PREFIX/opt/fzf/shell" /usr/local/opt/fzf/shell \
                   /usr/share/fzf /usr/share/fzf/shell /usr/share/doc/fzf/examples \
                   "$HOME/.fzf/shell"; do
            if [[ -r "$__d/key-bindings.bash" ]]; then
                source "$__d/key-bindings.bash"
                [[ -r "$__d/completion.bash" ]] && source "$__d/completion.bash"
                __fzf_loaded=1
                break
            fi
        done
        unset __d
    fi

    # Fallback for minimal machines that ship fzf without its shell integration:
    # a small Ctrl-R history menu so the searchable history always works.
    if [[ $__fzf_loaded -eq 0 && $- == *i* ]]; then
        __fzf_history_widget() {
            local line
            line=$(HISTTIMEFORMAT='' history | fzf --tac --no-sort --query="$READLINE_LINE" +m |
                   sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//')
            READLINE_LINE="$line"
            READLINE_POINT=${#READLINE_LINE}
        }
        bind -x '"\C-r": __fzf_history_widget'
    fi
    unset __fzf_loaded
fi

# Hook zoxide if installed (provides `z` / `zi`)
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

# Hook direnv if installed
command -v direnv &>/dev/null && eval "$(direnv hook bash)"
