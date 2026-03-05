# Clone and compile fast-syntax-highlighting
if [[ ! -e $XDG_CACHE_HOME/fast-syntax-highlighting ]]; then
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git $XDG_CACHE_HOME/fast-syntax-highlighting
    mv -- $XDG_CACHE_HOME/fast-syntax-highlighting/{'???chroma','tmp'}
    __zcompile_many $XDG_CACHE_HOME/fast-syntax-highlighting/{fast*,.fast*,**/*.ch,**/*.zsh}
    mv -- $XDG_CACHE_HOME/fast-syntax-highlighting/{'tmp','???chroma'}
fi

# Load fast-syntax-highlighting plugin
source $XDG_CACHE_HOME/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh