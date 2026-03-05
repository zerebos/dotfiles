# Clone and compile zsh-autosuggestions plugin
if [[ ! -e $XDG_CACHE_HOME/zsh-autosuggestions ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $XDG_CACHE_HOME/zsh-autosuggestions
    __zcompile_many $XDG_CACHE_HOME/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi

# Load zsh-autosuggestions plugin
source $XDG_CACHE_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh