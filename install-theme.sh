#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/Tecdroid214/rollo-warrior.git"
THEME_NAME="rollo-warrior"
THEME_DEST="/usr/share/sddm/themes/${THEME_NAME}"
SDDM_CONF="/etc/sddm.conf.d/10-${THEME_NAME}.conf"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REAL_USER="${SUDO_USER:-$(id -un)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
LOCAL_CLONE="${REAL_HOME}/rollo-warrior"

if [[ -f "${SCRIPT_DIR}/Main.qml" && -f "${SCRIPT_DIR}/metadata.desktop" ]]; then
    SOURCE_DIR="$SCRIPT_DIR"
else
    SOURCE_DIR="$LOCAL_CLONE"
fi

log() {
    printf '\n==> %s\n' "$*"
}

warn() {
    printf '\nAVISO: %s\n' "$*" >&2
}

fail() {
    printf '\nERROR: %s\n' "$*" >&2
    exit 1
}

on_error() {
    local exit_code=$?
    printf '\nERROR: el instalador terminó en la línea %s con código %s.\n' \
        "${BASH_LINENO[0]:-desconocida}" "$exit_code" >&2
    exit "$exit_code"
}
trap on_error ERR

require_root() {
    [[ $EUID -eq 0 ]] || fail "Ejecuta este script con: sudo ./install-theme.sh"
}

run_as_real_user() {
    if [[ "$REAL_USER" == "root" ]]; then
        "$@"
    else
        runuser -u "$REAL_USER" -- "$@"
    fi
}

ensure_source() {
    if [[ -f "${SOURCE_DIR}/Main.qml" && -f "${SOURCE_DIR}/metadata.desktop" ]]; then
        return
    fi

    log "Clonando el repositorio en ${LOCAL_CLONE}"
    rm -rf -- "$LOCAL_CLONE"
    run_as_real_user git clone "$REPO_URL" "$LOCAL_CLONE"
    SOURCE_DIR="$LOCAL_CLONE"
}

install_packages() {
    log "Instalando dependencias para SDDM y Qt 6"

    pacman -S --needed --noconfirm \
        git \
        rsync \
        sddm \
        qt6-declarative \
        qt6-svg \
        qt6-multimedia-ffmpeg
}

read_theme_value() {
    local key="$1"
    local file="${SOURCE_DIR}/theme.conf"

    awk -F= -v wanted="$key" '
        $0 !~ /^[[:space:]]*[;#]/ {
            current=$1
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)
            if (current == wanted) {
                value=substr($0, index($0, "=") + 1)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                print value
                exit
            }
        }
    ' "$file"
}

validate_source() {
    log "Validando archivos del tema"

    local required_files=(
        "Main.qml"
        "VideoBackground.qml"
        "metadata.desktop"
        "theme.conf"
    )

    local file
    for file in "${required_files[@]}"; do
        [[ -f "${SOURCE_DIR}/${file}" ]] || fail "Falta ${SOURCE_DIR}/${file}"
    done

    grep -Eq '^QtVersion[[:space:]]*=[[:space:]]*6[[:space:]]*$' \
        "${SOURCE_DIR}/metadata.desktop" \
        || fail "metadata.desktop debe contener QtVersion=6"

    local background_type enable_video image_path video_path fallback_path
    background_type="$(read_theme_value BackgroundType || true)"
    enable_video="$(read_theme_value EnableVideo || true)"
    image_path="$(read_theme_value BackgroundImage || true)"
    video_path="$(read_theme_value BackgroundVideo || true)"
    fallback_path="$(read_theme_value BackgroundVideoFallbackGif || true)"

    if [[ -n "$image_path" && ! -f "${SOURCE_DIR}/${image_path}" ]]; then
        warn "No existe la imagen de respaldo: ${SOURCE_DIR}/${image_path}"
    fi

    if [[ "$background_type" == "video" && "$enable_video" == "true" ]]; then
        if [[ -z "$video_path" ]]; then
            fail "BackgroundType=video y EnableVideo=true, pero BackgroundVideo está vacío"
        fi

        if [[ ! -f "${SOURCE_DIR}/${video_path}" ]]; then
            warn "No existe el video configurado: ${SOURCE_DIR}/${video_path}. El tema usará el GIF o la imagen de respaldo."
        fi
    fi

    if [[ -n "$fallback_path" && ! -f "${SOURCE_DIR}/${fallback_path}" ]]; then
        warn "No existe el GIF de respaldo: ${SOURCE_DIR}/${fallback_path}"
    fi

    log "Validación completada"
}

