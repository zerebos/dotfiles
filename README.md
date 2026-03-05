# zDotfiles

My personal ZSH dotfiles managed with [yadm](https://yadm.io/). A modern, modular ZSH configuration with curated tools and workflows for Unix/Linux development environments.

## 📸 Screenshots

### Terminal with Powerlevel10k
![Terminal with P10k theme showing prompt, syntax highlighting, and autosuggestions](https://github.com/user-attachments/assets/5d062fda-5a6f-441f-b200-d4db8f3c1615)
*Ghostty terminal with Powerlevel10k theme, fast-syntax-highlighting, and autosuggestions*

### Modern CLI Tools
![Modern CLI tools: eza (ls), bat (cat), and erd (tree) in action](https://github.com/user-attachments/assets/31faf362-ec05-479d-9ef8-76c8747e57fb)
*Replacements for traditional Unix tools with better output and features*

### Yazi File Manager
![Yazi TUI file manager with custom theme and plugins](https://github.com/user-attachments/assets/39383293-e937-47bb-9e48-92f416a52582)
*Full-featured file manager with image previews, git integration, and custom plugins*

### FZF Git Workflow
![Interactive git commit browser using fzf with preview](https://github.com/user-attachments/assets/723fdfa3-1393-4c7e-81a1-bc907c8110de)
*The `fshow` command: fuzzy-find git commits with full diff preview*

### Brewfile Helper Tool
![Brewfile script showing interactive package browser](https://github.com/user-attachments/assets/9dc1e4e9-98f6-417e-b87a-d0e043323d8e)
*Interactive package selection using the `brewfile view` command*

## ✨ Features

- **🚀 Fast Shell Startup** - P10k instant prompt and optimized loading
- **📦 Modular Configuration** - Organized into logical components (lib, aliases, plugins)
- **🎨 Modern CLI Tools** - Replaces traditional Unix tools with modern alternatives
- **🔍 FZF Integration** - Fuzzy finding everywhere (git, files, scripts)
- **🛠️ Developer Workflows** - Specialized commands for Go, Node/Bun, Git
- **🎯 XDG Compliant** - Respects XDG Base Directory standards
- **📱 Multi-Terminal Support** - Configs for Ghostty, Kitty, Alacritty, WezTerm, Rio
- **⚡ Auto-Bootstrap** - One command setup with dependency management

## 📋 What's Included

### Shell Configuration
- **ZSH** with Powerlevel10k theme
- Syntax highlighting via fast-syntax-highlighting
- Auto-suggestions via zsh-autosuggestions
- Smart completion system
- Custom aliases and functions organized by category:
  - Navigation shortcuts
  - Git workflows
  - File operations
  - Development tools
  - Container management
  - System utilities

### Modern CLI Tools
Replacements for traditional Unix commands:
- `eza` → better `ls` with icons and colors
- `bat` → better `cat` with syntax highlighting
- `erd` → better `tree` with better layouts
- `fd` → better `find` with simpler syntax
- `ripgrep` → faster `grep`
- `zoxide` → smarter `cd` with frecency
- `bottom` → better `top` with more features
- `dua-cli`, `gdu`, `diskonaut` → disk usage analyzers

### Development Tools
- **Git**: `gh`, `lazygit`, `git-delta`
- **Editors**: `micro` with custom colorschemes
- **Languages**: Go, Bun/Node.js, Rust, Zig toolchains
- **Utils**: `jq`, `yq`, `hyperfine`, `silicon`, `glow`
- **TUIs**: `yazi` (file manager), `presenterm` (presentations), `fastfetch`

### Applications & Services
- File manager: Yazi with plugins
- Terminal: Multiple configs (Ghostty primary)
- SSH: Wishlist, termscp
- 1Password CLI integration

## 🚀 Quick Start

### Prerequisites
- Git
- ZSH (this configuration is ZSH-specific)
- Internet connection
- Supported OS: macOS or Linux
  - Note: Windows is supported via WSL, but native Windows Terminal config is not included

### Installation

1. **Install YADM**
   ```bash
   # macOS
   brew install yadm

   # Linux (Ubuntu/Debian)
   sudo apt install yadm

   # Linux (Arch)
   sudo pacman -S yadm
   ```

2. **Clone this repo**
   ```bash
   yadm clone https://github.com/zerebos/dotfiles.git
   ```

3. **Run bootstrap**
   ```bash
   yadm bootstrap
   ```

   This will:
   - Install Homebrew (if missing)
   - Install essential tools via Homebrew
   - Set up Yazi plugins
   - Configure locale settings

4. **Install additional tool bundles** (optional)
   ```bash
   # Install multiple brewfiles at once
   brewfile install dev dev-go mac

   # Or browse and install individual packages interactively
   brewfile view dev    # Browse dev tools with fzf
   brewfile search git  # Search for git-related tools

   # See all available brewfiles
   brewfile list
   ```

5. **Set ZSH as default shell** (if not already)
   ```bash
   chsh -s $(which zsh)
   ```

6. **Restart your terminal**

7. **Validate your installation** (optional)
   ```bash
   ./bin/validate-dotfiles
   ```
   
   This helper script checks that:
   - Essential CLI tools are installed
   - Directory structure is correct
   - ZSH configuration is properly loaded
   - Environment variables are set
   - Custom aliases and functions are available
   
   The script is useful for troubleshooting installation issues or verifying your setup after updates.

## 📁 Structure

```
dotfiles/
├── .config/
│   ├── zsh/              # ZSH configuration
│   │   ├── .zshrc        # Main config file
│   │   ├── lib/          # Core libraries
│   │   ├── aliases/      # Categorized aliases
│   │   └── plugins/      # Plugin configurations
│   ├── yadm/             # YADM-specific configs
│   │   ├── bootstrap     # Auto-setup script
│   │   └── brewfiles/    # Homebrew bundles
│   ├── git/              # Git configuration
│   ├── kitty/            # Kitty terminal config
│   ├── ghostty/          # Ghostty terminal config
│   ├── alacritty/        # Alacritty terminal config
│   ├── wezterm/          # WezTerm terminal config
│   ├── yazi/             # Yazi file manager config
│   ├── micro/            # Micro editor config
│   └── ...               # Other app configs
├── bin/                  # Custom scripts
└── .zshenv               # ZSH environment setup
```

## 🎯 Key Aliases & Functions

### Navigation
- `..` - Go up one directory
- `cd` - Aliased to `z` (zoxide) for smart navigation
- `cdg` - Jump to git root
- `cdp` - Jump to project root (git, npm, go, cargo)
- `mkcd <dir>` - Create directory and cd into it
- `zz` - Fuzzy find and jump to frequent directories

### Git
- `gs` - git status
- `ga` - git add
- `gp` - git pull
- `gcm` - git commit -m
- `gpu` - git push
- `glg` - git log graph
- `fshow` - Fuzzy find git commits with preview
- `fstash` - Fuzzy find git stashes with preview

### Files
- `ls` - eza with icons (if available)
- `cat` - bat with syntax highlighting
- `tree` - erd with better layout
- `ll` - long listing
- `lla` - long listing with hidden files

### Development
- `serve [port]` - Start HTTP server (bun or python)
- `curlj <url>` - Get JSON with pretty printing
- `rpkg` - Run package.json script (fuzzy select)
- `lspkg` - List package.json scripts
- `gor [target]` - Run go program
- `gob [target]` - Build go program to ./bin

### System
- `fkill` - Fuzzy find and kill process
- `gdd` - Show disk usage
- `btm` - Display system information
- `listening` - Show open ports

## 🎨 Customization

### Changing the Theme
The Powerlevel10k theme can be reconfigured:
```bash
p10k configure
```

### Adding Your Own Aliases
Create a new file in `.config/zsh/aliases/` with a `.zsh` extension. It will be auto-loaded.

### Adding Custom Brewfiles
Create a custom Brewfile in `.config/yadm/brewfiles/` (e.g., `personal.rb`) and install with:
```bash
brewfile install personal
```

### Terminal Configurations

This repository includes configurations for multiple terminal emulators. These are maintained to test TUI and CLI applications across different terminals for correctness and compatibility.

**Primary Terminal**:
- **macOS/Linux**: [Ghostty](https://ghostty.org/) (or [cmux](https://github.com/manaflow-ai/cmux) which uses Ghostty under the hood)
- **Windows**: Windows Terminal (config not included in dotfiles)

**Additional Terminal Configs** (for testing):
- **Kitty** - Feature-rich, GPU-accelerated, great image protocol support
- **Alacritty** - Minimal, very fast, cross-platform
- **WezTerm** - Lua-configurable, excellent features
- **Rio** - Modern Rust-based terminal

You can install any of these terminals and use their respective configs. The shell configuration works seamlessly across all of them.

## 🧩 Installing Additional Tools

After the base installation, you can install additional tool bundles using the `brewfile` helper script:

```bash
# Install specific brewfiles (e.g., dev tools on macOS)
brewfile install dev mac

# Interactively browse and install individual packages
brewfile view dev    # Browse dev brewfile with fzf
brewfile search git  # Search across all brewfiles for packages matching "git"

# List available brewfiles
brewfile list
```

Available brewfiles:
- `essentials` - Core CLI tools and TUIs (installed by bootstrap)
- `dev` - General development tools (git, gh, lazygit, languages)
- `dev-go` - Go-specific tools and utilities
- `dev-rust` - Rust toolchain and utilities
- `dev-zig` - Zig toolchain
- `dev-extras` - Additional development utilities
- `dev-gui` - GUI development applications
- `containers` - Container tools (Docker, Podman, etc.)
- `mac` - macOS-specific applications
- `vscode` - VS Code extensions via brew

See [`bin/brewfile`](bin/brewfile) for full usage details and implementation.

## 🔧 Maintenance

### Update Dotfiles
```bash
yadm pull
```

### Update Tools
```bash
brew update && brew upgrade
```

### Update Yazi Plugins
```bash
ya pack -u
```

### Validate Your Setup
After updates or if you encounter issues, verify your installation:
```bash
./bin/validate-dotfiles
```

This will check all critical components and help identify any missing tools or configuration issues.

### Commit Changes
```bash
yadm add <file>
yadm commit -m "Description"
yadm push
```

## 💡 Tips

1. **FZF Keybindings**:
   - `Ctrl+R` - Search command history
   - `Ctrl+T` - Search files
   - `Alt+C` - Search directories

2. **Zoxide Navigation**:
   - `z foo` - Jump to directory matching "foo"
   - `zi` - Interactive directory selection

3. **Git Workflows**:
   - Use `fshow` to interactively browse commits
   - Use `fstash` to view stash contents

4. **Performance**:
   - The config is optimized for fast startup
   - Heavy plugins are lazy-loaded
   - Completions are cached

## 🤝 Contributing

Feel free to open issues or submit PRs if you find bugs or have suggestions!

## 📄 License

MIT License - Feel free to use and modify as you wish.

## 🙏 Credits

Built with and inspired by:
- [yadm](https://yadm.io/) - Dotfile manager
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - ZSH theme
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd
- And many other amazing open source tools

---

**Note**: This is a ZSH-specific configuration. While some tools and configs work across shells, the core shell configuration requires ZSH. Review and customize before using.
