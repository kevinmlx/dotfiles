#!/bin/bash
reminder_file="/tmp/sway-reminder.txt"
pidfile="/tmp/sway-reminder.pid"

# Cancel (called with "cancel" argument or via $mod+Shift+n)
if [ "$1" = "cancel" ]; then
    [ -f "$pidfile" ] && kill "$(cat "$pidfile")" 2>/dev/null
    rm -f "$pidfile" "$reminder_file"
    notify-send "Recordatorio cancelado"
    exit 0
fi

# If a timer is running, pause it
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill "$(cat "$pidfile")"
    rm -f "$pidfile"
    # Calculate remaining time
    end=$(cut -d'|' -f1 "$reminder_file")
    msg=$(cut -d'|' -f2- "$reminder_file")
    now=$(date +%s)
    remaining=$(( end - now ))
    [ "$remaining" -le 0 ] && remaining=0
    # Save paused state
    echo "paused|$remaining|$msg" > "$reminder_file"
    notify-send "Recordatorio pausado" "Quedan $remaining segundos"
    exit 0
fi

# If paused, resume it
if [ -f "$reminder_file" ] && grep -q "^paused|" "$reminder_file"; then
    read -r line < "$reminder_file"
    remaining=$(echo "$line" | cut -d'|' -f2)
    msg=$(echo "$line" | cut -d'|' -f3-)
    if [ "$remaining" -le 0 ]; then
        rm -f "$reminder_file"
        exit 0
    fi
    (
        end=$(( $(date +%s) + remaining ))
        echo "$end|$msg" > "$reminder_file"
        sleep "$remaining"
        notify-send -u critical -t 0 "Recordatorio" "$msg"
        pw-play /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null
        rm -f "$reminder_file"
    ) &
    echo $! > "$pidfile"
    notify-send "Recordatorio reanudado" "$remaining segundos restantes"
    exit 0
fi

# No timer or paused state → start a new reminder
minutes=$(echo "" | wmenu -p "Minutos:")
[ -z "$minutes" ] && exit 1
[ "$minutes" -eq "$minutes" ] 2>/dev/null || exit 1

sleep 0.1
msg=$(echo "" | wmenu -p "Mensaje:")
[ -z "$msg" ] && exit 1

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

