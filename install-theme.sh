#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Tecdroid214/rollo-warrior.git"
LOCAL_DIR="$HOME/rollo-warrior"
THEME_DEST="/usr/share/sddm/themes/rollo-warrior"

function check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Este script necesita permisos sudo. Ejecuta: sudo ./install-theme.sh"
        exit 1
    fi
}

function install_packages() {
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
}

function copy_theme() {
    echo ""
    echo "--- Copiando el tema a $THEME_DEST ---"
    if [ ! -d "$LOCAL_DIR/assets/videos" ] || [ -z "$(ls -A "$LOCAL_DIR/assets/videos" 2>/dev/null)" ]; then
        echo "AVISO: no se encontraron videos en $LOCAL_DIR/assets/videos"
        echo "Si tu theme.conf usa BackgroundType=video, copia tus videos ahí antes de continuar."
    fi
    rsync -av --delete "$LOCAL_DIR"/ "$THEME_DEST"/ \
        --exclude install-theme.sh \
        --exclude .git
}

function configure_sddm() {
    echo ""
    echo "--- Configurando SDDM ---"
    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/theme.conf << 'EOF'
[Theme]
Current=rollo-warrior
EOF
    systemctl enable sddm
}

function do_install() {
    check_sudo

    if [ ! -d "$LOCAL_DIR" ]; then
        echo ""
        echo "--- Clonando el repositorio ---"
        su - "$SUDO_USER" -c "git clone $REPO_URL $LOCAL_DIR"
    fi

    install_packages
    copy_theme
    configure_sddm

    echo ""
    echo "=== Instalación completa ==="
    echo "Prueba antes de reiniciar SDDM:"
    echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DEST"
    echo ""

    if [ ! -d "$LOCAL_DIR/assets/videos" ] || [ -z "$(ls -A "$LOCAL_DIR/assets/videos" 2>/dev/null)" ]; then
        echo "RECUERDA: si usas fondos en video, coloca tus archivos .mp4 en:"
        echo "  $LOCAL_DIR/assets/videos/"
        echo "y vuelve a correr este instalador con la opción 2 (Actualizar)."
    fi
}

function do_update() {
    echo ""
    echo "--- Actualizando desde GitHub ---"
    if [ -d "$LOCAL_DIR/.git" ]; then
        cd "$LOCAL_DIR"
        git pull origin main
    else
        echo "No se encontró un repositorio Git en $LOCAL_DIR"
        echo "Clonando desde $REPO_URL ..."
        rm -rf "$LOCAL_DIR"
        git clone "$REPO_URL" "$LOCAL_DIR"
        chmod +x "$LOCAL_DIR/install-theme.sh"
    fi

    check_sudo
    copy_theme

    echo ""
    echo "=== Actualización completa ==="
    echo "Prueba antes de reiniciar SDDM:"
    echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DEST"
}

echo "=== Instalador de Rollo Warrior SDDM Theme ==="
echo ""
echo "1) Instalar (paquetes + tema, primera vez)"
echo "2) Actualizar (solo copia los últimos cambios del tema)"
echo "3) Salir"
echo ""
read -p "Elige una opción [1-3]: " opcion

case $opcion in
    1) do_install ;;
    2) do_update ;;
    3) echo "Saliendo..."; exit 0 ;;
    *) echo "Opción inválida"; exit 1 ;;
esac