#!/usr/bin/env bash

set -Eeuo pipefail


# ============================================================
# CONFIGURACIÓN DEL PROYECTO
# ============================================================

REPO_URL="https://github.com/Tecdroid214/rollo-warrior.git"

THEME_NAME="rollo-warrior"

THEME_DEST="/usr/share/sddm/themes/${THEME_NAME}"

SDDM_CONF="/etc/sddm.conf.d/10-${THEME_NAME}.conf"


# ============================================================
# DETECCIÓN DEL DIRECTORIO Y USUARIO REAL
# ============================================================

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd -P
)"

REAL_USER="${SUDO_USER:-$(id -un)}"

REAL_HOME="$(
    getent passwd "$REAL_USER" | cut -d: -f6
)"

LOCAL_CLONE="${REAL_HOME}/rollo-warrior"


if [[ -f "${SCRIPT_DIR}/Main.qml" &&
      -f "${SCRIPT_DIR}/metadata.desktop" ]]; then

    SOURCE_DIR="$SCRIPT_DIR"

else

    SOURCE_DIR="$LOCAL_CLONE"

fi


# ============================================================
# FUNCIONES DE MENSAJES
# ============================================================

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
        "${BASH_LINENO[0]:-desconocida}" \
        "$exit_code" >&2

    exit "$exit_code"
}


trap on_error ERR


# ============================================================
# INTERFAZ VISUAL
# ============================================================

show_header() {

    clear


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        '
 ██████╗  ██████╗ ██╗     ██╗      ██████╗
 ██╔══██╗██╔═══██╗██║     ██║     ██╔═══██╗
 ██████╔╝██║   ██║██║     ██║     ██║   ██║
 ██╔══██╗██║   ██║██║     ██║     ██║   ██║
 ██║  ██║╚██████╔╝███████╗███████╗╚██████╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝ ╚═════╝'


    gum style \
        --foreground "#ffffff" \
        --bold \
        --align center \
        --width 58 \
        "W A R R I O R"


    gum style \
        --foreground "#888888" \
        --align center \
        --width 58 \
        "SDDM Theme Installer · v0.4"


    echo


    gum style \
        --foreground "#555555" \
        "────────────────────────────────────────────────────────"

}


show_section() {

    local title="$1"

    show_header

    echo


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        --border rounded \
        --padding "0 3" \
        "$title"


    echo

}


pause_menu() {

    echo

    gum input \
        --placeholder="Presiona ENTER para volver al menú" \
        >/dev/null

}


# ============================================================
# COMPROBACIONES
# ============================================================

require_root() {

    [[ $EUID -eq 0 ]] || fail \
        "Ejecuta este script con:

sudo ./install-theme.sh"

}


ensure_gum() {

    if command -v gum >/dev/null 2>&1; then
        return 0
    fi

    clear

    printf '\n'
    printf '========================================\n'
    printf '   Preparando Rollo Warrior Installer\n'
    printf '========================================\n'
    printf '\n'
    printf 'Gum no está instalado.\n'
    printf 'Instalándolo automáticamente...\n'
    printf '\n'

    pacman -S --needed --noconfirm gum

    command -v gum >/dev/null 2>&1 || \
        fail "No fue posible instalar Gum automáticamente."

    clear

    gum style \
        --border rounded \
        --padding "1 3" \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Gum fue instalado correctamente"
}


# ============================================================
# EJECUTAR COMO USUARIO REAL
# ============================================================

run_as_real_user() {

    if [[ "$REAL_USER" == "root" ]]; then

        "$@"

    else

        runuser -u "$REAL_USER" -- "$@"

    fi

}


# ============================================================
# OBTENER FUENTE DEL TEMA
# ============================================================

ensure_source() {

    if [[ -f "${SOURCE_DIR}/Main.qml" &&
          -f "${SOURCE_DIR}/metadata.desktop" ]]; then

        return

    fi


    log "Clonando el repositorio en ${LOCAL_CLONE}"


    rm -rf -- "$LOCAL_CLONE"


    run_as_real_user \
        git clone "$REPO_URL" "$LOCAL_CLONE"


    SOURCE_DIR="$LOCAL_CLONE"

}


