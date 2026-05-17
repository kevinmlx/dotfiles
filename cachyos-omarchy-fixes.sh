#!/bin/bash
# =============================================================================
# CachyOS + Omarchy — Script de fixes post-instalación (interactivo)
# Hardware: Lenovo ThinkPad T14 Gen 2i (Intel i5-1145G7 / Tiger Lake)
# Probado con: CachyOS + Omarchy, kernel 7.0.x, Hyprland, Wayland
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()     { echo -e "   ${GREEN}✓${NC} $1"; }
warn()   { echo -e "   ${YELLOW}⚠${NC} $1"; }
info()   { echo -e "   ${CYAN}→${NC} $1"; }
header() { echo -e "\n${BOLD}$1${NC}"; }

confirmar() {
    local sintoma="$1"
    echo ""
    echo -e "${YELLOW}  ¿Tienes este problema?${NC}"
    echo -e "  $sintoma"
    echo ""
    read -rp "  [s/N]: " respuesta
    [[ "$respuesta" =~ ^[sS]$ ]]
}

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     CachyOS + Omarchy — Fixes Post-Instalación              ║"
echo "║     ThinkPad T14 Gen 2i (Tiger Lake)                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Este script te preguntará uno a uno si tienes cada problema"
echo "  antes de aplicar el fix correspondiente."
echo ""
echo "  Responde 's' para aplicar el fix, Enter o 'n' para saltarlo."

REINICIAR=false

# =============================================================================
# FIX 1: SUSPEND
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 1/9 — Suspend: el equipo no vuelve a encender"
header "──────────────────────────────────────────────────────"
echo ""
echo "  Al suspender el equipo (cerrando la tapa o por inactividad),"
echo "  el LED de encendido queda SÓLIDO en lugar de parpadear,"
echo "  el teclado sigue iluminado pero la pantalla no vuelve."
echo "  La única solución es apagar manteniendo el botón de encendido."
echo ""
echo "  IMPORTANTE: Para que este fix funcione, también debes ir a la"
echo "  BIOS del ThinkPad y cambiar:"
echo "    Config > Power > Sleep State → 'Linux S3' (no 'Windows/Linux')"

if confirmar "¿El equipo se queda colgado al suspenderse y no vuelve a encender?"; then
    sudo mkdir -p /etc/systemd/sleep.conf.d/
    sudo tee /etc/systemd/sleep.conf.d/no-hibernate.conf > /dev/null << 'EOF'
[Sleep]
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
AllowSuspend=yes
SuspendState=mem
EOF

    if grep -q "^SleepOperation" /etc/systemd/logind.conf 2>/dev/null; then
        sudo sed -i 's/^SleepOperation.*/SleepOperation=suspend/' /etc/systemd/logind.conf
    elif grep -q "^#SleepOperation" /etc/systemd/logind.conf 2>/dev/null; then
        sudo sed -i 's/^#SleepOperation.*/SleepOperation=suspend/' /etc/systemd/logind.conf
    else
        echo "SleepOperation=suspend" | sudo tee -a /etc/systemd/logind.conf > /dev/null
    fi

    sudo systemctl restart systemd-logind
    ok "Hibernación desactivada, SleepOperation=suspend activo"
    REINICIAR=true
else
    info "Fix 1 saltado"
fi

# =============================================================================
# FIX 2: PARÁMETROS DEL KERNEL
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 2/9 — Kernel params: suspend sigue fallando ocasionalmente"
header "──────────────────────────────────────────────────────"
echo ""
echo "  Incluso con el Fix 1 aplicado, el suspend falla algunas veces"
echo "  pero no siempre. Es intermitente e impredecible."
echo ""
echo "  Esto pasa porque:"
echo "    - El NVMe Kioxia entra en estados de ahorro muy profundos"
echo "      y no responde bien al despertar."
echo "    - La GPU Intel (i915) tiene 'display power saving' agresivo"
echo "      que puede interferir con el resume."

