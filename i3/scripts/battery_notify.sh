#!/bin/bash

# Script para notificar cuando la batería esté baja
# Guarda este archivo como ~/.scripts/battery_notify.sh

BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1)

# Archivo para evitar spam de notificaciones
NOTIFIED_FILE="/tmp/battery_notified"

# Si la batería está al 20% o menos y no está cargando
if [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_STATUS" != "Charging" ]; then
    # Solo notificar si no hemos notificado ya
    if [ ! -f "$NOTIFIED_FILE" ]; then
        notify-send -u critical -i battery-low \
            "¡Batería Baja!" \
            "La batería está al ${BATTERY_LEVEL}%. Por favor conecta el cargador."
        
        # Crear archivo para evitar spam
        touch "$NOTIFIED_FILE"
    fi
elif [ "$BATTERY_LEVEL" -gt 25 ] || [ "$BATTERY_STATUS" = "Charging" ]; then
    # Resetear la notificación cuando la batería suba o esté cargando
    rm -f "$NOTIFIED_FILE"
fi
