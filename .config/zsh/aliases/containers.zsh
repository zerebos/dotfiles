# ====== #
# DOCKER #
# ====== #
alias dockerip="docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
alias dc="docker compose"
alias dcd="docker compose down"
alias dcu="docker compose up -d"
alias dcp="docker compose pull"
alias dupdate="dcp && dcd && dcu"