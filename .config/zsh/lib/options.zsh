# Make sure zsh share dir exists
if [[ ! -d $XDG_DATA_HOME/zsh ]]; then
    mkdir -p $XDG_DATA_HOME/zsh
fi

# Setup zsh history
export HISTFILE=$XDG_DATA_HOME/zsh/history
export HISTSIZE=10000
export SAVEHIST=10000

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
setopt EXTENDED_GLOB         # advanced globbing like *, **, [], etc.
setopt NO_CLOBBER            # '>' won’t clobber files; use >| to force
setopt PIPE_FAIL             # pipeline fails if any command fails
setopt INTERACTIVE_COMMENTS  # allow comments at prompt


# Setup important keybinds for consistency
bindkey  "^[[H"   beginning-of-line # HOME
bindkey  "^[[F"   end-of-line       # END
bindkey  "^[[3~"  delete-char       # DELETE