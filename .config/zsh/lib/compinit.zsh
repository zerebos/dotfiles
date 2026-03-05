# Enable the "new" completion system (compsys).
autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"
[[ "$ZDOTDIR/.zcompdump.zwc" -nt "$ZDOTDIR/.zcompdump" ]] || __zcompile_many "$ZDOTDIR/.zcompdump"

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
