# =============== #
# ZerebosSH (ZSH) #
# =============== #

# TODO: consider fzf tab complete https://github.com/Aloxaf/fzf-tab
# and forgit which also uses fzf https://github.com/wfxr/forgit

# 1. Activate Powerlevel10k Instant Prompt.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    # Do this as early as possible to make the prompt instantaneous.
    source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Load core libraries (must come first)
for f in $ZDOTDIR/lib/*.zsh(N); do
    source "$f"
done

# 3. Load plugins
for f in $ZDOTDIR/plugins/*.zsh(N); do
    source "$f"
done

# 4. Load aliases and workflows
for f in $ZDOTDIR/aliases/*.zsh(N); do
    source "$f"
done