# Login shells (notably macOS Terminal.app, which starts every tab as a login
# shell) read .bash_profile but NOT .bashrc. Source .bashrc here so interactive
# login shells get the same configuration.
[[ -r ~/.bashrc ]] && source ~/.bashrc