copy_theme() {
    log "Copiando el tema a ${THEME_DEST}"

    install -d -m 0755 "$THEME_DEST"

    rsync -a --delete \
        --exclude '.git/' \
        --exclude '.github/' \
        --exclude 'install-theme.sh' \
        --exclude '*.bak' \
        --exclude '*~' \
        "${SOURCE_DIR}/" "${THEME_DEST}/"

    chown -R root:root "$THEME_DEST"
    find "$THEME_DEST" -type d -exec chmod 0755 {} +
    find "$THEME_DEST" -type f -exec chmod 0644 {} +

    log "Tema instalado correctamente"
}

configure_theme() {
    log "Configurando Rollo Warrior como tema de SDDM"

    install -d -m 0755 /etc/sddm.conf.d

    cat > "$SDDM_CONF" <<CONF
[General]
DisplayServer=x11

[Theme]
Current=${THEME_NAME}
CONF

    chmod 0644 "$SDDM_CONF"
    log "Configuración escrita en ${SDDM_CONF}"
}

show_display_manager() {
    local manager="ninguno"

    if [[ -L /etc/systemd/system/display-manager.service ]]; then
        manager="$(readlink -f /etc/systemd/system/display-manager.service)"
    fi

    printf '\nGestor de inicio configurado actualmente: %s\n' "$manager"
}

activate_sddm() {
    require_root
    show_display_manager

    printf '\nEsta acción cambiará el gestor de inicio para el próximo arranque.\n'
    printf 'No cerrará tu sesión gráfica actual.\n'
    read -r -p 'Escribe SI para continuar: ' confirmation

    [[ "$confirmation" == "SI" ]] || {
        echo "Operación cancelada."
        return
    }

    if systemctl list-unit-files lightdm.service >/dev/null 2>&1; then
        systemctl disable lightdm.service || true
    fi

    systemctl enable sddm.service --force

    log "SDDM quedó habilitado para el próximo arranque"
    show_display_manager
    echo "Reinicia cuando estés listo: sudo reboot"
}

restore_lightdm() {
    require_root

    if ! systemctl list-unit-files lightdm.service >/dev/null 2>&1; then
        fail "LightDM no está instalado"
    fi

    systemctl disable sddm.service || true
    systemctl enable lightdm.service --force

    log "LightDM quedó restaurado para el próximo arranque"
    show_display_manager
}

update_repository() {
    ensure_source

    if [[ -d "${SOURCE_DIR}/.git" ]]; then
        log "Actualizando el repositorio local"
        run_as_real_user git -C "$SOURCE_DIR" pull --ff-only origin main
    else
        warn "${SOURCE_DIR} no es un repositorio Git; se copiarán los archivos locales actuales"
    fi
}

print_test_commands() {
    cat <<INFO

Prueba el tema desde tu sesión gráfica, SIN sudo:

  sddm-greeter-qt6 --test-mode --theme ${THEME_DEST}

Comprueba que SDDM detectará Qt 6:

  grep '^QtVersion=' ${THEME_DEST}/metadata.desktop

Comprueba que el video fue instalado:

  grep '^BackgroundVideo=' ${THEME_DEST}/theme.conf
  ls -lh ${THEME_DEST}/assets/videos/

El mensaje de socket en --test-mode es normal porque el greeter de prueba no
está conectado al demonio real de SDDM.
INFO
}

do_install() {
    require_root
    install_packages
    ensure_source
    validate_source
    copy_theme
    configure_theme
    show_display_manager
    print_test_commands

    cat <<INFO

Instalación terminada.
El instalador NO sustituyó automáticamente LightDM.
Usa la opción 4 del menú cuando la prueba con sddm-greeter-qt6 funcione.
INFO
}

do_update() {
    require_root
    ensure_source
    update_repository
    validate_source
    copy_theme
    configure_theme
    print_test_commands
}

show_menu() {
    cat <<'MENU'

=== Instalador de Rollo Warrior SDDM Theme v0.3 ===

1) Instalar o reparar dependencias, tema y configuración
2) Actualizar desde GitHub y volver a copiar el tema
3) Mostrar comandos de prueba
4) Activar SDDM para el próximo arranque
5) Restaurar LightDM para el próximo arranque
6) Salir
MENU
}

main() {
    require_root

    while true; do
        show_menu
        read -r -p 'Elige una opción [1-6]: ' option

        case "$option" in
            1) do_install ;;
            2) do_update ;;
            3) print_test_commands ;;
            4) activate_sddm ;;
            5) restore_lightdm ;;
            6) echo "Saliendo."; exit 0 ;;
            *) echo "Opción inválida." ;;
        esac
    done
}

main "$@"