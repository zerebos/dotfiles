# yadm Brewfile essentials to bootstrap a new install

# ============ #
# CLIS & UTILS #
# ============ #

brew "bat"
brew "dua-cli"
brew "erdtree"
brew "eza"
brew "fd"
brew "fzf"
brew "gdu"
brew "git" unless system "command -v git &> /dev/null"
brew "glow"
brew "gping"
brew "jq" # Used in a lot of scripts and aliases
brew "ouch"
brew "ripgrep"
brew "rsync" unless system "command -v rsync &> /dev/null"
brew "zoxide"



# =========== #
# TUIS & APPS #
# =========== #

brew "bottom"
brew "diskonaut"
brew "fastfetch"
brew "presenterm"
brew "superfile"
brew "tlrc"
brew "wtfutil"
brew "yadm"
brew "yazi"
brew "zsh" unless system "command -v zsh &> /dev/null"



# === #
# SSH #
# === #

brew "charmbracelet/tap/wishlist"
brew "veeso/termscp/termscp"
