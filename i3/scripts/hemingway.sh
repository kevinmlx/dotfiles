#!/bin/bash

# Archivo temporal para guardar el estado del Backspace
STATE_FILE="/tmp/hemingway_mode"

if [ ! -f "$STATE_FILE" ]; then
    # SI NO EXISTE EL ARCHIVO: Desactivamos el Backspace
    xmodmap -e "keycode 22 = NoSymbol"
    touch "$STATE_FILE"
    notify-send "MODO HEMINGWAY: ACTIVADO" "El fracaso no es una opción (ni el Backspace)." -i face-frown-symbolic
else
    # SI EXISTE EL ARCHIVO: Reactivamos el Backspace
    xmodmap -e "keycode 22 = BackSpace"
    rm "$STATE_FILE"
    notify-send "MODO HEMINGWAY: DESACTIVADO" "Ya puedes volver a borrar tus errores." -i face-smiling-symbolic
fi
