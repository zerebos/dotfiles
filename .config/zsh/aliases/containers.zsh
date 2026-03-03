# ====== #
# DOCKER #
# ====== #
alias dockerip="docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}'"
alias dc="docker compose"
alias dcd="docker compose down"
alias dcu="docker compose up -d"
alias dcp="docker compose pull"
alias dcl="docker compose logs -f"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dupdate="dcp && dcd && dcu"


# ====== #
# PODMAN #
# ====== #
alias pc="podman compose"
alias pcu="podman compose up -d"
alias pcd="podman compose down"
alias pcp="podman compose pull"
alias pupdate="pcp && pcd && pcu"