# ============================================================
# DEPENDENCIAS
# ============================================================

install_packages() {

    show_section "Instalando dependencias"

    gum spin \
        --spinner dot \
        --title "Instalando dependencias necesarias..." \
        -- \
        pacman -S \
            --needed \
            --noconfirm \
            git \
            rsync \
            gum \
            sddm \
            qt6-declarative \
            qt6-svg \
            qt6-multimedia-ffmpeg

    echo

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Dependencias verificadas correctamente"

}


# ============================================================
# LEER THEME.CONF
# ============================================================

read_theme_value() {

    local key="$1"

    local file="${SOURCE_DIR}/theme.conf"


    awk -F= -v wanted="$key" '

        $0 !~ /^[[:space:]]*[;#]/ {

            current=$1

            gsub(
                /^[[:space:]]+|[[:space:]]+$/,
                "",
                current
            )

            if (current == wanted) {

                value=substr(
                    $0,
                    index($0, "=") + 1
                )

                gsub(
                    /^[[:space:]]+|[[:space:]]+$/,
                    "",
                    value
                )

                print value

                exit
            }

        }

    ' "$file"

}


# ============================================================
# VALIDAR TEMA
# ============================================================

validate_source() {

    show_section "Validando archivos del tema"


    local required_files=(

        "Main.qml"
        "VideoBackground.qml"
        "metadata.desktop"
        "theme.conf"

    )


    local file


    for file in "${required_files[@]}"; do

        [[ -f "${SOURCE_DIR}/${file}" ]] || \
            fail "Falta ${SOURCE_DIR}/${file}"

    done


    grep -Eq \
        '^QtVersion[[:space:]]*=[[:space:]]*6[[:space:]]*$' \
        "${SOURCE_DIR}/metadata.desktop" \
        || fail "metadata.desktop debe contener QtVersion=6"


    local background_type
    local enable_video
    local image_path
    local video_path
    local fallback_path


    background_type="$(
        read_theme_value BackgroundType || true
    )"


    enable_video="$(
        read_theme_value EnableVideo || true
    )"


    image_path="$(
        read_theme_value BackgroundImage || true
    )"


    video_path="$(
        read_theme_value BackgroundVideo || true
    )"


    fallback_path="$(
        read_theme_value BackgroundVideoFallbackGif || true
    )"


    if [[ -n "$image_path" &&
          ! -f "${SOURCE_DIR}/${image_path}" ]]; then

        warn \
            "No existe la imagen configurada:
${SOURCE_DIR}/${image_path}"

    fi


    if [[ "$background_type" == "video" &&
          "$enable_video" == "true" ]]; then


        if [[ -z "$video_path" ]]; then

            fail \
                "BackgroundType=video y EnableVideo=true,
pero BackgroundVideo está vacío"

        fi


        if [[ ! -f "${SOURCE_DIR}/${video_path}" ]]; then

            warn \
                "No existe el video configurado.
Se utilizará el GIF o imagen de respaldo."

        fi

    fi


    if [[ -n "$fallback_path" &&
          ! -f "${SOURCE_DIR}/${fallback_path}" ]]; then

        warn \
            "No existe el GIF configurado:
${SOURCE_DIR}/${fallback_path}"

    fi


    echo


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Validación completada"

}


# ============================================================
# COPIAR TEMA
# ============================================================

copy_theme() {

    show_section "Instalando Rollo Warrior"


    gum spin \
        --spinner dot \
        --title "Copiando archivos del tema..." \
        --show-output \
        -- \
        bash -c "

            install -d -m 0755 '${THEME_DEST}'

            rsync -a --delete \
                --exclude '.git/' \
                --exclude '.github/' \
                --exclude 'install-theme.sh' \
                --exclude '*.bak' \
                --exclude '*~' \
                '${SOURCE_DIR}/' \
                '${THEME_DEST}/'

            chown -R root:root '${THEME_DEST}'

            find '${THEME_DEST}' \
                -type d \
                -exec chmod 0755 {} +

            find '${THEME_DEST}' \
                -type f \
                -exec chmod 0644 {} +

        "


    echo


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Tema instalado correctamente"

}