if confirmar "¿El suspend sigue fallando ocasionalmente después del Fix 1?"; then
    PARAMS="nvme_core.default_ps_max_latency_us=0 i915.enable_dc=0"

    if [ -f /etc/default/limine ]; then
        if grep -q "KERNEL_CMDLINE\[default\]" /etc/default/limine; then
            if ! grep -q "nvme_core.default_ps_max_latency_us" /etc/default/limine; then
                sudo sed -i "s|\(KERNEL_CMDLINE\[default\]+=\".*\)\"|\1 $PARAMS\"|" /etc/default/limine
                ok "Parámetros agregados a /etc/default/limine"
            else
                ok "Parámetros ya presentes"
            fi
        fi
    elif [ -f /etc/kernel/cmdline ]; then
        if ! grep -q "nvme_core.default_ps_max_latency_us" /etc/kernel/cmdline; then
            sudo sed -i "s|$| $PARAMS|" /etc/kernel/cmdline
            ok "Parámetros agregados a /etc/kernel/cmdline"
        else
            ok "Parámetros ya presentes"
        fi
    else
        warn "No se encontró /etc/default/limine ni /etc/kernel/cmdline"
        warn "Agrega manualmente al final de tu cmdline:"
        warn "  $PARAMS"
    fi
    REINICIAR=true
else
    info "Fix 2 saltado"
fi

# =============================================================================
# FIX 3: BOOT LENTO
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 3/9 — Boot lento: el sistema tarda más de 1 minuto en arrancar"
header "──────────────────────────────────────────────────────"
echo ""
echo "  El sistema tarda más de 1 minuto en llegar al login."
echo "  Puedes verificarlo ejecutando: systemd-analyze blame | head -5"
echo "  Si ves 'cachyos-rate-mirrors' tardando ~60s, es este problema."
echo ""
echo "  Los culpables son:"
echo "    - cachyos-rate-mirrors.timer: actualiza mirrors de pacman"
echo "      en cada boot, tardando ~65 segundos innecesariamente."
echo "    - NetworkManager-wait-online: espera conexión completa de red"
echo "      antes de continuar el boot, lo cual no es necesario."

if confirmar "¿El sistema tarda más de 1 minuto en arrancar?"; then
    sudo systemctl disable --now cachyos-rate-mirrors.timer 2>/dev/null || true
    sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null || true
    ok "cachyos-rate-mirrors.timer deshabilitado"
    ok "NetworkManager-wait-online deshabilitado"
else
    info "Fix 3 saltado"
fi

# =============================================================================
# FIX 4: PANTALLA AZUL AL CAMBIAR ÁNGULO
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 4/9 — Pantalla azul/freeze al cambiar el ángulo de la tapa"
header "──────────────────────────────────────────────────────"
echo ""
echo "  Al abrir, cerrar o cambiar el ángulo de la tapa del portátil,"
echo "  la pantalla se congela completamente y se pone azul."
echo "  El audio también se corta. No se recupera solo, hay que reiniciar."
echo ""
echo "  Causa: el driver 'raydium_i2c_ts' (touchscreen) tiene un bug"
echo "  que causa un kernel crash cuando el sensor de orientación"
echo "  detecta movimiento de la tapa."
echo ""
echo "  El touchscreen seguirá funcionando normalmente después del fix."

if confirmar "¿La pantalla se pone azul y se congela al mover la tapa?"; then
    sudo tee /etc/modprobe.d/blacklist-raydium.conf > /dev/null << 'EOF'
# raydium_i2c_ts causa kernel NULL pointer dereference en ThinkPad T14 Gen 2
# al cambiar el angulo de la pantalla. El touchscreen sigue funcionando
# via hid-multitouch.
blacklist raydium_i2c_ts
EOF
    ok "raydium_i2c_ts blacklisteado"
    REINICIAR=true
else
    info "Fix 4 saltado"
fi

# =============================================================================
# FIX 5: TRACKPAD — DRIVER RMI4
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 5/9 — Trackpad: movimiento impreciso o multitouch no funciona"
header "──────────────────────────────────────────────────────"
echo ""
echo "  El trackpad funciona pero se siente poco preciso, con lag,"
echo "  o el scroll con dos dedos no responde bien."
echo ""
echo "  Verifica el driver actual con:"
echo "    sudo dmesg | grep -i synaptics | tail -3"
echo "  Si dice 'SynPS/2' está en PS/2 (lento)."
echo "  Si dice 'TM3471-030' ya está en RMI4 (no necesitas este fix)."

