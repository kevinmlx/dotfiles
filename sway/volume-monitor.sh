#!/bin/bash
# PipeWire volume monitor for Sway
# Watches for external volume changes and syncs them to swayosd-client
# This ensures the OSD shows the correct volume when changed via hardware keys or other apps

pidfile="/tmp/sway-volume-monitor.pid"

# Kill previous instance
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill "$(cat "$pidfile")"
    sleep 0.2
fi
echo $$ > "$pidfile"

prev_vol=""
while true; do
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    if [ "$vol" != "$prev_vol" ] && [ -n "$prev_vol" ]; then
        if [ "$(echo "$vol > $prev_vol" | bc)" -eq 1 ]; then
            swayosd-client --output-volume +1 2>/dev/null
        else
            swayosd-client --output-volume -1 2>/dev/null
        fi
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$vol"
    fi
    prev_vol="$vol"
    sleep 0.3
done