# ============================================================
# CONFIGURAR SDDM
# ============================================================

configure_theme() {

    show_section "Configurando SDDM"


    install -d \
        -m 0755 \
        /etc/sddm.conf.d


    cat > "$SDDM_CONF" <<CONF
[General]
DisplayServer=x11

[Theme]
Current=${THEME_NAME}
CONF


    chmod 0644 "$SDDM_CONF"


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Configuración creada correctamente"


    echo


    gum style \
        --foreground "#888888" \
        "${SDDM_CONF}"

}


# ============================================================
# DISPLAY MANAGER ACTUAL
# ============================================================

show_display_manager() {

    local manager="ninguno"


    if [[ -L /etc/systemd/system/display-manager.service ]]; then

        manager="$(
            readlink -f \
            /etc/systemd/system/display-manager.service
        )"

    fi


    echo


    gum style \
        --border rounded \
        --padding "0 2" \
        --foreground "#ffffff" \
        "Display Manager actual:

${manager}"

}


# ============================================================
# GESTIONAR SDDM
# ============================================================

get_current_display_manager() {

    local manager=""

    if [[ -L /etc/systemd/system/display-manager.service ]]; then

        manager="$(
            readlink -f \
            /etc/systemd/system/display-manager.service
        )"

    fi

    printf '%s' "$manager"

}


show_display_manager() {

    local manager

    manager="$(get_current_display_manager)"

    [[ -n "$manager" ]] || manager="Ninguno configurado"


    echo


    gum style \
        --border rounded \
        --padding "0 2" \
        --foreground "#ffffff" \
        "Display Manager actual:

${manager}"

}


activate_sddm() {

    local current_manager

    show_section "Gestión de SDDM"

    current_manager="$(get_current_display_manager)"


    # --------------------------------------------------------
    # SDDM YA ESTÁ ACTIVO
    # --------------------------------------------------------

    if [[ "$current_manager" == *"sddm.service"* ]]; then


        gum style \
            --border rounded \
            --padding "1 3" \
            --foreground "#c6f4eb" \
            --bold \
            "✓ SDDM YA ESTÁ CONFIGURADO

SDDM es actualmente el Display Manager
del sistema."


        echo


        option="$(
            gum choose \
                --header="Selecciona una opción:" \
                --cursor="❯ " \
                --cursor-prefix=" " \
                --selected.foreground="#c6f4eb" \
                --cursor.foreground="#c6f4eb" \
                "🔧 Reparar componentes faltantes" \
                "⏻ Desactivar SDDM" \
                "↩ Volver al menú"
        )"


        case "$option" in


            "🔧 Reparar componentes faltantes")

                repair_components
                ;;


            "⏻ Desactivar SDDM")

                disable_sddm
                ;;


            "↩ Volver al menú")

                return
                ;;

        esac


        return

    fi


    # --------------------------------------------------------
    # SDDM NO ESTÁ ACTIVO
    # --------------------------------------------------------

    show_display_manager


    echo


    gum style \
        --foreground "#ffaa66" \
        --bold \
        "⚠ Esta acción cambiará el Display Manager
para el próximo arranque."


    echo


    if gum confirm \
        "¿Deseas activar SDDM para el próximo reinicio?"; then


        # Desactivar otros Display Managers conocidos

        systemctl disable lightdm.service \
            >/dev/null 2>&1 || true

        systemctl disable gdm.service \
            >/dev/null 2>&1 || true

        systemctl disable lxdm.service \
            >/dev/null 2>&1 || true

        systemctl disable ly.service \
            >/dev/null 2>&1 || true


        # Activar SDDM

        systemctl enable sddm.service --force


        echo


        gum style \
            --border rounded \
            --padding "1 3" \
            --foreground "#c6f4eb" \
            --bold \
            "✓ SDDM fue habilitado correctamente"


        echo


        gum style \
            --foreground "#ffffff" \
            --bold \
            "🔄 Para aplicar los cambios utiliza:

sudo reboot"


    else


        gum style \
            --foreground "#888888" \
            "Operación cancelada"

    fi

}

