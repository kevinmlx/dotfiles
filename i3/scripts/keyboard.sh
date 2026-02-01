#!/bin/bash

current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

if [ "$current_layout" = "es" ]; then
    setxkbmap us
    notify-send "Keyboard layout: US"
else
    setxkbmap es
    notify-send "Keyboard layout: ES"
fi
