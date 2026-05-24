#!/bin/bash
# Show keybindings in wmenu for quick reference

config=~/.config/sway/config
entries=()
desc=""

expand_key() {
    local key="$1"
    key="${key//\$mod/Mod}"
    key="${key//\$left/H}"
    key="${key//\$down/J}"
    key="${key//\$up/K}"
    key="${key//\$right/L}"
    echo "$key"
}

while IFS= read -r line; do
    blank="${line//[[:space:]]/}"
    [ -z "$blank" ] && desc="" && continue

    if [[ "$line" =~ ^[[:space:]]*#([^#].*)$ ]]; then
        d="${BASH_REMATCH[1]}"
        desc="${d## }"
        continue
    fi

    if [[ "$line" =~ ^[[:space:]]*bindsym[[:space:]]+(--release[[:space:]]+)?([^ ]+)[[:space:]]+(.*)$ ]]; then
        key=$(expand_key "${BASH_REMATCH[2]}")
        cmd="${BASH_REMATCH[3]}"
        [ -z "$desc" ] && desc="$cmd"
        entries+=("$key | $desc")
        desc=""
        continue
    fi

    desc=""
done < "$config"

[ ${#entries[@]} -eq 0 ] && exit 1

printf '%s\n' "${entries[@]}" | column -t -s '|' | wmenu -l 20 -p "Keybindings:" > /dev/null
