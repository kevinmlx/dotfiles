#!/bin/bash
# Simple reminder script for Sway
# First call: prompts for minutes and message, then sets a timer
# Second call (before timer expires): cancels the reminder

reminder_file="/tmp/sway-reminder.txt"
pidfile="/tmp/sway-reminder.pid"

# Cancel existing reminder
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill "$(cat "$pidfile")"
    rm -f "$pidfile" "$reminder_file"
    notify-send "Recordatorio cancelado"
    exit 0
fi

# Prompt for minutes
minutes=$(echo "" | wmenu -p "Minutos:")
[ -z "$minutes" ] && exit 1
[ "$minutes" -eq "$minutes" ] 2>/dev/null || exit 1

# Prompt for message
sleep 0.1
msg=$(echo "" | wmenu -p "Mensaje:")
[ -z "$msg" ] && exit 1

# Run timer in background
(
    end=$(( $(date +%s) + minutes * 60 ))
    echo "$end|$msg" > "$reminder_file"
    sleep "$((minutes * 60))"
    notify-send -u critical -t 0 "Recordatorio" "$msg"
    pw-play /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null
    rm -f "$reminder_file"
) &

echo $! > "$pidfile"
notify-send "Recordatorio en $minutes min" "$msg"
