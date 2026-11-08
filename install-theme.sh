#!/usr/bin/env bash
# Rollo Warrior · instalador SDDM
# Compatible con Arch/CachyOS (pacman) y Debian/Ubuntu (apt).
set -Eeuo pipefail

# ============================================================
# CONFIGURACIÓN DEL PROYECTO
# ============================================================
REPO_URL="https://github.com/Tecdroid214/rollo-warrior.git"
THEME_NAME="rollo-warrior"
THEME_DEST="/usr/share/sddm/themes/${THEME_NAME}"
SDDM_CONF="/etc/sddm.conf.d/10-${THEME_NAME}.conf"
ACCENT="#c6f4eb"
MISSING=0

# ============================================================
# MENSAJES (antes de que exista gum)
# ============================================================
log()  { printf '\n==> %s\n' "$*"; }
warn() { printf '\nAVISO: %s\n' "$*" >&2; }
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

on_error() {
    local code=$?
    printf '\nERROR: el instalador terminó en la línea %s con código %s.\n' \
        "${BASH_LINENO[0]:-?}" "$code" >&2
    exit "$code"
}
trap on_error ERR

# ============================================================
# DETECCIÓN DE DISTRIBUCIÓN
# Qt6 en Debian se reparte en paquetes qml6-module-*, en Arch todo
# viene dentro de qt6-declarative.
# ============================================================
if command -v pacman >/dev/null 2>&1; then
    PM="pacman"
    PM_REFRESH=(true)
    PM_INSTALL=(pacman -S --needed --noconfirm)
    PKGS=(git rsync sddm qt6-declarative qt6-svg qt6-multimedia-ffmpeg)
elif command -v apt-get >/dev/null 2>&1; then
    PM="apt"
    PM_REFRESH=(apt-get update)
    PM_INSTALL=(env DEBIAN_FRONTEND=noninteractive apt-get install -y)
    PKGS=(git rsync sddm
          qml6-module-qtquick
          qml6-module-qtquick-window
          qml6-module-qtqml-workerscript
          qml6-module-qtmultimedia)
else
    fail "Distribución no soportada: se necesita pacman (Arch/CachyOS) o apt (Debian/Ubuntu)."
fi

# ============================================================
# DIRECTORIO Y USUARIO REAL
# (funciona tanto ejecutando el archivo como con bash -c "$(curl ...)")
# ============================================================
SCRIPT_SRC="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
if [[ -n "$SCRIPT_SRC" && -f "$SCRIPT_SRC" ]]; then
    SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_SRC")" && pwd -P)"
fi

REAL_USER="${SUDO_USER:-$(id -un)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
LOCAL_CLONE="${REAL_HOME}/rollo-warrior"

if [[ -n "$SCRIPT_DIR" && -f "${SCRIPT_DIR}/Main.qml" && -f "${SCRIPT_DIR}/metadata.desktop" ]]; then
    SOURCE_DIR="$SCRIPT_DIR"
else
    SOURCE_DIR="$LOCAL_CLONE"
fi

run_as_real_user() {
    if [[ "$REAL_USER" == "root" ]]; then "$@"; else runuser -u "$REAL_USER" -- "$@"; fi
}

# ============================================================
# COMPROBACIONES PREVIAS
# ============================================================
require_root() {
    [[ $EUID -eq 0 ]] || fail "Ejecuta este script con sudo."
}

ensure_gum() {
    command -v gum >/dev/null 2>&1 && return 0

    log "Instalando gum (interfaz del instalador)..."
    "${PM_REFRESH[@]}" >/dev/null 2>&1 || true

    if ! "${PM_INSTALL[@]}" gum; then
        fail "No fue posible instalar gum automáticamente.
En Debian 13 está en los repos oficiales; si usas otra versión, agrega el repo de Charm:
https://github.com/charmbracelet/gum#installation"
    fi
}

# ============================================================
# INTERFAZ
# ============================================================
ok()      { gum style --foreground "$ACCENT" --bold "$*"; }
note()    { gum style --foreground "#888888" "$*"; }
caution() { gum style --foreground "#ffaa66" --bold "$*"; }
box()     { local color="$1"; shift; gum style --border rounded --padding "1 3" --foreground "$color" --bold "$*"; }
mark_ok() { gum style --foreground "$ACCENT" "  ✓ $*"; }
mark_bad(){ gum style --foreground "#ff7777" "  ✗ $*"; MISSING=$((MISSING + 1)); }