# ============================================================
# DESACTIVAR SDDM
# ============================================================

disable_sddm() {

    local alternative_manager=""

    show_section "Desactivar SDDM"


    # Buscar Display Managers alternativos instalados

    if systemctl list-unit-files \
        lightdm.service >/dev/null 2>&1; then

        alternative_manager="LightDM"

    elif systemctl list-unit-files \
        gdm.service >/dev/null 2>&1; then

        alternative_manager="GDM"

    elif systemctl list-unit-files \
        lxdm.service >/dev/null 2>&1; then

        alternative_manager="LXDM"

    elif systemctl list-unit-files \
        ly.service >/dev/null 2>&1; then

        alternative_manager="Ly"

    fi


    # --------------------------------------------------------
    # HAY OTRO DISPLAY MANAGER
    # --------------------------------------------------------

    if [[ -n "$alternative_manager" ]]; then


        gum style \
            --border rounded \
            --padding "1 3" \
            --foreground "#ffffff" \
            "Se detectó un Display Manager alternativo:

${alternative_manager}"


        echo


        gum style \
            --foreground "#ffaa66" \
            --bold \
            "⚠ SDDM será desactivado.

Después podrás configurar otro Display Manager."


    # --------------------------------------------------------
    # NO HAY OTRO DISPLAY MANAGER
    # --------------------------------------------------------

    else


        gum style \
            --border rounded \
            --padding "1 3" \
            --foreground "#ffaa66" \
            --bold \
            "⚠ NO SE DETECTÓ OTRO DISPLAY MANAGER

Si desactivas SDDM, el sistema arrancará
en modo TTY después del reinicio.

Deberás iniciar sesión manualmente:

Usuario:
Contraseña:"


    fi


    echo


    if gum confirm \
        "¿Deseas desactivar SDDM?"; then


        systemctl disable sddm.service


        echo


        gum style \
            --border rounded \
            --padding "1 3" \
            --foreground "#c6f4eb" \
            --bold \
            "✓ SDDM fue desactivado correctamente"


        echo


        if [[ -z "$alternative_manager" ]]; then


            gum style \
                --foreground "#ffaa66" \
                "El próximo inicio será en modo TTY.

Desde allí deberás iniciar sesión
con tu usuario y contraseña."


        else


            gum style \
                --foreground "#ffffff" \
                "Display Manager alternativo detectado:

${alternative_manager}"

        fi


        echo


        gum style \
            --foreground "#ffffff" \
            --bold \
            "🔄 Para aplicar los cambios utiliza:

sudo reboot"


    else


        gum style \
            --foreground "#888888" \
            "Operación cancelada"

    fi

}

# ============================================================
# REPARAR COMPONENTES
# ============================================================

repair_components() {

    show_section "Reparar componentes"


    gum style \
        --foreground "#888888" \
        "Comprobando los componentes necesarios..."


    echo


    gum spin \
        --spinner dot \
        --title "Verificando e instalando componentes faltantes..." \
        -- \
        pacman -S \
            --needed \
            --noconfirm \
            gum \
            git \
            rsync \
            sddm \
            qt6-declarative \
            qt6-svg \
            qt6-multimedia-ffmpeg


    echo


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Componentes verificados correctamente"


    echo


    # Verificar tema

    if [[ ! -f "${THEME_DEST}/Main.qml" ]]; then


        gum style \
            --foreground "#ffaa66" \
            "⚠ El tema no parece estar instalado correctamente."

        echo

        if gum confirm \
            "¿Deseas reinstalar el tema automáticamente?"; then


            ensure_source

            validate_source

            copy_theme

            configure_theme

        fi


    else


        gum style \
            --foreground "#c6f4eb" \
            "✓ Los archivos principales del tema están presentes"

    fi


    echo


    gum style \
        --border rounded \
        --padding "1 3" \
        --foreground "#c6f4eb" \
        --bold \
        "✓ REPARACIÓN FINALIZADA"

}

# ============================================================
# RESTAURAR LIGHTDM
# ============================================================

