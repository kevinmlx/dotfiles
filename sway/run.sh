#!/bin/bash
# Application launcher for Sway
# Lists all available binaries and launches them (respecting Terminal=true in .desktop files)

app=$(ls /usr/bin /usr/local/bin ~/.local/bin 2>/dev/null | sort -u | wmenu -p "Run:")
[ -z "$app" ] && exit 1

desktop=$(find /usr/share/applications ~/.local/share/applications -name "${app}.desktop" 2>/dev/null | head -1)
if [ -n "$desktop" ] && grep -qi "^Terminal=true" "$desktop"; then
    exec kitty -e "$app"
else
    exec "$app"
fi
