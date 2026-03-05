# Enable the "new" completion system (compsys).
autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"

# Compile the completion dump for faster loading
# Only recompile if the .zwc (compiled) file is older than the source file
[[ "$ZDOTDIR/.zcompdump.zwc" -nt "$ZDOTDIR/.zcompdump" ]] || __zcompile_many "$ZDOTDIR/.zcompdump"

# Show a navigable selection menu when there are multiple matches
zstyle ':completion:*' menu select

# Group matches by category (files, commands, options)
zstyle ':completion:*' group-name ''

# Pretty description header for each group
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# Fuzzy-ish matching for completions:
# 1. 'm:{a-z}={A-Za-z}' - Makes matching case-insensitive
#    Example: typing "foo" matches "Foo" or "FOO"
# 2. 'r:|[._-]=* r:|=*' - Treats . _ - as word separators for partial matching
#    Example: typing "gco" can match "git-checkout" or "git_checkout"
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'

# Apply terminal/LS_COLORS to completion lists
(( ${+LS_COLORS} )) && zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
