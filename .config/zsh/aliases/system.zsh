# ========== #
# NETWORKING #
# ========== #

# HTTP load testing with wrk (requires wrk)
alias wrk="wrk -t4 -c50 -d10s"

# Get current external ip
alias myip="curl -s https://ifconfig.me || curl -s https://api.ipify.org"

# What’s listening (macOS-friendly)
listening() {
    if command -v lsof >/dev/null; then
        sudo lsof -nP -iTCP -sTCP:LISTEN
    else
        ss -tulpn
    fi
}

# Default to gping if available, otherwise fallback to ping
ping() {
    if command -v gping &> /dev/null; then
        gping "$@"
    else
        command ping "$@"
    fi
}



# =========== #
# PROCESS OPS #
# =========== #

# Pick a process to kill
fkill() {
    __ensure_commands fzf || return
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}') || return
    echo "$pid" | xargs -r kill
}


# =========== #
# SYSTEM INFO #
# =========== #

alias mem="ps aux --sort=-%mem | head"
alias cpu="ps aux --sort=-%cpu | head"



# ========= #
# DISK & FS #
# ========= #

alias dfh="df -h"
alias watchls="watch -n 1 ls -l"
alias watchps="watch -n 1 'ps aux | head'"
alias gdd="gdu-go --show-disks"
alias dua="dua interactive"
alias dn="diskonaut"



# ==== #
# MISC #
# ==== #

# Run a command with sudo, but if it's an alias or function, run that instead of the raw command
sdo() {
    local cmd="$1"
    shift

    case "$(type -t "$cmd")" in
        function)
            sudo zsh -c "$(printf '%s\n' "$(declare -f "$cmd")"; printf '%s "$@"\n' "$cmd")" zsh "$@"
            ;;
        alias)
            sudo zsh -ic "$cmd $*"
            ;;
        *)
            sudo "$cmd" "$@"
            ;;
    esac
}

# Use windows desktop 1password-cli if available
if command -v op.exe &> /dev/null; then
    alias op=$(command -v op.exe)
fi