restore_lightdm() {

    show_section "Restaurar LightDM"


    if ! systemctl list-unit-files \
        lightdm.service >/dev/null 2>&1; then

        fail "LightDM no está instalado"

    fi


    if gum confirm \
        "¿Deseas restaurar LightDM para el próximo reinicio?"; then


        systemctl disable sddm.service || true

        systemctl enable lightdm.service --force


        echo


        gum style \
            --foreground "#c6f4eb" \
            --bold \
            "✓ LightDM fue restaurado correctamente"


        show_display_manager


    else

        gum style \
            --foreground "#888888" \
            "Operación cancelada"

    fi

}


# ============================================================
# ACTUALIZAR REPOSITORIO
# ============================================================

update_repository() {

    ensure_source


    if [[ -d "${SOURCE_DIR}/.git" ]]; then


        gum spin \
            --spinner dot \
            --title "Actualizando desde GitHub..." \
            --show-output \
            -- \
            runuser \
                -u "$REAL_USER" \
                -- \
                git \
                -C "$SOURCE_DIR" \
                pull \
                --ff-only \
                origin \
                main


    else

        warn \
            "${SOURCE_DIR} no es un repositorio Git.

Se utilizarán los archivos locales actuales."

    fi

}

# ============================================================
# DIAGNÓSTICO COMPLETO DEL SISTEMA
# ============================================================

