# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [2.1.0] - 2026-03-05

### Added
- Comprehensive public README with:
  - Installation + bootstrap flow
  - Brewfile helper usage (`install`, `view`, `search`, `list`)
  - Real screenshots for terminal, CLI tools, Yazi, Git/FZF, and brewfile workflows
  - Terminal compatibility rationale and platform notes
- `bin/validate-dotfiles` validation helper for post-install verification
- `CHANGELOG.md` (Keep a Changelog format) for release notes tracking
- MIT License

### Changed
- README updated to use `brewfile` helper consistently instead of mixed direct `brew bundle` examples
- Documentation now explicitly positions the repo as ZSH-specific
- `ANALYSIS.md` updated to reflect completed recommendations and current repository state
- Improved inline documentation across shell functions and workflows for clarity/maintainability

### Fixed
- Validation helper no longer exits early due to arithmetic return-code behavior
- Validation helper now sources ZSH config so alias/function checks run in the expected environment

### Removed
- Legacy bash config files (`.bashrc`, `.bash_aliases`, `.profile`) from active setup
- Stale TODO comments from ZSH startup config

## [2.0.0] - 2026-03-04

### Added
- **Brewfile Manager**: New `bin/brewfile` script for interactive package management
  - `brewfile install` - Install multiple brewfiles at once
  - `brewfile view` - Browse packages with fzf
  - `brewfile search` - Search across all brewfiles
  - `brewfile list` - List available brewfiles
- Categorized Brewfiles for modular installation
  - Split into: essentials, dev, dev-go, dev-rust, dev-zig, dev-extras, dev-gui, containers, mac, vscode

### Changed
- **Major ZSH refactor**: Moved from monolithic config to modular structure
  - Split aliases into categories: files, navigation, git, devtools, system, containers
  - Organized into `lib/`, `aliases/`, and `plugins/` directories
  - Improved loading order and performance
- Updated alias commands to check for tool availability before use
- Moved to more generic, portable zshrc

### Removed
- Legacy bash configuration files (.bashrc, .bash_aliases, .profile)
- TODO comments from zshrc

## [1.x] - Historical

### 2025-10 to 2026-03
- Added new git aliases and shortcuts
- Updated Ghostty terminal configuration
- Updated various tool configurations
- Maintained Brewfile with latest tools

### 2024-10 to 2024-11
- Updated several application configs
- Expanded Brewfile package list
- General configuration updates

### 2024-01
- Fixed bootstrap script
- Separated yadm-specific git configuration
- Added comprehensive gitignore/gitconfig
- Adjusted CLI tools and expanded aliases

---

## Maintenance Notes

Going forward, document changes under `[Unreleased]` and move them to a dated version when you make significant updates. Consider version bumps:

- **Major (X.0.0)**: Breaking changes, major restructuring
- **Minor (x.X.0)**: New features, new tools, significant config additions
- **Patch (x.x.X)**: Bug fixes, small tweaks, minor config updates

Or keep it simple and just use dated entries without version numbers. Your choice!