show_header() {
    clear
    gum style --foreground "$ACCENT" --bold '
 ██████╗  ██████╗ ██╗     ██╗      ██████╗
 ██╔══██╗██╔═══██╗██║     ██║     ██╔═══██╗
 ██████╔╝██║   ██║██║     ██║     ██║   ██║
 ██╔══██╗██║   ██║██║     ██║     ██║   ██║
 ██║  ██║╚██████╔╝███████╗███████╗╚██████╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝ ╚═════╝'
    gum style --foreground "#ffffff" --bold --align center --width 58 "W A R R I O R"
    gum style --foreground "#888888" --align center --width 58 "SDDM Theme Installer · v0.5 · ${PM}"
    echo
    gum style --foreground "#555555" "────────────────────────────────────────────────────────"
}

show_section() {
    show_header
    echo
    gum style --foreground "$ACCENT" --bold --border rounded --padding "0 3" "$1"
    echo
}

step() {
    echo
    gum style --foreground "$ACCENT" --bold --border rounded --padding "0 3" "$1"
    echo
}

pause_menu() {
    echo
    gum input --placeholder="Presiona ENTER para volver al menú" >/dev/null || true
}

# ============================================================
# FUENTE DEL TEMA
# ============================================================
ensure_source() {
    # Si se ejecuta desde el repo local, se usa tal cual.
    [[ "$SOURCE_DIR" == "$LOCAL_CLONE" ]] || return 0

    if [[ -d "${LOCAL_CLONE}/.git" ]]; then
        log "Actualizando ${LOCAL_CLONE}"
        run_as_real_user git -C "$LOCAL_CLONE" pull --ff-only \
            || warn "No se pudo actualizar; se usa la copia local existente."
    else
        if [[ -e "$LOCAL_CLONE" ]]; then
            local backup="${LOCAL_CLONE}.bak.$(date +%s)"
            warn "${LOCAL_CLONE} existe y no es un repositorio Git; se mueve a ${backup}"
            mv -- "$LOCAL_CLONE" "$backup"
        fi
        log "Clonando el repositorio en ${LOCAL_CLONE}"
        run_as_real_user git clone --depth 1 "$REPO_URL" "$LOCAL_CLONE"
    fi

    [[ -f "${SOURCE_DIR}/Main.qml" ]] || fail "El repositorio no contiene Main.qml"
}

# ============================================================
# DEPENDENCIAS
# ============================================================
install_packages() {
    step "Instalando dependencias (${PM})"
    gum spin --spinner dot --title "Actualizando índices..." -- "${PM_REFRESH[@]}" || true
    gum spin --spinner dot --title "Instalando dependencias..." --show-output -- \
        "${PM_INSTALL[@]}" "${PKGS[@]}"
    ok "✓ Dependencias verificadas correctamente"
}

pkg_version() {
    case "$PM" in
        pacman) pacman -Q "$1" 2>/dev/null | awk '{print $2}' || true ;;
        apt)    dpkg-query -W -f='${db:Status-Abbrev}|${Version}' "$1" 2>/dev/null \
                    | awk -F'|' '$1 ~ /^ii/ {print $2}' || true ;;
    esac
}

# Comprueba que un módulo QML exista (ruta distinta en Arch y Debian).
qml_module_exists() {
    compgen -G "/usr/lib/qt6/qml/$1" >/dev/null || compgen -G "/usr/lib/*/qt6/qml/$1" >/dev/null
}

# ============================================================
# LEER theme.conf
# ============================================================
read_theme_value() {
    awk -F= -v wanted="$1" '
        $0 !~ /^[[:space:]]*[;#]/ {
            current = $1
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)
            if (current == wanted) {
                value = substr($0, index($0, "=") + 1)
                gsub(/^[[:space:]\r]+|[[:space:]\r]+$/, "", value)
                print value
                exit
            }
        }
    ' "${SOURCE_DIR}/theme.conf"
}