system_diagnostics() {

    show_section "Diagnóstico completo"

    local packages=(
        "sddm"
        "qt6-declarative"
        "qt6-svg"
        "qt6-multimedia-ffmpeg"
        "git"
        "rsync"
        "gum"
    )

    local package
    local version
    local installed_count=0
    local missing_count=0


    gum style \
        --border rounded \
        --padding "1 2" \
        --foreground "#ffffff" \
        --width 78 \
        "COMPROBANDO COMPONENTES NECESARIOS

Esta prueba verifica las dependencias necesarias para:

• Instalación del tema
• Funcionamiento de SDDM
• Interfaz Qt 6
• Prueba local del tema"


    echo


    # --------------------------------------------------------
    # PAQUETES DEL SISTEMA
    # --------------------------------------------------------

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "📦 PAQUETES INSTALADOS"


    echo


    for package in "${packages[@]}"; do

        if pacman -Q "$package" >/dev/null 2>&1; then

            version="$(
                pacman -Q "$package" |
                awk '{print $2}'
            )"

            printf '  '

            gum style \
                --foreground "#c6f4eb" \
                --bold \
                "✓ ${package}"

            printf '    '

            gum style \
                --foreground "#888888" \
                "Versión: ${version}"

            ((installed_count++)) || true

        else

            printf '  '

            gum style \
                --foreground "#ff7777" \
                --bold \
                "✗ ${package}"

            printf '    '

            gum style \
                --foreground "#ff7777" \
                "NO INSTALADO"

            ((missing_count++)) || true

        fi

    done


    echo
    echo


    # --------------------------------------------------------
    # COMPROBAR EJECUTABLES
    # --------------------------------------------------------

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "⚙️ EJECUTABLES"


    echo


    if command -v sddm >/dev/null 2>&1; then

        gum style \
            --foreground "#c6f4eb" \
            "✓ sddm encontrado"

    else

        gum style \
            --foreground "#ff7777" \
            "✗ Ejecutable sddm no encontrado"

        ((missing_count++)) || true

    fi


    if command -v sddm-greeter-qt6 >/dev/null 2>&1; then

        gum style \
            --foreground "#c6f4eb" \
            "✓ sddm-greeter-qt6 disponible"

    else

        gum style \
            --foreground "#ff7777" \
            "✗ sddm-greeter-qt6 no encontrado"

        ((missing_count++)) || true

    fi


    if command -v gum >/dev/null 2>&1; then

        gum style \
            --foreground "#c6f4eb" \
            "✓ gum disponible"

    else

        gum style \
            --foreground "#ff7777" \
            "✗ gum no encontrado"

        ((missing_count++)) || true

    fi


    echo
    echo


    # --------------------------------------------------------
    # COMPROBAR TEMA
    # --------------------------------------------------------

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "🎨 TEMA ROLLO WARRIOR"


    echo


    if [[ -d "$THEME_DEST" ]]; then

        gum style \
            --foreground "#c6f4eb" \
            "✓ Directorio del tema encontrado"

    else

        gum style \
            --foreground "#ff7777" \
            "✗ El tema no está instalado"

        ((missing_count++)) || true

    fi


    local theme_files=(
        "Main.qml"
        "VideoBackground.qml"
        "metadata.desktop"
        "theme.conf"
    )


    local file


    for file in "${theme_files[@]}"; do

        if [[ -f "${THEME_DEST}/${file}" ]]; then

            gum style \
                --foreground "#c6f4eb" \
                "✓ ${file}"

        else

            gum style \
                --foreground "#ff7777" \
                "✗ Falta ${file}"

            ((missing_count++)) || true

        fi

    done


    echo
    echo


    # --------------------------------------------------------
    # CONFIGURACIÓN DE SDDM
    # --------------------------------------------------------

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "⚙️ CONFIGURACIÓN DE SDDM"


    echo


    if [[ -f "$SDDM_CONF" ]]; then

        gum style \
            --foreground "#c6f4eb" \
            "✓ Archivo de configuración encontrado"

        echo

        if grep -q \
            "^Current=${THEME_NAME}$" \
            "$SDDM_CONF"; then

            gum style \
                --foreground "#c6f4eb" \
                "✓ Rollo Warrior está configurado como tema"

        else

            gum style \
                --foreground "#ffaa66" \
                "⚠ El archivo existe, pero el tema configurado no coincide"

            ((missing_count++)) || true

        fi

    else

        gum style \
            --foreground "#ff7777" \
            "✗ No existe ${SDDM_CONF}"

        ((missing_count++)) || true

    fi


    echo
    echo


    # --------------------------------------------------------
    # DISPLAY MANAGER
    # --------------------------------------------------------

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "🖥️ DISPLAY MANAGER"


    echo


    local manager="No detectado"


    if [[ -L /etc/systemd/system/display-manager.service ]]; then

        manager="$(
            readlink -f \
            /etc/systemd/system/display-manager.service
        )"

    fi


    gum style \
        --border rounded \
        --padding "0 2" \
        --foreground "#ffffff" \
        "${manager}"


    echo
    echo


    # --------------------------------------------------------
    # ESTADO DEL SERVICIO SDDM
    # --------------------------------------------------------

    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "🚀 ESTADO DE SDDM"


    echo


    if systemctl is-enabled sddm.service >/dev/null 2>&1; then

        gum style \
            --foreground "#c6f4eb" \
            "✓ SDDM está habilitado para iniciar con el sistema"

    else

        gum style \
            --foreground "#ffaa66" \
            "⚠ SDDM no está habilitado para iniciar automáticamente"

    fi


    echo
    echo


    # --------------------------------------------------------
    # RESULTADO FINAL
    # --------------------------------------------------------

    if [[ "$missing_count" -eq 0 ]]; then

        gum style \
            --border double \
            --padding "1 3" \
            --foreground "#c6f4eb" \
            --bold \
            "✓ DIAGNÓSTICO COMPLETADO

Todo lo necesario está instalado correctamente.

Paquetes comprobados: ${installed_count}

El sistema está preparado para:

✓ Usar SDDM
✓ Cargar el tema Rollo Warrior
✓ Ejecutar pruebas locales"

    else

        gum style \
            --border double \
            --padding "1 3" \
            --foreground "#ffaa66" \
            --bold \
            "⚠ DIAGNÓSTICO COMPLETADO CON PROBLEMAS

Paquetes correctos: ${installed_count}
Problemas encontrados: ${missing_count}

Revisa los elementos marcados con ✗."

    fi


    pause_menu
}


# ============================================================
# COMANDOS DE PRUEBA - SUBMENÚ INTERACTIVO
# ============================================================