if confirmar "¿El trackpad se siente impreciso o el multitouch no funciona bien?"; then
    sudo tee /etc/modprobe.d/trackpad.conf > /dev/null << 'EOF'
# Usar SMBus (RMI4) en lugar de PS/2 legacy para el trackpad Synaptics TM3471-030
options psmouse synaptics_intertouch=1
EOF
    ok "Driver RMI4/SMBus activado"
    REINICIAR=true
else
    info "Fix 5 saltado"
fi

# =============================================================================
# FIX 6: TRACKPAD ERRÁTICO — LECTOR DE HUELLAS
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 6/9 — Trackpad errático: cursor salta al eje equivocado"
header "──────────────────────────────────────────────────────"
echo ""
echo "  El cursor del trackpad a veces se mueve solo en la dirección"
echo "  equivocada — mueves el dedo hacia la derecha y el cursor va"
echo "  hacia arriba o abajo. Pasa de manera aleatoria e impredecible."
echo ""
echo "  Puedes confirmar el problema con:"
echo "    sudo dmesg | grep 'usb 3-3' | tail -10"
echo "  Si ves líneas repetidas de 'reset full-speed USB device', es esto."
echo ""
echo "  NOTA: este fix desactiva el lector de huellas completamente."

if confirmar "¿El cursor del trackpad salta al eje equivocado de manera aleatoria?"; then
    sudo tee /etc/udev/rules.d/90-goodix-fingerprint.rules > /dev/null << 'EOF'
# Desautorizar lector de huellas Goodix (27c6:6584)
# Sus resets periodicos en el bus USB causan comportamiento erratico
# en el trackpad Synaptics (cursor salta al eje equivocado).
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="6584", ATTR{authorized}="0"
EOF
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    ok "Lector de huellas Goodix desautorizado"
    REINICIAR=true
else
    info "Fix 6 saltado"
fi

# =============================================================================
# FIX 7: BLUETOOTH NO PERSISTE
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 7/9 — Bluetooth: se apaga solo tras cada reinicio"
header "──────────────────────────────────────────────────────"
echo ""
echo "  El Bluetooth aparece apagado tras cada reinicio."
echo "  Se puede encender manualmente con 'bluetoothctl power on'"
echo "  pero al reiniciar vuelve a apagarse."
echo ""
echo "  Verifica el estado actual con:"
echo "    bluetoothctl show | grep Powered"
echo "  Si dice 'Powered: no' tras reiniciar, tienes este problema."

if confirmar "¿El Bluetooth se apaga solo en cada reinicio?"; then
    if [ -f /etc/bluetooth/main.conf ]; then
        if grep -q "^#AutoEnable" /etc/bluetooth/main.conf; then
            sudo sed -i 's/^#AutoEnable.*/AutoEnable=true/' /etc/bluetooth/main.conf
        elif grep -q "^AutoEnable=false" /etc/bluetooth/main.conf; then
            sudo sed -i 's/^AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf
        elif ! grep -q "^AutoEnable" /etc/bluetooth/main.conf; then
            echo "AutoEnable=true" | sudo tee -a /etc/bluetooth/main.conf > /dev/null
        fi
    else
        sudo mkdir -p /etc/bluetooth
        sudo tee /etc/bluetooth/main.conf > /dev/null << 'EOF'
[Policy]
AutoEnable=true
EOF
    fi
    sudo systemctl restart bluetooth
    ok "AutoEnable=true activado en /etc/bluetooth/main.conf"
else
    info "Fix 7 saltado"
fi

