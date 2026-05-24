#!/bin/bash
# Sway status bar script
# Shows: recording indicator, reminders, Bluetooth devices, battery, date/time

NOTIFIED_FILE="$HOME/.cache/sway-bat-notified"

while true; do
    # --- Battery ---
    bat_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
    bat_status=$(cat /sys/class/power_supply/BAT0/status)

    # Notify when battery is low (≤20% and not charging)
    if [ "$bat_capacity" -le 20 ] && [ "$bat_status" != "Charging" ] && [ ! -f "$NOTIFIED_FILE" ]; then
        notify-send -u critical "Bateria baja" "$bat_capacity% restante"
        touch "$NOTIFIED_FILE"
    fi
    # Reset notification once charging resumes
    if [ "$bat_status" = "Charging" ] && [ -f "$NOTIFIED_FILE" ]; then
        rm -f "$NOTIFIED_FILE"
    fi

    # Battery display text
    if [ "$bat_status" = "Charging" ] || [ "$bat_status" = "Full" ]; then
        bat_text="BAT $bat_capacity% (+)"
    else
        bat_text="BAT $bat_capacity%"
    fi

    # --- Bluetooth ---
    bt_device=$(timeout 3 bluetoothctl devices Connected 2>/dev/null | sed 's/Device [0-9A-F:]* //')
    if [ -n "$bt_device" ]; then
        bt_text="$bt_device |"
    else
        bt_text=""
    fi

    # --- Screen recording indicator ---
    rec_text=""
    if [ -f /tmp/sway-recording.pid ] && kill -0 "$(cat /tmp/sway-recording.pid)" 2>/dev/null; then
        rec_text="REC   |"
    fi

    # --- Reminder countdown ---
    remind_text=""
    if [ -f /tmp/sway-reminder.txt ]; then
        end=$(cut -d'|' -f1 /tmp/sway-reminder.txt)
        msg=$(cut -d'|' -f2- /tmp/sway-reminder.txt)
        now=$(date +%s)
        if [ "$end" -gt "$now" ]; then
            remaining=$(( (end - now + 30) / 60 ))
            remind_text="$remaining min |"
        fi
    fi

    # --- Output ---
    echo "$rec_text $remind_text $bt_text $bat_text | $(date '+%d-%m-%Y %H:%M')"
    sleep 10
done