show_test_panel() {

    gum style \
        --border rounded \
        --padding "1 2" \
        --foreground "#ffffff" \
        --width 78 \
        "PRUEBAS Y DIAGNÓSTICO

  🔎 Diagnóstico completo
     Comprueba paquetes, versiones, SDDM y el tema.

  🧪 Prueba local del tema
     Inicia SDDM Greeter en modo de prueba.

  🔍 Comprobar Qt 6
     Verifica que el tema esté configurado para Qt 6.

  🎬 Comprobar configuración de video
     Muestra el video configurado en theme.conf.

  📁 Ver archivos de video
     Lista los archivos disponibles.

  ↩ Volver al menú principal"
}


run_test_local() {

    show_section "Prueba local del tema"

    gum style \
        --border rounded \
        --padding "1 2" \
        --foreground "#ffffff" \
        "EJECUTANDO:

sddm-greeter-qt6 --test-mode --theme ${THEME_DEST}"

    echo

    gum style \
        --foreground "#888888" \
        "Cierra la ventana de prueba cuando termines."

    echo

    # Ejecutar como usuario real para evitar problemas
    # con permisos y variables gráficas.
    if [[ "$REAL_USER" == "root" ]]; then

        sddm-greeter-qt6 \
            --test-mode \
            --theme "$THEME_DEST" || true

    else

        runuser -u "$REAL_USER" -- \
            sddm-greeter-qt6 \
                --test-mode \
                --theme "$THEME_DEST" || true

    fi

    echo

    gum style \
        --foreground "#888888" \
        "El mensaje sobre socket en modo de prueba puede ser normal."

    pause_menu
}


check_qt6() {

    show_section "Comprobar Qt 6"

    gum style \
        --border rounded \
        --padding "1 2" \
        --foreground "#ffffff" \
        "COMANDO:

grep '^QtVersion=' ${THEME_DEST}/metadata.desktop"

    echo

    if [[ -f "${THEME_DEST}/metadata.desktop" ]]; then

        result="$(
            grep '^QtVersion=' \
                "${THEME_DEST}/metadata.desktop" || true
        )"

        if [[ "$result" == "QtVersion=6" ]]; then

            gum style \
                --border rounded \
                --padding "1 3" \
                --foreground "#c6f4eb" \
                --bold \
                "✓ CORRECTO

${result}"

        else

            gum style \
                --border rounded \
                --padding "1 3" \
                --foreground "#ffaa66" \
                --bold \
                "⚠ CONFIGURACIÓN NO ESPERADA

${result:-No se encontró QtVersion=6}"

        fi

    else

        gum style \
            --foreground "#ff7777" \
            --bold \
            "✗ No existe metadata.desktop"

    fi

    pause_menu
}


check_video_config() {

    show_section "Comprobar configuración de video"

    gum style \
        --border rounded \
        --padding "1 2" \
        --foreground "#ffffff" \
        "COMANDO:

grep '^BackgroundVideo=' ${THEME_DEST}/theme.conf"

    echo

    if [[ -f "${THEME_DEST}/theme.conf" ]]; then

        result="$(
            grep '^BackgroundVideo=' \
                "${THEME_DEST}/theme.conf" || true
        )"

        if [[ -n "$result" ]]; then

            gum style \
                --border rounded \
                --padding "1 3" \
                --foreground "#c6f4eb" \
                --bold \
                "✓ CONFIGURACIÓN ENCONTRADA

${result}"

        else

            gum style \
                --border rounded \
                --padding "1 3" \
                --foreground "#ffaa66" \
                --bold \
                "⚠ NO SE ENCONTRÓ

BackgroundVideo no está configurado."

        fi

    else

        gum style \
            --foreground "#ff7777" \
            --bold \
            "✗ No existe theme.conf"

    fi

    pause_menu
}


list_video_files() {

    show_section "Archivos de video"

    local video_dir="${THEME_DEST}/assets/videos"

    gum style \
        --border rounded \
        --padding "1 2" \
        --foreground "#ffffff" \
        "DIRECTORIO:

${video_dir}"

    echo

    if [[ -d "$video_dir" ]]; then

        files="$(
            find "$video_dir" \
                -maxdepth 1 \
                -type f \
                -printf '%f\n' \
                2>/dev/null || true
        )"

        if [[ -n "$files" ]]; then

            gum style \
                --border rounded \
                --padding "1 3" \
                --foreground "#c6f4eb" \
                --bold \
                "✓ ARCHIVOS ENCONTRADOS