# =============================================================================
# FIX 8: OMARCHY_PATH
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 8/9 — omarchy-update falla con error de archivo no encontrado"
header "──────────────────────────────────────────────────────"
echo ""
echo "  Al ejecutar 'omarchy update', falla con un error como:"
echo "    cat: /version: No existe el fichero o el directorio"
echo "    Something went wrong during the update!"
echo ""
echo "  Verifica si tienes el problema con:"
echo "    echo \$OMARCHY_PATH"
echo "  Si no muestra nada (línea vacía), tienes este problema."

if confirmar "¿omarchy-update falla con errores de archivos no encontrados?"; then
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$HOME/.config/fish"

    if ! grep -q "OMARCHY_PATH" "$FISH_CONFIG" 2>/dev/null; then
        cat >> "$FISH_CONFIG" << 'EOF'

# OMARCHY_PATH — fish no carga uwsm/env automáticamente.
# Sin esto, omarchy-update y otros comandos fallan.
set -gx OMARCHY_PATH $HOME/.local/share/omarchy
fish_add_path $OMARCHY_PATH/bin
EOF
        ok "OMARCHY_PATH agregado a ~/.config/fish/config.fish"
    else
        ok "OMARCHY_PATH ya estaba configurado"
    fi
else
    info "Fix 8 saltado"
fi

# =============================================================================
# FIX 9: DISPLAY MANAGER
# =============================================================================
header "──────────────────────────────────────────────────────"
header "Fix 9/9 — Conflicto de display managers: pantalla negra al iniciar"
header "──────────────────────────────────────────────────────"
echo ""
echo "  Al arrancar, aparece la pantalla de login de omarchy (ly)"
echo "  pero luego la pantalla queda en negro. Hay que usar teclas"
echo "  de función para llegar al login de CachyOS (plasmalogin)."
echo ""
echo "  Verifica si tienes ambos activos con:"
echo "    systemctl list-units | grep -E 'ly|plasmalogin'"
echo "  Si aparecen los dos como 'active', tienes este problema."

if confirmar "¿La pantalla queda en negro al arrancar por conflicto de login managers?"; then
    sudo systemctl disable --now plasmalogin.service 2>/dev/null || true
    ok "plasmalogin deshabilitado"

    if systemctl list-unit-files | grep -q "ly@"; then
        sudo systemctl enable --now "ly@tty2.service" 2>/dev/null || true
        ok "ly habilitado"
    elif systemctl list-unit-files | grep -q "^ly.service"; then
        sudo systemctl enable --now ly.service 2>/dev/null || true
        ok "ly habilitado"
    else
        warn "No se encontró ly — instálalo con: sudo pacman -S ly"
    fi
    REINICIAR=true
else
    info "Fix 9 saltado"
fi

# =============================================================================
# REGENERAR INITRAMFS
# =============================================================================
if $REINICIAR; then
    echo ""
    header "▶ Regenerando initramfs..."
    if command -v limine-mkinitcpio &>/dev/null; then
        sudo limine-mkinitcpio
    elif command -v mkinitcpio &>/dev/null; then
        sudo mkinitcpio -P
    else
        warn "No se encontró limine-mkinitcpio ni mkinitcpio — regenera manualmente"
    fi

    echo ""
    header "▶ Actualizando entradas del bootloader..."
    if command -v limine-update &>/dev/null; then
        sudo limine-update 2>/dev/null || true
        ok "Entradas de Limine actualizadas"
    fi
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   ✓ Script completado                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if $REINICIAR; then
    echo "  Reinicia para aplicar todos los cambios:"
    echo "    reboot"
    echo ""
fi

echo "  Configuración manual requerida tras reiniciar:"
echo ""
echo "  1. BIOS ThinkPad (si tienes problemas de suspend):"
echo "     Config > Power > Sleep State → 'Linux S3'"
echo ""
echo "  2. Trackpad en Hyprland (~/.config/hypr/input.conf):"
echo "     touchpad {"
echo "       clickfinger_behavior = true"
echo "       tap-to-click = true"
echo "       tap-and-drag = true"
echo "       drag_lock = false"
echo "       scroll_factor = 0.4"
echo "     }"
echo ""
echo "  3. SwayOSD en autostart (~/.config/hypr/autostart.conf):"
echo "     exec-once = swayosd-server"
echo ""