# ============================================================
# VALIDAR TEMA
# ============================================================
validate_source() {
    step "Validando archivos del tema"

    local f
    for f in Main.qml VideoBackground.qml metadata.desktop theme.conf; do
        [[ -f "${SOURCE_DIR}/${f}" ]] || fail "Falta ${SOURCE_DIR}/${f}"
    done

    grep -Eq '^QtVersion[[:space:]]*=[[:space:]]*6[[:space:]]*$' "${SOURCE_DIR}/metadata.desktop" \
        || fail "metadata.desktop debe contener QtVersion=6"

    local bg_type enable_video image video fallback
    bg_type="$(read_theme_value BackgroundType || true)"
    enable_video="$(read_theme_value EnableVideo || true)"
    image="$(read_theme_value BackgroundImage || true)"
    video="$(read_theme_value BackgroundVideo || true)"
    fallback="$(read_theme_value BackgroundVideoFallbackGif || true)"

    if [[ -n "$image" && ! -f "${SOURCE_DIR}/${image}" ]]; then
        warn "No existe la imagen configurada: ${SOURCE_DIR}/${image}"
    fi

    if [[ "$bg_type" == "video" && "$enable_video" == "true" ]]; then
        [[ -n "$video" ]] || fail "BackgroundType=video y EnableVideo=true, pero BackgroundVideo está vacío"
        if [[ ! -f "${SOURCE_DIR}/${video}" ]]; then
            warn "No existe el video configurado (${video}); se usará el GIF o la imagen de respaldo."
        fi
    fi

    if [[ -n "$fallback" && ! -f "${SOURCE_DIR}/${fallback}" ]]; then
        warn "No existe el GIF configurado: ${SOURCE_DIR}/${fallback}"
    fi

    ok "✓ Validación completada"
}

# ============================================================
# COPIAR TEMA
# Los videos/GIF (no van en Git) y theme.conf.user quedan protegidos:
# --delete no los borra del destino al actualizar.
# ============================================================
copy_theme() {
    step "Instalando Rollo Warrior"

    install -d -m 0755 "$THEME_DEST"
    rsync -a --delete \
        --exclude '.git/' --exclude '.github/' --exclude '.gitignore' \
        --exclude 'install-theme.sh' --exclude '*.bak' --exclude '*~' \
        --filter='P assets/videos/***' \
        --filter='P assets/gif/***' \
        --filter='P theme.conf.user' \
        "${SOURCE_DIR}/" "${THEME_DEST}/"

    chown -R root:root "$THEME_DEST"
    find "$THEME_DEST" -type d -exec chmod 0755 {} +
    find "$THEME_DEST" -type f -exec chmod 0644 {} +

    ok "✓ Tema instalado en ${THEME_DEST}"
}

