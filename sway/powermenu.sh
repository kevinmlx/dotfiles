#!/bin/bash
choice=$(printf "Bloquear\nCerrar sesion\nSuspender\nReiniciar\nApagar" | wmenu -l 5 -p "Que desea hacer?")

case "$choice" in
    "Bloquear")
        swaylock -f -S --effect-blur 3x3 --clock --indicator --indicator-radius 160 --indicator-thickness 20 --fade-in 0.2 --datestr "%a, %d de %b" --timestr "%H:%M"
        ;;
    "Cerrar sesion")
        swaymsg exit
        ;;
    "Suspender")
        systemctl suspend
        ;;
    "Reiniciar")
        systemctl reboot
        ;;
    "Apagar")
        systemctl poweroff
        ;;
esac
