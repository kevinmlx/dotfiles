#!/bin/bash
# Screenshot script for Sway
# Select region with slurp, then copy to clipboard or save to file

dir="$HOME/Imágenes/screenshots"
mkdir -p "$dir"
file="$dir/$(date '+%Y-%m-%d_%H-%M-%S').png"

choice=$(printf "Copiar al portapapeles\nGuardar como archivo" | wmenu -l 2 -p "Captura:")

if [ -z "$choice" ]; then
    exit 1
fi

case "$choice" in
    "Copiar al portapapeles")
        grim -g "$(slurp)" - | wl-copy
        notify-send "Captura copiada al portapapeles"
        ;;
    "Guardar como archivo")
        grim -g "$(slurp)" "$file"
        notify-send "Captura guardada" "$file"
        ;;
esac