# ============================================================
# CONFIGURAR SDDM
# ============================================================
warn_conflicts() {
    local f
    while IFS= read -r f; do
        [[ "$f" == "$SDDM_CONF" ]] && continue
        warn "Otro archivo también define 'Current=' y podría pisar el tema: ${f}"
    done < <(grep -lsE '^[[:space:]]*Current=' /etc/sddm.conf /etc/sddm.conf.d/*.conf 2>/dev/null || true)
}

configure_theme() {
    step "Configurando SDDM"

    install -d -m 0755 /etc/sddm.conf.d

    {
        # El greeter X11 solo se fuerza si Xorg está instalado.
        if command -v Xorg >/dev/null 2>&1; then
            printf '[General]\nDisplayServer=x11\n\n'
        else
            warn "Xorg no está instalado; no se fuerza DisplayServer=x11."
        fi
        printf '[Theme]\nCurrent=%s\n' "$THEME_NAME"
    } > "$SDDM_CONF"
    chmod 0644 "$SDDM_CONF"

    warn_conflicts
    ok "✓ Configuración creada"
    note "$SDDM_CONF"
}

# ============================================================
# DISPLAY MANAGER
# ============================================================
unit_exists() { systemctl cat "$1" >/dev/null 2>&1; }

get_current_display_manager() {
    if [[ -L /etc/systemd/system/display-manager.service ]]; then
        readlink -f /etc/systemd/system/display-manager.service
    fi
    return 0
}

find_alt_dm() {
    local u
    for u in lightdm gdm gdm3 lxdm ly; do
        if unit_exists "${u}.service"; then printf '%s' "$u"; return 0; fi
    done
    return 0
}

show_display_manager() {
    local manager
    manager="$(get_current_display_manager)"
    [[ -n "$manager" ]] || manager="Ninguno configurado"
    echo
    gum style --border rounded --padding "0 2" --foreground "#ffffff" "Display Manager actual:

${manager}"
}

repair_components() {
    show_section "Reparar componentes"
    note "Comprobando los componentes necesarios..."
    echo
    gum spin --spinner dot --title "Verificando e instalando componentes..." --show-output -- \
        "${PM_INSTALL[@]}" gum "${PKGS[@]}"
    ok "✓ Componentes verificados correctamente"
    echo

    if [[ ! -f "${THEME_DEST}/Main.qml" ]]; then
        caution "⚠ El tema no parece estar instalado correctamente."
        echo
        if gum confirm "¿Deseas reinstalar el tema automáticamente?"; then
            ensure_source
            validate_source
            copy_theme
            configure_theme
        fi
    else
        ok "✓ Los archivos principales del tema están presentes"
    fi

    echo
    box "$ACCENT" "✓ REPARACIÓN FINALIZADA"
}

disable_sddm() {
    local alt
    alt="$(find_alt_dm)"
    show_section "Desactivar SDDM"

    if [[ -n "$alt" ]]; then
        gum style --border rounded --padding "1 3" --foreground "#ffffff" \
            "Se detectó un Display Manager alternativo:

${alt}"
        echo
        caution "⚠ SDDM será desactivado. Después podrás configurar otro Display Manager."
    else
        box "#ffaa66" "⚠ NO SE DETECTÓ OTRO DISPLAY MANAGER

Si desactivas SDDM, el sistema arrancará en modo TTY
y deberás iniciar sesión manualmente."
    fi

    echo
    if gum confirm "¿Deseas desactivar SDDM?"; then
        systemctl disable sddm.service
        echo
        box "$ACCENT" "✓ SDDM fue desactivado correctamente"
        echo
        gum style --foreground "#ffffff" --bold "🔄 Para aplicar los cambios utiliza:

sudo reboot"
    else
        note "Operación cancelada"
    fi
}

activate_sddm() {
    local current option u
    show_section "Gestión de SDDM"
    current="$(get_current_display_manager)"

    if [[ "$current" == *"sddm.service"* ]]; then
        box "$ACCENT" "✓ SDDM YA ESTÁ CONFIGURADO

SDDM es actualmente el Display Manager del sistema."
        echo

        option="$(gum choose \
            --header="Selecciona una opción:" \
            --cursor="❯ " --cursor-prefix=" " \
            --selected.foreground="$ACCENT" --cursor.foreground="$ACCENT" \
            "🔧 Reparar componentes faltantes" \
            "⏻ Desactivar SDDM" \
            "↩ Volver al menú")" || return 0

        case "$option" in
            "🔧 Reparar componentes faltantes") repair_components ;;
            "⏻ Desactivar SDDM")               disable_sddm ;;
        esac
        return 0
    fi

    show_display_manager
    echo
    caution "⚠ Esta acción cambiará el Display Manager para el próximo arranque."
    echo

    if gum confirm "¿Deseas activar SDDM para el próximo reinicio?"; then
        for u in lightdm gdm gdm3 lxdm ly; do
            systemctl disable "${u}.service" >/dev/null 2>&1 || true
        done
        systemctl enable sddm.service --force

        # Debian/Ubuntu guardan además el DM por defecto en este archivo.
        if [[ "$PM" == "apt" && -d /etc/X11 ]]; then
            echo /usr/bin/sddm > /etc/X11/default-display-manager
        fi

        echo
        box "$ACCENT" "✓ SDDM fue habilitado correctamente"
        echo
        gum style --foreground "#ffffff" --bold "🔄 Para aplicar los cambios utiliza:

sudo reboot"
    else
        note "Operación cancelada"
    fi
}

restore_lightdm() {
    show_section "Restaurar LightDM"

    if ! unit_exists lightdm.service; then
        warn "LightDM no está instalado"
        return 0
    fi

    if gum confirm "¿Deseas restaurar LightDM para el próximo reinicio?"; then
        systemctl disable sddm.service || true
        systemctl enable lightdm.service --force
        echo
        ok "✓ LightDM fue restaurado correctamente"
        show_display_manager
    else
        note "Operación cancelada"
    fi
}

# ============================================================
# DIAGNÓSTICO
# ============================================================
system_diagnostics() {
    show_section "Diagnóstico completo"
    MISSING=0
    local pkg ver m f manager

    ok "📦 PAQUETES (${PM})"
    for pkg in "${PKGS[@]}" gum; do
        ver="$(pkg_version "$pkg")"
        if [[ -n "$ver" ]]; then mark_ok "${pkg}  (${ver})"; else mark_bad "${pkg} — NO INSTALADO"; fi
    done

    echo
    ok "⚙️  COMPONENTES"
    if command -v sddm >/dev/null 2>&1; then mark_ok "sddm"; else mark_bad "sddm no encontrado"; fi
    if command -v sddm-greeter-qt6 >/dev/null 2>&1; then mark_ok "sddm-greeter-qt6"; else mark_bad "sddm-greeter-qt6 no encontrado"; fi
    for m in QtQuick/Window QtMultimedia; do
        if qml_module_exists "$m"; then
            mark_ok "módulo QML ${m//\//.}"
        else
            mark_bad "módulo QML ${m//\//.} no encontrado (QtMultimedia solo es necesario para video)"
        fi
    done

    echo
    ok "🎨 TEMA ROLLO WARRIOR"
    if [[ -d "$THEME_DEST" ]]; then
        mark_ok "directorio del tema"
        for f in Main.qml VideoBackground.qml metadata.desktop theme.conf; do
            if [[ -f "${THEME_DEST}/${f}" ]]; then mark_ok "$f"; else mark_bad "falta ${f}"; fi
        done
    else
        mark_bad "el tema no está instalado"
    fi

    echo
    ok "⚙️  CONFIGURACIÓN DE SDDM"
    if [[ -f "$SDDM_CONF" ]]; then
        if grep -q "^Current=${THEME_NAME}$" "$SDDM_CONF"; then
            mark_ok "Rollo Warrior está configurado como tema"
        else
            mark_bad "el archivo existe, pero el tema configurado no coincide"
        fi
    else
        mark_bad "no existe ${SDDM_CONF}"
    fi
    warn_conflicts

    echo
    ok "🖥️  DISPLAY MANAGER"
    manager="$(get_current_display_manager)"
    gum style --border rounded --padding "0 2" --foreground "#ffffff" "${manager:-No detectado}"
    if systemctl is-enabled sddm.service >/dev/null 2>&1; then
        mark_ok "SDDM habilitado para iniciar con el sistema"
    else
        mark_bad "SDDM no está habilitado"
    fi

    echo
    if [[ "$MISSING" -eq 0 ]]; then
        box "$ACCENT" "✓ DIAGNÓSTICO COMPLETADO

Todo lo necesario está instalado correctamente."
    else
        box "#ffaa66" "⚠ DIAGNÓSTICO CON PROBLEMAS

Problemas encontrados: ${MISSING}
Revisa los elementos marcados con ✗."
    fi
    note "Si el login falla: journalctl -u sddm -b --no-pager | tail -60"

    pause_menu
}

# ============================================================
# PRUEBAS
# ============================================================
run_test_local() {
    show_section "Prueba local del tema"
    gum style --border rounded --padding "1 2" --foreground "#ffffff" \
        "EJECUTANDO:

sddm-greeter-qt6 --test-mode --theme ${THEME_DEST}"
    echo
    note "Cierra la ventana de prueba cuando termines."
    echo

    if [[ "$REAL_USER" == "root" ]]; then
        sddm-greeter-qt6 --test-mode --theme "$THEME_DEST" || true
    else
        runuser -u "$REAL_USER" -- env \
            XDG_RUNTIME_DIR="/run/user/$(id -u "$REAL_USER")" \
            WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}" \
            DISPLAY="${DISPLAY:-:0}" \
            sddm-greeter-qt6 --test-mode --theme "$THEME_DEST" || true
    fi

    echo
    note "Si no abre ventana, ejecuta ese comando en tu terminal (sin sudo)."
    note "El mensaje sobre el socket en modo de prueba es normal."
    pause_menu
}

check_qt6() {
    show_section "Comprobar Qt 6"
    local result=""
    if [[ -f "${THEME_DEST}/metadata.desktop" ]]; then
        result="$(grep '^QtVersion=' "${THEME_DEST}/metadata.desktop" || true)"
        if [[ "$result" == "QtVersion=6" ]]; then
            box "$ACCENT" "✓ CORRECTO

${result}"
        else
            box "#ffaa66" "⚠ CONFIGURACIÓN NO ESPERADA

${result:-No se encontró QtVersion=6}"
        fi
    else
        gum style --foreground "#ff7777" --bold "✗ No existe metadata.desktop"
    fi
    pause_menu
}

check_video_config() {
    show_section "Comprobar configuración de video"
    local result=""
    if [[ -f "${THEME_DEST}/theme.conf" ]]; then
        result="$(grep -E '^(BackgroundType|EnableVideo|BackgroundVideo)=' "${THEME_DEST}/theme.conf" || true)"
        if [[ -n "$result" ]]; then
            box "$ACCENT" "✓ CONFIGURACIÓN ENCONTRADA

${result}"
        else
            box "#ffaa66" "⚠ NO SE ENCONTRÓ

BackgroundVideo no está configurado."
        fi
    else
        gum style --foreground "#ff7777" --bold "✗ No existe theme.conf"
    fi
    pause_menu
}

list_video_files() {
    show_section "Archivos de video"
    local dir="${THEME_DEST}/assets/videos" files=""
    gum style --border rounded --padding "1 2" --foreground "#ffffff" "DIRECTORIO:

${dir}"
    echo

    if [[ -d "$dir" ]]; then
        files="$(find "$dir" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null || true)"
        if [[ -n "$files" ]]; then
            box "$ACCENT" "✓ ARCHIVOS ENCONTRADOS

${files}"
            echo
            ls -lh "$dir"
        else
            box "#ffaa66" "⚠ EL DIRECTORIO ESTÁ VACÍO

Copia tu video aquí con:
sudo cp mi-video.mp4 ${dir}/"
        fi
    else
        box "#ff7777" "✗ NO EXISTE EL DIRECTORIO

${dir}"
    fi
    pause_menu
}

print_test_commands() {
    local option
    while true; do
        show_section "Pruebas del tema"

        option="$(gum choose \
            --header="Usa ↑ ↓ para navegar y ENTER para seleccionar:" \
            --cursor="❯ " --cursor-prefix=" " \
            --selected.foreground="$ACCENT" --cursor.foreground="$ACCENT" \
            "🔎 Diagnóstico completo del sistema" \
            "🧪 Ejecutar prueba local del tema" \
            "🔍 Comprobar Qt 6" \
            "🎬 Comprobar configuración de video" \
            "📁 Ver archivos de video" \
            "↩ Volver al menú principal")" || return 0

        case "$option" in
            "🔎 Diagnóstico completo del sistema")  system_diagnostics ;;
            "🧪 Ejecutar prueba local del tema")    run_test_local ;;
            "🔍 Comprobar Qt 6")                    check_qt6 ;;
            "🎬 Comprobar configuración de video")  check_video_config ;;
            "📁 Ver archivos de video")             list_video_files ;;
            *)                                      return 0 ;;
        esac
    done
}

# ============================================================
# INSTALACIÓN Y ACTUALIZACIÓN
# ============================================================
do_install() {
    show_section "Instalación de Rollo Warrior"

    install_packages
    ensure_source
    validate_source
    copy_theme
    configure_theme
    show_display_manager

    echo
    box "$ACCENT" "✓ INSTALACIÓN TERMINADA

El tema fue instalado. Pruébalo (en tu terminal, sin sudo):

sddm-greeter-qt6 --test-mode --theme ${THEME_DEST}"
}

do_update() {
    show_section "Actualizar Rollo Warrior"

    if [[ "$SOURCE_DIR" == "$LOCAL_CLONE" ]]; then
        ensure_source
    elif [[ -d "${SOURCE_DIR}/.git" ]]; then
        run_as_real_user git -C "$SOURCE_DIR" pull --ff-only \
            || warn "No se pudo actualizar desde GitHub; se usan los archivos locales."
    fi

    validate_source
    copy_theme
    configure_theme

    echo
    ok "✓ Actualización completada"
}

# ============================================================
# MENÚ PRINCIPAL
# ============================================================
show_menu() {
    gum choose \
        --header="Selecciona una opción:" \
        --cursor="❯ " --cursor-prefix=" " \
        --selected.foreground="$ACCENT" --cursor.foreground="$ACCENT" \
        "🎨 Instalar o reparar tema" \
        "🔄 Actualizar desde GitHub" \
        "🧪 Probar y mostrar comandos" \
        "⚙ Gestionar SDDM" \
        "↩ Restaurar LightDM" \
        "🚪 Salir"
}

main() {
    require_root
    ensure_gum

    local option
    while true; do
        show_header
        option="$(show_menu)" || option="🚪 Salir"

        case "$option" in
            "🎨 Instalar o reparar tema")   do_install;          pause_menu ;;
            "🔄 Actualizar desde GitHub")   do_update;           pause_menu ;;
            "🧪 Probar y mostrar comandos") print_test_commands ;;
            "⚙ Gestionar SDDM")             activate_sddm;       pause_menu ;;
            "↩ Restaurar LightDM")          restore_lightdm;     pause_menu ;;
            "🚪 Salir")
                clear
                gum style --border rounded --padding "1 3" --bold --foreground "$ACCENT" \
                    "Gracias por usar

R O L L O   W A R R I O R"
                exit 0
                ;;
        esac
    done
}

main "$@"