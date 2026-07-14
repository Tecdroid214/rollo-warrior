#!/usr/bin/env bash
set -e

echo "=== Instalador de Rollo Warrior SDDM Theme ==="

# 1. Verifica que se ejecute con sudo
if [ "$EUID" -ne 0 ]; then
    echo "Este script necesita sudo. Ejecuta: sudo ./install-theme.sh"
    exit 1
fi

# 2. Instala los paquetes necesarios
echo ""
echo "--- Instalando paquetes necesarios ---"
pacman -S --needed --noconfirm \
    sddm \
    qt6-declarative \
    qt6-svg \
    qt6-multimedia \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-base \
    gst-libav

# 3. Copia el tema a la ubicación del sistema
echo ""
echo "--- Copiando el tema a /usr/share/sddm/themes/ ---"
THEME_SOURCE="$(dirname "$(readlink -f "$0")")"
rsync -av --delete "$THEME_SOURCE"/ /usr/share/sddm/themes/rollo-warrior/ \
    --exclude install-theme.sh \
    --exclude .git

# 4. Configura SDDM para usar el tema
echo ""
echo "--- Configurando SDDM ---"
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf.d << 'EOF'
[Theme]
Current=rollo-warrior
EOF

# 5. Habilita el servicio
systemctl enable sddm

echo ""
echo "=== Instalación completa ==="
echo ""
echo "IMPORTANTE: antes de reiniciar, prueba el tema con:"
echo "  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/rollo-warrior"
echo ""
echo "Si carga sin errores, reinicia SDDM desde una TTY (Ctrl+Alt+F3) con:"
echo "  sudo systemctl restart sddm"