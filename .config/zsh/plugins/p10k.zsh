# Clone and compile powerlevel10k theme
if [[ ! -e $XDG_CACHE_HOME/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $XDG_CACHE_HOME/powerlevel10k
    __zcompile_many $XDG_CACHE_HOME/powerlevel10k/**/*.zsh
fi

# Load powerlevel10k theme
source $XDG_CACHE_HOME/powerlevel10k/powerlevel10k.zsh-theme

# Load powerlevel10k config, run `p10k configure` or edit $ZDOTDIR/p10k.zsh to change
[[ ! -f $ZDOTDIR/p10k.zsh ]] || source $ZDOTDIR/p10k.zsh