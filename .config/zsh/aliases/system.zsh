# Get current external ip
alias myip='curl -s https://ifconfig.me || curl -s https://api.ipify.org'

# Run a command with sudo, but if it's an alias or function, run that instead of the raw command
sdo() {
    local firstArg=$1
    if [ $(type -t $firstArg) = function ]
    then
            shift && command sudo bash -c "$(declare -f $firstArg);$firstArg $*"
    elif [ $(type -t $firstArg) = alias ]
    then
            alias sudo='\sudo '
            eval "sudo $@"
    else
            command sudo "$@"
    fi
}

# Use windows desktop 1pass
if command -v op.exe &> /dev/null; then
    alias op=$(command -v op.exe)
fi


# =========== #
# PROCESS OPS #
# =========== #

# Pick a process to kill
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}') || return
    echo "$pid" | xargs -r kill -9
}

# What’s listening (macOS-friendly)
listening() {
    if command -v lsof >/dev/null; then
        sudo lsof -nP -iTCP -sTCP:LISTEN
    else
        ss -ltnp
    fi
}