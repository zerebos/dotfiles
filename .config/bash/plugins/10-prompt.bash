# Prompt.
#
# Powerlevel10k is zsh-only, so there is no way to get a true 1:1 port. The
# closest cross-shell match to the p10k look is Starship (which the fish config
# in this repo already uses), so prefer it when available and fall back to a
# hand-rolled, git-aware two-line prompt otherwise.

[[ $- == *i* ]] || return 0

if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
    return 0
fi

# --- Fallback prompt -------------------------------------------------------
# A tiny git-aware two-line prompt: context on top, prompt symbol below. The
# branch is computed as plain text and coloured directly in PS1, with colours
# wrapped in \[ \] so bash measures the prompt width correctly. (We deliberately
# don't route the branch through __git_ps1 + printf, which would mangle the
# \[ \] non-printing markers.)

__prompt_command() {
    local exit=$?

    local reset='\[\e[0m\]' blue='\[\e[34m\]' green='\[\e[32m\]'
    local red='\[\e[31m\]' magenta='\[\e[35m\]'

    # Exit-status indicator: green symbol on success, red with code on failure
    local status_seg="${green}❯${reset}"
    [[ $exit -ne 0 ]] && status_seg="${red}❯ ${exit}${reset}"

    # Git segment: branch (or short SHA when detached) plus a * when dirty
    local branch dirty="" git_seg=""
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
        git diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty="*"
        git_seg=" ${magenta}⌥ ${branch}${dirty}${reset}"
    fi

    PS1="${blue}\w${reset}${git_seg}\n${status_seg} "
}

PROMPT_COMMAND="__prompt_command${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
