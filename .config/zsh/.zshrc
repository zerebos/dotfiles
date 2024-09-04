if [ -d "/opt/homebrew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d "/home/linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

fpath+=("$(brew --prefix)/share/zsh/site-functions")


# Setup function that compiles zsh script to zsh word binaries
function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}


# Clone and compile to wordcode missing plugins.
if [[ ! -e $ZDOTDIR/fast-syntax-highlighting ]]; then
  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZDOTDIR/fast-syntax-highlighting
  mv -- $ZDOTDIR/fast-syntax-highlighting/{'???chroma','tmp'}
  zcompile-many $ZDOTDIR/fast-syntax-highlighting/{fast*,.fast*,**/*.ch,**/*.zsh}
  mv -- $ZDOTDIR/fast-syntax-highlighting/{'tmp','???chroma'}
fi

if [[ ! -e $ZDOTDIR/zsh-autosuggestions ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZDOTDIR/zsh-autosuggestions
  zcompile-many $ZDOTDIR/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi


# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit
[[ $ZDOTDIR/.zcompdump.zwc -nt $ZDOTDIR/.zcompdump ]] || zcompile-many $ZDOTDIR/.zcompdump
unfunction zcompile-many

ZSH_AUTOSUGGEST_MANUAL_REBIND=1


# Load plugins.
source $ZDOTDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt, run `p10k configure` or edit $ZDOTDIR/p10k.zsh.
[[ ! -f $ZDOTDIR/p10k.zsh ]] || source $ZDOTDIR/p10k.zsh


# Add homebrew commands to the available paths
fpath+=("$(brew --prefix)/share/zsh/site-functions")

# eval "$(starship init zsh)"
eval "$(zoxide init zsh)"


# Load custom aliases from separate file
if [ -f $ZDOTDIR/aliases.zsh ]; then
    . $ZDOTDIR/aliases.zsh
fi

export PATH="$PATH:/Users/zack/bin"
export EDITOR="micro"
export PAGER="bat"
export MICRO_TRUECOLOR=1


bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char


export DISABLE_AUTO_TITLE="false"

function set_terminal_title() {
  echo -en "\e]2;$@\a"
}

# echo -n "\e]1337;CurrentDir=$(pwd)\a"
precmd() {
  if [[ $TERM_PROGRAM == "Tabby" ]]; then
      set_terminal_title "${$(pwd)/\/Users\/zack/~}"
  fi
}
