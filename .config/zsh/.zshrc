# ================= #
# Essential Plugins #
# ================= #

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
if [[ -d "/opt/homebrew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  fpath+="/opt/homebrew/share/zsh/site-functions"
fi

if [[ -d "/home/linuxbrew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fpath+="/home/linuxbrew/.linuxbrew/share/zsh/site-functions"
fi




# ========= #
# ZSH SETUP #
# ========= #

# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit
[[ $ZDOTDIR/.zcompdump.zwc -nt $ZDOTDIR/.zcompdump ]] || zcompile-many $ZDOTDIR/.zcompdump
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

# Setup important keybinds for consistency
bindkey  "^[[H"   beginning-of-line # HOME
bindkey  "^[[F"   end-of-line       # END
bindkey  "^[[3~"  delete-char       # DELETE

# Add important paths to $PATH
[[ ":$PATH:" == *":$HOME/bin:"* ]] || export PATH=$PATH:~/bin
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH=$PATH:~/.local/bin

# Setup some env vars
if command -v flow &> /dev/null; then
  export EDITOR="flow"
elif command -v micro &> /dev/null; then
  export EDITOR="micro"
fi
export MICRO_TRUECOLOR=1          # force truecolor for micro
export DIRENV_LOG_FORMAT=''       # silence direnv output
export DISABLE_AUTO_TITLE="false" # Ensure autotitle is enabled




# ============== #
# CMDS & ALIASES #
# ============== #

# Allow certain commands to add their hooks
(command -v zoxide &> /dev/null) && eval "$(zoxide init zsh)"
(command -v direnv &> /dev/null) && eval "$(direnv hook zsh)"  
(command -v fzf &> /dev/null) && eval "$(fzf --zsh)"  

# Load custom aliases from separate file
if [ -f $ZDOTDIR/aliases.zsh ]; then
    . $ZDOTDIR/aliases.zsh
fi




# ========= #
# TERMINALS #
# ========= #
if [[ $TERM_PROGRAM == "Tabby" ]]; then
  function set_terminal_title() {
    echo -en "\e]2;$@\a"
  }

  # echo -n "\e]1337;CurrentDir=$(pwd)\a"
  precmd() {
    set_terminal_title "${$(pwd)/\/Users\/zack/~}"
  }
fi
