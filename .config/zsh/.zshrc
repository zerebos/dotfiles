# ================= #
# Essential Plugins #
# ================= #

# TODO: consider fzf tab complete https://github.com/Aloxaf/fzf-tab
# and forgit which also uses fzf https://github.com/wfxr/forgit

# Activate Powerlevel10k Instant Prompt.
# Do this as early as possible to make the prompt instantaneous.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Setup function that compiles zsh script to zsh word binaries
function zcompile-many() {
    local f
    for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Clone essential zsh plugins and compile to word code
if [[ ! -e $XDG_CACHE_HOME/fast-syntax-highlighting ]]; then
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git $XDG_CACHE_HOME/fast-syntax-highlighting
    mv -- $XDG_CACHE_HOME/fast-syntax-highlighting/{'???chroma','tmp'}
    zcompile-many $XDG_CACHE_HOME/fast-syntax-highlighting/{fast*,.fast*,**/*.ch,**/*.zsh}
    mv -- $XDG_CACHE_HOME/fast-syntax-highlighting/{'tmp','???chroma'}
fi

if [[ ! -e $XDG_CACHE_HOME/zsh-autosuggestions ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $XDG_CACHE_HOME/zsh-autosuggestions
    zcompile-many $XDG_CACHE_HOME/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi

if [[ ! -e $XDG_CACHE_HOME/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $XDG_CACHE_HOME/powerlevel10k
    zcompile-many $XDG_CACHE_HOME/powerlevel10k/**/*.zsh
fi

# Load zsh plugins.
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1 # Disable auto rebind for autosuggestion widgets (performance++)
source $XDG_CACHE_HOME/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $XDG_CACHE_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh
source $XDG_CACHE_HOME/powerlevel10k/powerlevel10k.zsh-theme

# Load powerlevel10k config, run `p10k configure` or edit $ZDOTDIR/p10k.zsh to change
[[ ! -f $ZDOTDIR/p10k.zsh ]] || source $ZDOTDIR/p10k.zsh




# ======== #
# Homebrew #
# ======== #

# Have homebrew add itself to path if it exists
# Also add the bash completion function to fpath
# This needs to be done before compsys init
# --- Cached brew shellenv (macOS/Linuxbrew) ---
brew_cache_init() {
    local brew_bin
    if [[ -x /opt/homebrew/bin/brew ]]; then
        brew_bin=/opt/homebrew/bin/brew
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        brew_bin=/home/linuxbrew/.linuxbrew/bin/brew
    else
        return 0
    fi

    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/shellenv"
    local cache_file="$cache_dir/brew_shellenv.zsh"

    mkdir -p -- "$cache_dir"

    # Rebuild cache if missing or brew binary is newer
    if [[ ! -f "$cache_file" || "$brew_bin" -nt "$cache_file" ]]; then
        "$brew_bin" shellenv >| "$cache_file"
    fi

    # Source the cached shellenv (fast)
    source "$cache_file"

    # Ensure zsh completions are on fpath
    local brew_prefix
    brew_prefix="$("$brew_bin" --prefix)"
    fpath=("$brew_prefix/share/zsh/site-functions" $fpath)
}

brew_cache_init
unset -f brew_cache_init




# ========= #
# ZSH SETUP #
# ========= #

# Run once if you changed plugins/permissions:
# compaudit | xargs -r chmod g-w
# compinit -d "$ZDOTDIR/.zcompdump"

# Enable the "new" completion system (compsys).
autoload -Uz compinit
compinit -C -d "$ZDOTDIR/.zcompdump"
[[ "$ZDOTDIR/.zcompdump.zwc" -nt "$ZDOTDIR/.zcompdump" ]] || zcompile-many "$ZDOTDIR/.zcompdump"
unfunction zcompile-many

# Make sure zsh share dir exists
if [[ ! -d $XDG_DATA_HOME/zsh ]]; then
    mkdir -p $XDG_DATA_HOME/zsh
fi

# Setup zsh history
export HISTFILE=$XDG_DATA_HOME/zsh/history
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY

# History config
setopt HIST_IGNORE_DUPS        # don’t store duplicate consecutive entries
setopt HIST_FIND_NO_DUPS       # don’t find duplicates when searching
setopt HIST_IGNORE_SPACE       # commands starting with space are not stored
setopt HIST_REDUCE_BLANKS      # strip superfluous blanks
setopt HIST_EXPIRE_DUPS_FIRST  # expire duplicates first when trimming
setopt APPEND_HISTORY          # append (don’t overwrite) on shell exit
setopt INC_APPEND_HISTORY      # write incrementally (multi-session friendly)
#setopt SHARE_HISTORY          # share history between sessions (can't be used with HISTFILE=0)

# Non-history config
setopt AUTO_CD               # 'foo' becomes 'cd foo' if directory
setopt CORRECT               # spelling correction for commands
#setopt CORRECT_ALL=false    # use this if I get annoyed with correcting arguments
setopt EXTENDED_GLOB         # advanced globbing
setopt NO_CLOBBER            # '>' won’t clobber files; use >| to force
setopt PIPE_FAIL             # pipeline fails if any command fails
setopt INTERACTIVE_COMMENTS  # allow comments at prompt

# Setup important keybinds for consistency
bindkey  "^[[H"   beginning-of-line # HOME
bindkey  "^[[F"   end-of-line       # END
bindkey  "^[[3~"  delete-char       # DELETE

# Show a navigable selection menu when there are multiple matches
zstyle ':completion:*' menu select

# Group matches by category (files, commands, options)
zstyle ':completion:*' group-name ''

# Pretty description header for each group
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# Fuzzy-ish matching: case-insensitive for letters; treat . _ - as separators
# So typing `gco` can match `git-checkout`; `Foo` matches `foo`
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'

# Apply terminal/LS_COLORS to completion lists
(( ${+LS_COLORS} )) && zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}



# ========= #
# PATHS/ENV #
# ========= #

# Add important paths to $PATH/path the zsh way
path+=( "$HOME/bin" "$HOME/.local/bin" "$HOME/go/bin" )
typeset -U path # Enforce uniqueness
#export PATH="${path[*]}" # technicially not neeeded

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



# ============== #
# CMDS & ALIASES #
# ============== #

# Allow certain commands to add their hooks
(command -v zoxide &> /dev/null) && eval "$(zoxide init zsh)"
(command -v direnv &> /dev/null) && eval "$(direnv hook zsh)"
(command -v fzf &> /dev/null) && eval "$(fzf --zsh)"

# Now legacy
# Load custom aliases from separate file
if [ -f $ZDOTDIR/aliases.zsh ]; then
    . $ZDOTDIR/aliases.zsh
fi

if [ -f $ZDOTDIR/aliases.local.zsh ]; then
    . $ZDOTDIR/aliases.local.zsh
fi

# My new approach: source all .zsh files in the aliases dir
# It's more modular and less error prone than one giant file
for f in $ZDOTDIR/aliases/*.zsh(N); do
    source "$f"
done





# ========= #
# TERMINALS #
# ========= #
if [[ $TERM_PROGRAM == "Tabby" ]]; then
    set_terminal_title() { echo -en "\e]2;$*\a"; }
    tabby_precmd() { set_terminal_title "${${PWD/#$HOME/~}}"; }
    autoload -Uz add-zsh-hook && add-zsh-hook precmd tabby_precmd
fi
