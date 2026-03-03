# Get headers response
alias hh='curl -sI'

# Get a random UUID
alias uuid='bun -e "import { randomUUID } from \"node:crypto\"; console.log(randomUUID())"'

# Serve a local directory temporarily
serve() {
  local port="${1:-8000}"
  local dir="${2:-.}"
  bunx --bun serve --port "$port" --dir "$dir"
}

# Run npm script (requires jq)
rnpm() {
    if ! command -v jq &> /dev/null; then echo "Need jq to run this!"; return 1; fi
    local script
    script=$(cat package.json | jq -r '.scripts | keys[] ' | sort | fzf) && npm run $(echo "$script")
}

# Print every path in $PATH on its own line
path() { print -l -- $path }
pathn() {
    local i
    for i in {1..$#path}; do
        printf '%2d  %s\n' $i "$path[$i]"
    done
}

# emoji picker
emoji() {
    emojis=$(curl -sSL 'https://git.io/JXXO7')
    selected_emoji=$(echo $emojis | fzf)
    echo $selected_emoji
}