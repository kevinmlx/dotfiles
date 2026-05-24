#!/bin/bash
# Toggle keyboard layout between US English and Latin American Spanish

current=$(swaymsg -t get_inputs | jq -r '.[] | select(.type=="keyboard") | .xkb_active_layout_name' | head -1)
if echo "$current" | grep -qi "latam\|spanish\|espanol\|latin"; then
    swaymsg input type:keyboard xkb_layout us
else
    swaymsg input type:keyboard xkb_layout latam
fi
sleep 0.2
new_layout=$(swaymsg -t get_inputs | jq -r '.[] | select(.type=="keyboard") | .xkb_active_layout_name' | head -1)
notify-send "Teclado: $new_layout"