${files}"

            echo

            gum style \
                --foreground "#888888" \
                "Información detallada:"

            ls -lh "$video_dir"

        else

            gum style \
                --border rounded \
                --padding "1 3" \
                --foreground "#ffaa66" \
                --bold \
                "⚠ EL DIRECTORIO ESTÁ VACÍO"

        fi

    else

        gum style \
            --border rounded \
            --padding "1 3" \
            --foreground "#ff7777" \
            --bold \
            "✗ NO EXISTE EL DIRECTORIO

${video_dir}"

    fi

    pause_menu
}


print_test_commands() {

    while true; do

        show_section "Pruebas del tema"

        show_test_panel

        echo

        option="$(
            gum choose \
                --header="Usa ↑ ↓ para navegar y ENTER para seleccionar:" \
                --cursor="❯ " \
                --cursor-prefix=" " \
                --selected.foreground="#c6f4eb" \
                --cursor.foreground="#c6f4eb" \
                "🔎 Diagnóstico completo del sistema" \
                "🧪 Ejecutar prueba local del tema" \
                "🔍 Comprobar Qt 6" \
                "🎬 Comprobar configuración de video" \
                "📁 Ver archivos de video" \
                "↩ Volver al menú principal"
        )"

       case "$option" in

            "🔎 Diagnóstico completo del sistema")
                system_diagnostics
                ;;

            "🧪 Ejecutar prueba local del tema")
                run_test_local
                ;;

            "🔍 Comprobar Qt 6")
                check_qt6
                ;;

            "🎬 Comprobar configuración de video")
                check_video_config
                ;;

            "📁 Ver archivos de video")
                list_video_files
                ;;

            "↩ Volver al menú principal")
                return
                ;;

        esac

    done

}


# ============================================================
# INSTALACIÓN COMPLETA
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


    gum style \
        --border double \
        --padding "1 3" \
        --foreground "#c6f4eb" \
        --bold \
        "✓ INSTALACIÓN TERMINADA

El tema fue instalado localmente.

SDDM NO fue activado automáticamente.

Primero prueba el tema con:

sddm-greeter-qt6 --test-mode --theme ${THEME_DEST}"


}


# ============================================================
# ACTUALIZACIÓN
# ============================================================

do_update() {

    show_section "Actualizar Rollo Warrior"


    update_repository

    validate_source

    copy_theme

    configure_theme


    echo


    gum style \
        --foreground "#c6f4eb" \
        --bold \
        "✓ Actualización completada"

}


# ============================================================
# MENÚ PRINCIPAL
# ============================================================

show_menu() {

    gum choose \
        --header="Selecciona una opción:" \
        --cursor="❯ " \
        --cursor-prefix=" " \
        --selected.foreground="#c6f4eb" \
        --cursor.foreground="#c6f4eb" \
        "🎨 Instalar o reparar tema" \
        "🔄 Actualizar desde GitHub" \
        "🧪 Probar y mostrar comandos" \
        "⚙ Gestionar SDDM" \
        "↩ Restaurar LightDM" \
        "🚪 Salir"

}


# ============================================================
# FUNCIÓN PRINCIPAL
# ============================================================

main() {

    require_root

    ensure_gum


    while true; do


        show_header


        option="$(show_menu)"


        case "$option" in


            "🎨 Instalar o reparar tema")

                do_install
                pause_menu
                ;;


            "🔄 Actualizar desde GitHub")

                do_update
                pause_menu
                ;;


            "🧪 Probar y mostrar comandos")

                print_test_commands
                pause_menu
                ;;


            "⚙ Gestionar SDDM")

                activate_sddm
                pause_menu
                ;;


            "↩ Restaurar LightDM")

                restore_lightdm
                pause_menu
                ;;


            "🚪 Salir")

                clear


                gum style \
                    --border rounded \
                    --padding "1 3" \
                    --bold \
                    --foreground "#c6f4eb" \
                    "Gracias por usar

R O L L O   W A R R I O R"


                exit 0
                ;;

        esac

    done

}


main "$@"