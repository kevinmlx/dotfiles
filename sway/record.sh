#!/bin/bash
dir="$HOME/Vídeos/screenshots"
mkdir -p "$dir"
pidfile="/tmp/sway-recording.pid"

if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill -INT "$(cat "$pidfile")" && rm -f "$pidfile"
    notify-send "Grabacion terminada" "Guardada en $dir"
    exit 0
fi

choice=$(printf "Solo video\nVideo + audio" | wmenu -l 2 -p "Tipo:") || exit 1

case "$choice" in
    "Solo video")
        file="$dir/$(date '+%Y-%m-%d_%H-%M-%S')_video.mp4"
        area=$(slurp) || exit 1
        wf-recorder -g "$area" -f "$file" &
        disown
        echo $! > "$pidfile"
        notify-send "Grabando" "Video"
        ;;
    "Video + audio")
        file="$dir/$(date '+%Y-%m-%d_%H-%M-%S')_audio.mp4"
        area=$(slurp) || exit 1
        wf-recorder -g "$area" -f "$file" --audio &
        disown
        echo $! > "$pidfile"
        notify-send "Grabando" "Video+Audio"
        ;;
esac
