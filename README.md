<div align="center">

# ⚔️ Rollo Warrior

### Un tema moderno, animado y configurable para SDDM con Qt 6

![SDDM](https://img.shields.io/badge/SDDM-Qt%206-1793D1?style=for-the-badge)
![CachyOS](https://img.shields.io/badge/CachyOS-Compatible-00AEEF?style=for-the-badge)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Compatible-1793D1?style=for-the-badge&logo=archlinux)
![Debian](https://img.shields.io/badge/Debian%2013-Compatible-A81D33?style=for-the-badge&logo=debian)
![QML](https://img.shields.io/badge/QML-Theme-41CD52?style=for-the-badge&logo=qt)
![Versión](https://img.shields.io/badge/Versi%C3%B3n-0.5-c6f4eb?style=for-the-badge)
![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-orange?style=for-the-badge)

<br>

**Rollo Warrior** transforma la pantalla de inicio de sesión de Linux con  
fondos animados, paneles personalizables, selector de sesión y una estética oscura.

[📥 Instalación](#-instalación) •
[🎬 Demostración](#-demostración) •
[🎨 Configuración](#-configuración) •
[🛠️ Solución de problemas](#️-solución-de-problemas)

</div>

---

> [!IMPORTANT]
> Rollo Warrior continúa en desarrollo.  
> Antes de activarlo como pantalla de inicio principal, prueba siempre el tema con `sddm-greeter-qt6 --test-mode`.

---

# 🌌 Descripción

**Rollo Warrior** es un tema personalizado para el gestor de inicio de sesión **SDDM**, desarrollado con **QML y Qt 6**.

Su objetivo es ofrecer una pantalla de inicio moderna, visualmente atractiva y fácil de personalizar, conservando herramientas para probar, instalar, actualizar, diagnosticar y restaurar el gestor de inicio del sistema.

El tema está pensado principalmente para:

- 🟦 CachyOS.
- 🏹 Arch Linux y distribuciones basadas en Arch.
- 🌀 Debian 13 (Trixie).
- 🖥️ SDDM con Qt 6.
- 🎞️ Sistemas compatibles con Qt Multimedia.

---

# 🆕 Novedades de la versión 0.5

- 🌀 **Compatibilidad con Debian 13.** El instalador detecta si el sistema usa `pacman` o `apt` e instala los paquetes correctos.
- 📦 **Módulos QML de Debian.** Se instalan `qml6-module-*`, necesarios porque Debian reparte Qt 6 en paquetes separados.
- 🔎 **Diagnóstico ampliado.** Comprueba paquetes, módulos QML, archivos del tema, configuración y gestor de inicio.
- 🛡️ **Las actualizaciones ya no borran tus videos ni GIF.** Los archivos de `assets/videos/` y `assets/gif/` se conservan, igual que `theme.conf.user`.
- 🔄 **El repositorio local se actualiza solo** con `git pull` en cada instalación o actualización.
- ⚠️ **Aviso de conflictos.** Si otro archivo de `/etc/sddm.conf.d/` también define `Current=`, el instalador te lo indica.
- ⌨️ **Menú interactivo con teclas.** Se navega con ↑ ↓ y ENTER, y se cancela con ESC sin errores.

---

# ✨ Características

## 🖥️ Interfaz

- Selector de usuario.
- Selector de sesión gráfica.
- Campo de contraseña personalizado.
- Animación de vibración al fallar la contraseña.
- Mensajes de error en español o inglés.
- Interfaz de inicio oscura y configurable.
- Soporte para imágenes de usuario proporcionadas por SDDM.

## 🕒 Reloj y fecha

- Formato de 12 o 24 horas.
- Reloj horizontal o vertical.
- Posición izquierda, centro o derecha.
- Posición superior, central o inferior.
- Tamaño configurable.
- Márgenes personalizables.
- Fecha normal o en negrita.

## 🎬 Fondos

- Fondos mediante imágenes.
- Fondos mediante video.
- GIF de respaldo durante la carga.
- Imagen alternativa si el video no funciona.
- Capa de oscurecimiento configurable.
- Activación o desactivación rápida del video.

## 🎨 Personalización

- Color de acento personalizado.
- Tipografías incluidas en el tema.
- Paneles con apariencia de vidrio.
- Paneles con degradado.
- Paneles transparentes.
- Esquinas redondeadas.
- Transparencia configurable.
- Oscurecimiento especial durante el inicio de sesión.

## 🛠️ Instalador

- Compatible con Arch/CachyOS (`pacman`) y Debian 13 (`apt`).
- Instalación automática de dependencias.
- Instalación automática de `gum` para la interfaz del instalador.
- Validación de archivos principales.
- Descarga y actualización automática desde GitHub.
- Instalación en la ruta correcta de SDDM.
- Configuración automática del tema.
- Diagnóstico completo del sistema.
- Activación o desactivación de SDDM.
- Restauración opcional de LightDM.

---

# 🎬 Demostración

## 🖼️ Vista principal

<p align="center">
  <img src="docs/images/rollo-warrior-main.png"
       alt="Pantalla principal de Rollo Warrior"
       width="850">
</p>

## 🔐 Panel de inicio de sesión

<p align="center">
  <img src="docs/images/rollo-warrior-login.png"
       alt="Panel de inicio de sesión de Rollo Warrior"
       width="850">
</p>

## 🖥️ Selector de sesiones

<p align="center">
  <img src="docs/images/rollo-warrior-sessions.png"
       alt="Selector de sesiones gráficas"
       width="850">
</p>

## 🎞️ Demostración animada

<p align="center">
  <img src="docs/demo/rollo-warrior-demo.gif"
       alt="Demostración animada de Rollo Warrior"
       width="850">
</p>

## 📹 Video completo

Puedes ver la demostración completa aquí:

[▶️ Reproducir demostración de Rollo Warrior](docs/demo/rollo-warrior-demo.mp4)

---

# 📁 Organización recomendada para imágenes y videos

Dentro del repositorio puedes crear esta estructura:

```text
rollo-warrior/
├── docs/
│   ├── images/
│   │   ├── rollo-warrior-main.png
│   │   ├── rollo-warrior-login.png
│   │   └── rollo-warrior-sessions.png
│   └── demo/
│       ├── rollo-warrior-demo.gif
│       └── rollo-warrior-demo.mp4
├── assets/
├── Main.qml
├── VideoBackground.qml
├── metadata.desktop
├── theme.conf
├── install-theme.sh
└── README.md
```

Para crear las carpetas:

```bash
cd ~/rollo-warrior

mkdir -p docs/images
mkdir -p docs/demo
```

Después copia tus archivos:

```bash
cp ~/Imágenes/captura-principal.png \
  docs/images/rollo-warrior-main.png

cp ~/Imágenes/captura-login.png \
  docs/images/rollo-warrior-login.png

cp ~/Videos/rollo-warrior-demo.gif \
  docs/demo/rollo-warrior-demo.gif
```

Sube los cambios:

```bash
git add docs README.md
git commit -m "Agregar demostración visual al README"
git push origin main
```

> [!TIP]
> Para mostrar una animación directamente dentro del README, utiliza un archivo GIF.
>
> Los videos MP4 pueden presentarse mediante un enlace para abrirlos o descargarlos.

---

# 📥 Instalación

El mismo comando funciona en **Arch/CachyOS** y en **Debian 13**:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Tecdroid214/rollo-warrior/main/install-theme.sh)"
```

> [!NOTE]
> No se necesita permiso de ejecución porque el archivo se abre directamente mediante Bash.
>
> Sí se necesita `sudo`, ya que el instalador escribe en `/usr/share`, `/etc` y administra servicios del sistema.
>
> No uses `curl ... | sudo bash`: el menú necesita el teclado y una tubería se lo quitaría.

## 📋 Requisitos previos

| Sistema | Gestor | Antes de instalar |
|---------|--------|-------------------|
| Arch / CachyOS | `pacman` | Nada adicional. |
| Debian 13 | `apt` | Necesitas `curl` y `sudo`. |

En Debian, si no los tienes:

```bash
su -
apt install -y curl sudo
usermod -aG sudo tu_usuario
```

Cierra sesión y vuelve a entrar para que el grupo `sudo` se aplique.

## 📦 Dependencias que instala el instalador

El instalador las instala automáticamente al elegir **Instalar o reparar tema**.

| Función | Arch / CachyOS | Debian 13 |
|---------|----------------|-----------|
| Herramientas | `git`, `rsync`, `gum` | `git`, `rsync`, `gum` |
| Gestor de inicio | `sddm` | `sddm` |
| QtQuick y QML | `qt6-declarative` | `qml6-module-qtquick`, `qml6-module-qtquick-window`, `qml6-module-qtqml-workerscript` |
| Video | `qt6-multimedia-ffmpeg` | `qml6-module-qtmultimedia` |
| Imágenes SVG | `qt6-svg` | — |

> [!NOTE]
> Debian 13 ya incluye SDDM con Qt 6 y el ejecutable `sddm-greeter-qt6`.
>
> La compatibilidad con Debian está en pruebas. Si algún paquete falla, abre un Issue con el mensaje de error.

---

# 📋 Menú del instalador

Al ejecutar el instalador aparece un menú interactivo. Se navega con **↑ ↓**, se selecciona con **ENTER** y se sale con **ESC**:

```text
Selecciona una opción:

❯ 🎨 Instalar o reparar tema
  🔄 Actualizar desde GitHub
  🧪 Probar y mostrar comandos
  ⚙ Gestionar SDDM
  ↩ Restaurar LightDM
  🚪 Salir
```

| Opción | Qué hace |
|--------|----------|
| 🎨 **Instalar o reparar tema** | Instala dependencias, descarga el repositorio, valida y copia el tema, y crea la configuración. |
| 🔄 **Actualizar desde GitHub** | Descarga los cambios, valida de nuevo y vuelve a copiar el tema. |
| 🧪 **Probar y mostrar comandos** | Abre el submenú de pruebas y diagnóstico. |
| ⚙ **Gestionar SDDM** | Activa SDDM, o si ya está activo, permite repararlo o desactivarlo. |
| ↩ **Restaurar LightDM** | Devuelve LightDM como gestor de inicio (debe estar instalado). |
| 🚪 **Salir** | Cierra el instalador. |

Para la primera instalación selecciona **🎨 Instalar o reparar tema**.

El instalador:

1. Instalará las dependencias de tu distribución.
2. Descargará el repositorio en `~/rollo-warrior`, o lo actualizará si ya existe.
3. Validará los archivos del tema.
4. Copiará Rollo Warrior a `/usr/share/sddm/themes/rollo-warrior`.
5. Creará `/etc/sddm.conf.d/10-rollo-warrior.conf`.
6. Mantendrá tu gestor de inicio actual hasta que decidas cambiarlo.

## 🧪 Submenú de pruebas

| Opción | Qué hace |
|--------|----------|
| 🔎 **Diagnóstico completo** | Comprueba paquetes, módulos QML, archivos del tema, configuración y gestor de inicio. |
| 🧪 **Ejecutar prueba local del tema** | Abre el greeter en modo de prueba. |
| 🔍 **Comprobar Qt 6** | Verifica que `metadata.desktop` indique `QtVersion=6`. |
| 🎬 **Comprobar configuración de video** | Muestra `BackgroundType`, `EnableVideo` y `BackgroundVideo`. |
| 📁 **Ver archivos de video** | Lista los videos instalados en el tema. |

---

# 📦 Descargar el repositorio

## Mediante Git

```bash
git clone https://github.com/Tecdroid214/rollo-warrior.git
```

Después entra en la carpeta:

```bash
cd ~/rollo-warrior
```

Ejecuta el instalador:

```bash
sudo bash install-theme.sh
```

Si ejecutas el instalador desde la carpeta del repositorio, usará esos archivos en lugar de descargar otra copia.

## Dirección del repositorio

```text
https://github.com/Tecdroid214/rollo-warrior
```

---

# 🧪 Probar el tema

Antes de activar SDDM, prueba Rollo Warrior desde tu sesión gráfica.

Ejecuta este comando **sin sudo**:

```bash
sddm-greeter-qt6 \
  --test-mode \
  --theme /usr/share/sddm/themes/rollo-warrior
```

Durante la prueba puedes revisar:

- 🖼️ El fondo.
- 🎞️ La reproducción del video.
- 🕒 El reloj y la fecha.
- 👤 El selector de usuario.
- 🖥️ El selector de sesión.
- 🔐 El campo de contraseña.
- 🎨 Los colores y paneles.

> [!NOTE]
> El inicio de sesión real no funcionará dentro de `--test-mode`.
>
> Esto es normal porque el greeter de prueba no está conectado al servicio real de SDDM.

---

# ✅ Activar SDDM

En **Debian 13** SDDM suele venir activado por defecto, así que normalmente no necesitas este paso.

Cuando la prueba funcione correctamente:

```bash
cd ~/rollo-warrior
sudo bash install-theme.sh
```

Selecciona:

```text
⚙ Gestionar SDDM
```

Si SDDM no es el gestor actual, el instalador solicitará confirmación antes de cambiarlo. Si ya está activo, mostrará las opciones de reparar o desactivar.

Después reinicia:

```bash
sudo reboot
```

---

# 🔄 Actualización

Para descargar una versión nueva de Rollo Warrior:

```bash
cd ~/rollo-warrior
sudo bash install-theme.sh
```

Selecciona:

```text
🔄 Actualizar desde GitHub
```

La opción de actualización:

- Descarga los cambios desde GitHub.
- Valida nuevamente el tema.
- Copia los archivos actualizados.
- Vuelve a escribir la configuración de SDDM.
- **Conserva** los videos en `assets/videos/`, los GIF en `assets/gif/` y el archivo `theme.conf.user`.

También puedes descargar los cambios manualmente:

```bash
cd ~/rollo-warrior
git pull --ff-only origin main
```

> [!WARNING]
> La actualización reemplaza `theme.conf` por el del repositorio.
>
> Si quieres conservar ajustes propios, guárdalos en `theme.conf.user` dentro de la carpeta del tema. SDDM lo lee después de `theme.conf` y el instalador no lo borra.

---

# 🎨 Configuración

El archivo principal de configuración es:

```text
theme.conf
```

Edita la copia del repositorio:

```bash
nano ~/rollo-warrior/theme.conf
```

Después vuelve a instalar el tema para copiar la configuración:

```bash
cd ~/rollo-warrior
sudo bash install-theme.sh
```

Selecciona:

```text
🎨 Instalar o reparar tema
```

---

## 🌐 Idioma

```ini
Language=es
```

Valores disponibles:

```ini
Language=es
Language=en
```

| Valor | Idioma |
|------:|--------|
| `es` | Español |
| `en` | Inglés |

---

## 🕒 Formato de hora

Formato de 24 horas:

```ini
Use12Hour=false
```

Formato de 12 horas:

```ini
Use12Hour=true
```

---

## 📍 Posición del reloj

```ini
ClockPosition=left
ClockPositionV=center
```

Valores horizontales:

```ini
left
center
right
```

Valores verticales:

```ini
top
center
bottom
```

---

## ↔️ Orientación del reloj

Horizontal:

```ini
ClockOrientation=horizontal
```

Vertical:

```ini
ClockOrientation=vertical
```

---

## 🔠 Tamaño del reloj

```ini
ClockFontSize=110
DateFontSize=30
```

Ejemplo para una interfaz más compacta:

```ini
ClockFontSize=85
DateFontSize=24
```

---

## 📏 Márgenes

```ini
ClockMarginH=80
ClockMarginV=15
```

| Opción | Función |
|--------|---------|
| `ClockMarginH` | Separación horizontal |
| `ClockMarginV` | Separación vertical |

---

## ✒️ Tipografía

```ini
FontFamily=
CustomFontFile=assets/fonts/Hearty Sacred.otf
```

Para utilizar otra fuente:

1. Copia el archivo a `assets/fonts/`.
2. Cambia la ruta en `theme.conf`.

Ejemplo:

```ini
CustomFontFile=assets/fonts/MiFuente.ttf
```

---

## 🌈 Color de acento

```ini
AccentMode=custom
AccentColor=#c6f4eb
```

Ejemplos:

```ini
AccentColor=#c6f4eb
AccentColor=#ffffff
AccentColor=#ff5c8a
AccentColor=#8ab4f8
AccentColor=#ffd166
```

Modo automático:

```ini
AccentMode=auto
```

> [!TIP]
> Para fondos de video se recomienda utilizar `AccentMode=custom`.

---

# 🖼️ Fondo mediante imagen

```ini
BackgroundType=image
EnableVideo=false
BackgroundImage=assets/images/image_3.jpg
```

La imagen debe existir dentro de la carpeta indicada.

---

# 🎞️ Fondo mediante video

```ini
BackgroundType=video
EnableVideo=true
BackgroundVideo=assets/videos/video_1.mp4
```

Configura también los respaldos:

```ini
BackgroundVideoFallbackGif=assets/gif/error_imagen.gif
BackgroundImage=assets/images/image_3.jpg
```

Orden aproximado de respaldo:

```text
Video → GIF → Imagen
```

Para desactivar temporalmente el video:

```ini
BackgroundType=video
EnableVideo=false
```

> [!IMPORTANT]
> Los videos (`*.mp4`) y los GIF (`*.gif`) **no se incluyen en el repositorio** de GitHub.
>
> Para usar un video, cópialo manualmente a la carpeta del tema:
>
> ```bash
> sudo cp mi-video.mp4 /usr/share/sddm/themes/rollo-warrior/assets/videos/
> ```
>
> Las actualizaciones no lo borrarán.

> [!TIP]
> En Debian, si el video no se reproduce, empieza con `EnableVideo=false` para comprobar que el resto del tema carga bien. Después activa el video y revisa el registro con `journalctl -u sddm -b`.

---

## 🌑 Oscurecimiento del fondo

```ini
OverlayOpacity=0.15
```

| Valor | Resultado aproximado |
|------:|----------------------|
| `0.00` | Sin oscurecimiento |
| `0.15` | Oscurecimiento ligero |
| `0.50` | Oscurecimiento medio |
| `0.80` | Oscurecimiento fuerte |
| `1.00` | Fondo completamente oscuro |

---

# 🪟 Personalización de paneles

## Estilo principal

```ini
PanelStyle=glass
```

Opciones:

```ini
PanelStyle=glass
PanelStyle=gradient
PanelStyle=none
```

## Transparencia

```ini
TextBackgroundOpacity=0.45
PanelTintOpacity=0.25
```

## Esquinas

```ini
PanelRadius=0
```

Ejemplo con esquinas redondeadas:

```ini
PanelRadius=24
```

---

# 🔐 Panel de inicio de sesión

```ini
LoginDarkenEnabled=true
LoginDarkenOpacity=0.25
LoginPanelStyle=glass
```

Estilos disponibles:

```ini
LoginPanelStyle=glass
LoginPanelStyle=gradient
LoginPanelStyle=none
```

Para desactivar el oscurecimiento:

```ini
LoginDarkenEnabled=false
```

---

# 📂 Estructura del proyecto

```text
rollo-warrior/
├── Main.qml
├── VideoBackground.qml
├── metadata.desktop
├── theme.conf
├── install-theme.sh
├── assets/
│   ├── fonts/
│   ├── gif/
│   ├── images/
│   └── videos/
└── docs/
    ├── images/
    └── demo/
```

| Archivo | Función |
|---------|---------|
| `Main.qml` | Interfaz principal |
| `VideoBackground.qml` | Fondo y reproducción de video |
| `metadata.desktop` | Información para SDDM |
| `theme.conf` | Configuración visual |
| `install-theme.sh` | Instalación, actualización y diagnóstico |
| `assets/` | Recursos utilizados por el tema |
| `docs/` | Capturas y demostraciones del README |

---

# 🛠️ Solución de problemas

## Ejecutar el diagnóstico

La forma más rápida de ver qué falta:

```bash
cd ~/rollo-warrior
sudo bash install-theme.sh
```

Selecciona **🧪 Probar y mostrar comandos → 🔎 Diagnóstico completo**. Cada componente aparece marcado con ✓ o ✗.

---

## El video no aparece

Comprueba la configuración:

```bash
grep -E '^(BackgroundType|EnableVideo|BackgroundVideo)=' \
  /usr/share/sddm/themes/rollo-warrior/theme.conf
```

Comprueba que el archivo exista:

```bash
ls -lh \
  /usr/share/sddm/themes/rollo-warrior/assets/videos/
```

Prueba el greeter:

```bash
sddm-greeter-qt6 \
  --test-mode \
  --theme /usr/share/sddm/themes/rollo-warrior
```

---

## SDDM no muestra Rollo Warrior

Comprueba:

```bash
cat /etc/sddm.conf.d/10-rollo-warrior.conf
```

El archivo debería contener:

```ini
[General]
DisplayServer=x11

[Theme]
Current=rollo-warrior
```

La línea `DisplayServer=x11` solo se escribe si Xorg está instalado.

Si otro archivo también define `Current=`, puede pisar el tema. Búscalo con:

```bash
grep -rn "^Current=" /etc/sddm.conf /etc/sddm.conf.d/
```

---

## Error "module is not installed"

Si el login muestra un error rojo parecido a:

```text
module "QtQuick.Window" is not installed
```

faltan módulos de Qt 6. Ejecuta de nuevo **🎨 Instalar o reparar tema**, o instálalos a mano.

En Debian:

```bash
sudo apt install qml6-module-qtquick qml6-module-qtquick-window \
  qml6-module-qtqml-workerscript qml6-module-qtmultimedia
```

En Arch/CachyOS:

```bash
sudo pacman -S qt6-declarative qt6-multimedia-ffmpeg
```

---

## Ver el registro de SDDM

Si el tema funciona en `--test-mode` pero falla al reiniciar:

```bash
journalctl -u sddm -b --no-pager | tail -60
```

---

## Comprobar el gestor de inicio

```bash
readlink -f \
  /etc/systemd/system/display-manager.service
```

Estado de SDDM:

```bash
systemctl status sddm.service
```

---

## `git pull` falla por cambios locales

Si editaste `theme.conf` dentro de `~/rollo-warrior` y la actualización no puede continuar:

```bash
cd ~/rollo-warrior
git stash
git pull --ff-only origin main
git stash pop
```

---

## Restaurar LightDM

Ejecuta:

```bash
cd ~/rollo-warrior
sudo bash install-theme.sh
```

Selecciona:

```text
↩ Restaurar LightDM
```

> [!WARNING]
> Esta opción requiere que LightDM esté instalado.

---

# ⚠️ Recomendaciones de seguridad

Un tema de SDDM se ejecuta antes de iniciar la sesión del usuario.

Antes de activarlo:

1. 🧪 Prueba siempre el tema con `--test-mode`.
2. 💾 Mantén una copia de seguridad.
3. 🖥️ Conserva acceso a una terminal TTY.
4. 🚫 No elimines tu gestor anterior inmediatamente.
5. 🔍 Revisa el instalador antes de ejecutar código descargado.

Para revisar el script:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Tecdroid214/rollo-warrior/main/install-theme.sh \
  | less
```

Para abrir una TTY normalmente puedes usar:

```text
Ctrl + Alt + F2
```

o:

```text
Ctrl + Alt + F3
```

---

# 🗺️ Próximas funciones

- [x] Fondo mediante imagen.
- [x] Fondo mediante video.
- [x] GIF de respaldo.
- [x] Selector de sesión.
- [x] Animación de contraseña incorrecta.
- [x] Instalador automático.
- [x] Actualización desde GitHub.
- [x] Instalador compatible con Arch/CachyOS y Debian 13.
- [x] Diagnóstico completo desde el instalador.
- [ ] Más estilos visuales.
- [ ] Más opciones de paneles.
- [ ] Mejor soporte para diferentes resoluciones.
- [ ] Configuración simplificada.
- [ ] Mejoras para imágenes de perfil.
- [ ] Compatibilidad con más distribuciones (Fedora, openSUSE, Ubuntu).

---

# 🤝 Contribuciones

Las pruebas, sugerencias y reportes son bienvenidos.

Puedes utilizar la sección **Issues** para informar:

- 🐛 Errores.
- 🎞️ Problemas con videos.
- 🖥️ Problemas con sesiones.
- 📦 Fallos de instalación en Arch o Debian.
- 🎨 Sugerencias visuales.
- ✨ Solicitudes de funciones.

---

# 👤 Autor

<div align="center">

Desarrollado por **Tecdroid214**

[![GitHub](https://img.shields.io/badge/GitHub-Tecdroid214-181717?style=for-the-badge&logo=github)](https://github.com/Tecdroid214)

### ⭐ Si te gusta Rollo Warrior, puedes darle una estrella al repositorio

</div>

---

# 📄 Licencia

La licencia definitiva del proyecto se añadirá próximamente.

Mientras el proyecto esté en desarrollo, revisa el repositorio antes de copiar, redistribuir o modificar sus recursos.

---

<div align="center">

## ⚔️ Rollo Warrior

**Una entrada diferente para tu escritorio Linux.**

</div>
