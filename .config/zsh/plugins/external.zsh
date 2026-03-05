# Set theming for fzf window
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

# Use fd or rg for fzf file searching if available, with some sensible defaults
if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
elif command -v rg >/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='rg --hidden --glob "!.git" --type directory -l'
fi

# Hook zoxide if installed
(command -v zoxide &> /dev/null) && eval "$(zoxide init zsh)"

# Hook direnv if installed
(command -v direnv &> /dev/null) && eval "$(direnv hook zsh)"

# Enable fzf keybindings and fuzzy completion if fzf is installed
(command -v fzf &> /dev/null) && eval "$(fzf --zsh)"