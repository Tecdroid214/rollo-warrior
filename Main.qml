import QtQuick
import QtQuick.Window

Rectangle {
    id: root

    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height
    color: "#000000"
    focus: true

    Component.onCompleted: root.forceActiveFocus()

    // =====================================================
    // Helpers de configuración
    // =====================================================
    function hasConfigKey(key) {
        return config && config.keys().indexOf(key) !== -1
    }

    function configString(key, fallbackValue) {
        return hasConfigKey(key) ? config.stringValue(key) : fallbackValue
    }

    function configBool(key, fallbackValue) {
        if (!hasConfigKey(key))
            return fallbackValue
        return config.stringValue(key).toLowerCase() === "true"
    }

    function configReal(key, fallbackValue) {
        if (!hasConfigKey(key))
            return fallbackValue
        var parsed = parseFloat(config.stringValue(key))
        return isNaN(parsed) ? fallbackValue : parsed
    }

    // =====================================================
    // Lectura de theme.conf
    // =====================================================
    property string clockPosition: configString("ClockPosition", "center")
    property string clockPositionV: configString("ClockPositionV", "center")
    property string clockOrientation: configString("ClockOrientation", "horizontal")
    property string language: configString("Language", "es")
    property bool use12Hour: configBool("Use12Hour", false)

    property string backgroundType: configString("BackgroundType", "image")
    property string backgroundImage: configString("BackgroundImage", "assets/images/image_1.jpg")
    property string backgroundVideo: configString("BackgroundVideo", "")
    property string backgroundVideoFallbackGif: configString(
        "BackgroundVideoFallbackGif",
        "assets/gif/fallback.gif"
    )
    property bool enableVideo: configBool("EnableVideo", true)

    property real overlayOpacity: configReal("OverlayOpacity", 0.30)
    property real textBgOpacity: configReal("TextBackgroundOpacity", 0.45)
    property string accentMode: configString("AccentMode", "auto")
    property string accentColorConfig: configString("AccentColor", "#c6f4eb")

    property real clockMarginH: configReal("ClockMarginH", 80)
    property real clockMarginV: configReal("ClockMarginV", 40)
    property bool splitLayout: configBool("SplitLayout", false)
    property bool dateBold: configBool("DateBold", true)
    property real clockFontSize: configReal("ClockFontSize", 110)
    property real dateFontSize: configReal("DateFontSize", 30)
    property bool unlockCentered: configBool("UnlockCentered", false)

    property string panelStyle: configString("PanelStyle", "glass")
    property real panelRadius: configReal("PanelRadius", 0)
    property real panelTintOpacity: configReal("PanelTintOpacity", 0.25)
    property bool enableBlur: configBool("EnableBlur", false)
    property real panelBlurRadius: configReal("PanelBlurRadius", 45)

    property string fontFamily: configString("FontFamily", "")
    property string customFontFile: configString("CustomFontFile", "")

    property bool loginDarkenEnabled: configBool("LoginDarkenEnabled", true)
    property real loginDarkenOpacity: configReal("LoginDarkenOpacity", 0.25)
    property string loginPanelStyle: configString("LoginPanelStyle", "glass")

    // =====================================================
    // Estado derivado
    // =====================================================
    property url resolvedBackgroundImage: Qt.resolvedUrl(backgroundImage)
    property url resolvedBackgroundVideo: Qt.resolvedUrl(backgroundVideo)
    property url resolvedFallbackGif: Qt.resolvedUrl(backgroundVideoFallbackGif)
    property bool useVideoBackground:
        backgroundType === "video" && enableVideo && backgroundVideo.length > 0

    // El estado se enlaza directamente al objeto cargado para evitar perder
    // una señal si MediaPlayer comienza antes de que Connections quede conectado.
    readonly property bool videoComponentReady:
        videoLoader.status === Loader.Ready && videoLoader.item !== null
    readonly property bool videoPlaybackReady:
        videoComponentReady && videoLoader.item.started
    readonly property bool videoPlaybackFailed:
        videoLoader.status === Loader.Error
        || (videoComponentReady && videoLoader.item.failed)
    readonly property string videoErrorMessage:
        videoLoader.status === Loader.Error
        ? "No se pudo cargar VideoBackground.qml"
        : (videoComponentReady ? videoLoader.item.errorMessage : "")

    property bool splitActive: splitLayout && clockPosition !== "center"
    property bool clockAtBottom: clockPositionV === "bottom"
    property bool unlockShouldCenter: unlockCentered || splitActive

    property date now: new Date()
    property string currentTimeText:
        use12Hour ? Qt.formatTime(now, "h:mm AP") : Qt.formatTime(now, "hh:mm")
    property string currentHourText: {
        var h = now.getHours()
        if (use12Hour) {
            h = h % 12
            if (h === 0)
                h = 12
        }
        var value = h.toString()
        return value.length < 2 ? "0" + value : value
    }
    property string currentMinuteText: {
        var value = now.getMinutes().toString()
        return value.length < 2 ? "0" + value : value
    }
    property string currentAmPmText: now.getHours() < 12 ? "AM" : "PM"
    property string currentDateText: {
        if (language === "es") {
            var daysEs = [
                "Domingo", "Lunes", "Martes", "Miércoles",
                "Jueves", "Viernes", "Sábado"
            ]
            var monthsEs = [
                "enero", "febrero", "marzo", "abril", "mayo", "junio",
                "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
            ]
            return daysEs[now.getDay()] + ", " + now.getDate() + " de " + monthsEs[now.getMonth()]
        }

        var daysEn = [
            "Sunday", "Monday", "Tuesday", "Wednesday",
            "Thursday", "Friday", "Saturday"
        ]
        var monthsEn = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        return daysEn[now.getDay()] + ", " + monthsEn[now.getMonth()] + " " + now.getDate()
    }

    property string unlockText:
        language === "es"
        ? "Presiona cualquier tecla para desbloquear"
        : "Press any key to unlock"

    property string loginErrorText: ""
    property bool showLogin: false
    property bool showPassword: false

    FontLoader {
        id: customFontLoader
        source: customFontFile.length > 0 ? Qt.resolvedUrl(customFontFile) : ""
    }

    property string effectiveFontFamily:
        customFontLoader.status === FontLoader.Ready
        ? customFontLoader.name
        : (fontFamily.length > 0 ? fontFamily : Qt.application.font.family)

    property color extractedAccentColor: "#c6f4eb"
    property color accentColor:
        accentMode === "custom" || useVideoBackground
        ? accentColorConfig
        : extractedAccentColor

    // =====================================================
    // Entrada de teclado y autenticación
    // =====================================================
    Keys.onPressed: function(event) {
        if (!showLogin) {
            showLogin = true
            event.accepted = true
        }
    }

    onShowLoginChanged: {
        if (showLogin) {
            loginErrorText = ""
            passwordInput.forceActiveFocus()
        } else {
            passwordInput.text = ""
            root.forceActiveFocus()
        }
    }

    function doLogin() {
        var userName = userListView.currentItem
            ? userListView.currentItem.userName
            : ""
        var sessionIndex = sessionListView.currentIndex >= 0
            ? sessionListView.currentIndex
            : 0

        if (userName.length === 0) {
            loginErrorText = language === "es"
                ? "No se encontró un usuario válido"
                : "No valid user was found"
            return
        }

        loginErrorText = ""
        sddm.login(userName, passwordInput.text, sessionIndex)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            loginErrorText = language === "es"
                ? "Contraseña incorrecta o inicio de sesión fallido"
                : "Incorrect password or login failed"
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }

        function onLoginSucceeded() {
            loginErrorText = ""
        }

        function onInformationMessage(message) {
            if (message && message.length > 0)
                loginErrorText = message
        }
    }

    // Modelos invisibles, pero instanciados para disponer de currentItem.
    ListView {
        id: userListView
        x: -10000
        y: -10000
        width: 1
        height: 1
        opacity: 0
        cacheBuffer: 100000
        model: userModel
        currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0

        delegate: Item {
            property string userName: name
            property string userRealName: realName
            property string userIcon: icon
        }
    }

    ListView {
        id: sessionListView
        x: -10000
        y: -10000
        width: 1
        height: 1
        opacity: 0
        cacheBuffer: 100000
        model: sessionModel
        currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

        delegate: Item {
            property string sessionName: name
        }
    }

    // =====================================================
    // Fondo: imagen base, GIF de espera y video
    // =====================================================
    Item {
        id: backgroundLayer
        anchors.fill: parent

        Image {
            id: staticBackground
            anchors.fill: parent
            source: root.resolvedBackgroundImage
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            sourceSize.width: root.width
            sourceSize.height: root.height

            onStatusChanged: {
                if (status === Image.Ready)
                    colorCanvas.requestPaint()
            }
        }

        AnimatedImage {
            id: gifFallback
            anchors.fill: parent
            z: 1
            source: root.resolvedFallbackGif
            fillMode: Image.PreserveAspectCrop
            visible: root.useVideoBackground && !root.videoPlaybackReady
            playing: visible
            asynchronous: true
            cache: false
        }

        Loader {
            id: videoLoader
            anchors.fill: parent
            z: 2
            active: root.useVideoBackground
            visible: active && status === Loader.Ready
            opacity: root.videoPlaybackReady ? 1 : 0
            source: active ? Qt.resolvedUrl("VideoBackground.qml") : ""

            Behavior on opacity {
                NumberAnimation { duration: 180 }
            }

            onLoaded: {
                if (!item)
                    return

                item.videoSource = root.resolvedBackgroundVideo

                // Espera un ciclo del event loop. Esto evita que playbackStarted
                // ocurra antes de que Main.qml pueda observar item.started.
                Qt.callLater(function() {
                    if (videoLoader.item)
                        videoLoader.item.start()
                })
            }

            onStatusChanged: {
                if (status === Loader.Error)
                    console.log("No se pudo cargar VideoBackground.qml")
            }
        }

        Connections {
            target: videoLoader.item
            ignoreUnknownSignals: true

            function onPlaybackStarted() {
                console.log("Video de fondo iniciado correctamente:",
                            root.resolvedBackgroundVideo)
            }

            function onPlaybackFailed(message) {
                console.log("Error de video; se mantiene el GIF o la imagen:",
                            message)
            }

            function onMediaStatusReported(statusText) {
                console.log("Estado de Qt Multimedia:", statusText)
            }
        }
    }

    // Extrae un color aproximado de la imagen estática.
    Canvas {
        id: colorCanvas
        width: 32
        height: 32
        opacity: 0

        onPaint: {
            if (root.useVideoBackground || staticBackground.status !== Image.Ready)
                return

            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.drawImage(staticBackground, 0, 0, width, height)

            var imageData = ctx.getImageData(0, 0, width, height)
            var data = imageData.data
            var totalLum = 0
            var count = 0
            var sumSin = 0
            var sumCos = 0
            var sumSat = 0

            for (var i = 0; i < data.length; i += 4) {
                var red = data[i] / 255
                var green = data[i + 1] / 255
                var blue = data[i + 2] / 255
                var luminance = 0.299 * red + 0.587 * green + 0.114 * blue

                totalLum += luminance
                count++

                var pixelColor = Qt.rgba(red, green, blue, 1)
                var saturation = pixelColor.hslSaturation
                var hue = pixelColor.hslHue
                if (hue < 0)
                    hue = 0

                var angle = hue * 2 * Math.PI
                sumSin += Math.sin(angle) * saturation
                sumCos += Math.cos(angle) * saturation
                sumSat += saturation
            }

            if (count === 0)
                return

            var averageLuminance = totalLum / count
            var finalHue = 0

            if (sumSat > 0.001) {
                var averageAngle = Math.atan2(sumSin, sumCos)
                finalHue = averageAngle / (2 * Math.PI)
                if (finalHue < 0)
                    finalHue += 1
            }

            var finalSaturation = Math.max(0.45, Math.min(0.9, (sumSat / count) * 3))
            var targetLightness = averageLuminance < 0.5 ? 0.85 : 0.22
            root.extractedAccentColor = Qt.hsla(finalHue, finalSaturation, targetLightness, 1)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.overlayOpacity
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.showLogin && root.loginDarkenEnabled
            ? root.loginDarkenOpacity
            : 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    // =====================================================
    // Pantalla de bloqueo
    // =====================================================
    Item {
        id: lockScreen
        anchors.fill: parent
        opacity: root.showLogin ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.showLogin = true
        }

        Item {
            id: contentBlock
            visible: !root.splitActive
            width: Math.min(560, root.width * 0.42)
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.left: root.clockPosition === "left" ? parent.left : undefined
            anchors.leftMargin: root.clockMarginH
            anchors.horizontalCenter:
                root.clockPosition === "center" ? parent.horizontalCenter : undefined
            anchors.right: root.clockPosition === "right" ? parent.right : undefined
            anchors.rightMargin: root.clockMarginH

            Rectangle {
                visible: root.panelStyle === "gradient"
                anchors.fill: parent

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop {
                        position: 0.15
                        color: Qt.rgba(0, 0, 0, root.textBgOpacity)
                    }
                    GradientStop {
                        position: 0.85
                        color: Qt.rgba(0, 0, 0, root.textBgOpacity)
                    }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            Rectangle {
                visible: root.panelStyle === "glass"
                anchors.fill: parent
                radius: root.panelRadius
                color: Qt.rgba(0, 0, 0, root.panelTintOpacity + 0.12)
                border.color: Qt.rgba(
                    root.accentColor.r,
                    root.accentColor.g,
                    root.accentColor.b,
                    0.08
                )
                border.width: 1
            }

            Column {
                id: clockColumn
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: root.clockPositionV === "top" ? parent.top : undefined
                anchors.topMargin: root.clockMarginV
                anchors.verticalCenter:
                    root.clockPositionV === "center" ? parent.verticalCenter : undefined
                anchors.bottom:
                    root.clockPositionV === "bottom" ? parent.bottom : undefined
                anchors.bottomMargin: root.clockMarginV
                spacing: 12

                Text {
                    visible: root.clockOrientation === "horizontal"
                    text: root.currentTimeText
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: root.clockFontSize
                    font.family: root.effectiveFontFamily
                    font.weight: Font.Medium
                    color: root.accentColor
                }

                Column {
                    visible: root.clockOrientation === "vertical"
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: -root.clockFontSize * 0.12

                    Text {
                        text: root.currentHourText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: root.clockFontSize
                        font.family: root.effectiveFontFamily
                        font.weight: Font.Medium
                        color: root.accentColor
                    }

                    Text {
                        text: root.currentMinuteText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: root.clockFontSize
                        font.family: root.effectiveFontFamily
                        font.weight: Font.Medium
                        color: root.accentColor
                    }

                    Text {
                        visible: root.use12Hour
                        text: root.currentAmPmText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Math.max(14, root.clockFontSize * 0.18)
                        font.family: root.effectiveFontFamily
                        color: Qt.rgba(
                            root.accentColor.r,
                            root.accentColor.g,
                            root.accentColor.b,
                            0.75
                        )
                    }
                }

                Text {
                    text: root.currentDateText
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: root.dateFontSize
                    font.family: root.effectiveFontFamily
                    font.bold: root.dateBold
                    color: Qt.rgba(
                        root.accentColor.r,
                        root.accentColor.g,
                        root.accentColor.b,
                        0.75
                    )
                }
            }
        }

        Item {
            id: splitBlock
            visible: root.splitActive
            anchors.fill: parent

            Text {
                id: splitClockText
                text: root.currentTimeText
                font.pixelSize: root.clockFontSize
                font.family: root.effectiveFontFamily
                font.weight: Font.Medium
                color: root.accentColor

                anchors.left: root.clockPosition === "left" ? parent.left : undefined
                anchors.leftMargin: root.clockMarginH
                anchors.right: root.clockPosition === "right" ? parent.right : undefined
                anchors.rightMargin: root.clockMarginH

                anchors.top: root.clockPositionV === "top" ? parent.top : undefined
                anchors.topMargin: root.clockMarginV
                anchors.verticalCenter:
                    root.clockPositionV === "center" ? parent.verticalCenter : undefined
                anchors.bottom:
                    root.clockPositionV === "bottom" ? parent.bottom : undefined
                anchors.bottomMargin: root.clockMarginV
            }

            Text {
                text: root.currentDateText
                font.pixelSize: root.dateFontSize
                font.family: root.effectiveFontFamily
                font.bold: root.dateBold
                color: Qt.rgba(
                    root.accentColor.r,
                    root.accentColor.g,
                    root.accentColor.b,
                    0.75
                )

                anchors.right: root.clockPosition === "left" ? parent.right : undefined
                anchors.rightMargin: root.clockMarginH
                anchors.left: root.clockPosition === "right" ? parent.left : undefined
                anchors.leftMargin: root.clockMarginH
                anchors.verticalCenter: splitClockText.verticalCenter
            }
        }

        Item {
            id: unlockFollowBlock
            visible: !root.unlockShouldCenter
            width: Math.min(560, root.width * 0.42)

            anchors.left: root.clockPosition === "left" ? parent.left : undefined
            anchors.leftMargin: root.clockMarginH
            anchors.horizontalCenter:
                root.clockPosition === "center" ? parent.horizontalCenter : undefined
            anchors.right: root.clockPosition === "right" ? parent.right : undefined
            anchors.rightMargin: root.clockMarginH

            anchors.top: root.clockAtBottom ? parent.top : undefined
            anchors.topMargin: 40
            anchors.bottom: root.clockAtBottom ? undefined : parent.bottom
            anchors.bottomMargin: 40

            Text {
                text: root.unlockText
                font.pixelSize: 16
                font.family: root.effectiveFontFamily
                color: Qt.rgba(
                    root.accentColor.r,
                    root.accentColor.g,
                    root.accentColor.b,
                    0.70
                )
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            visible: root.unlockShouldCenter
            text: root.unlockText
            font.pixelSize: 16
            font.family: root.effectiveFontFamily
            color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.70
            )
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: root.clockAtBottom ? parent.top : undefined
            anchors.topMargin: 40
            anchors.bottom: root.clockAtBottom ? undefined : parent.bottom
            anchors.bottomMargin: 40
        }
    }

    // =====================================================
    // Pantalla de usuario y contraseña
    // =====================================================
    Item {
        id: loginScreen
        anchors.fill: parent
        opacity: root.showLogin ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        Item {
            id: loginPanel
            width: Math.min(560, root.width * 0.42)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Rectangle {
                visible: root.loginPanelStyle === "gradient"
                anchors.fill: parent

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop {
                        position: 0.15
                        color: Qt.rgba(0, 0, 0, root.textBgOpacity)
                    }
                    GradientStop {
                        position: 0.85
                        color: Qt.rgba(0, 0, 0, root.textBgOpacity)
                    }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            Rectangle {
                visible: root.loginPanelStyle === "glass"
                anchors.fill: parent
                radius: root.panelRadius
                color: Qt.rgba(0, 0, 0, root.panelTintOpacity + 0.12)
                border.color: Qt.rgba(
                    root.accentColor.r,
                    root.accentColor.g,
                    root.accentColor.b,
                    0.08
                )
                border.width: 1
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: Math.max(40, root.height * 0.065)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Rectangle {
                    width: 96
                    height: 96
                    radius: width / 2
                    color: Qt.rgba(
                        root.accentColor.r,
                        root.accentColor.g,
                        root.accentColor.b,
                        0.15
                    )
                    border.color: Qt.rgba(
                        root.accentColor.r,
                        root.accentColor.g,
                        root.accentColor.b,
                        0.30
                    )
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: userListView.currentItem
                            ? userListView.currentItem.userIcon
                            : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    text: {
                        if (!userListView.currentItem)
                            return ""
                        return userListView.currentItem.userRealName.length > 0
                            ? userListView.currentItem.userRealName
                            : userListView.currentItem.userName
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 22
                    font.family: root.effectiveFontFamily
                    color: root.accentColor
                }
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.max(50, root.height * 0.065)
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 80
                spacing: 14

                Item {
                    id: sessionSelector
                    width: parent.width
                    height: 40
                    property bool expanded: false

                    Rectangle {
                        id: sessionBox
                        anchors.fill: parent
                        radius: 20
                        color: Qt.rgba(1, 1, 1, 0.06)
                        border.color: Qt.rgba(
                            root.accentColor.r,
                            root.accentColor.g,
                            root.accentColor.b,
                            0.30
                        )
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: sessionListView.currentItem
                                    ? sessionListView.currentItem.sessionName
                                    : ""
                                font.pixelSize: 14
                                font.family: root.effectiveFontFamily
                                color: root.accentColor
                            }

                            Text {
                                text: sessionSelector.expanded ? "▲" : "▼"
                                font.pixelSize: 10
                                color: Qt.rgba(
                                    root.accentColor.r,
                                    root.accentColor.g,
                                    root.accentColor.b,
                                    0.70
                                )
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: sessionSelector.expanded = !sessionSelector.expanded
                        }
                    }

                    Rectangle {
                        id: sessionDropdown
                        visible: sessionSelector.expanded
                        width: parent.width
                        anchors.bottom: sessionBox.top
                        anchors.bottomMargin: 8
                        height: Math.min(sessionModel.count, 4) * 40
                        radius: 14
                        color: Qt.rgba(0.05, 0.02, 0.03, 0.95)
                        border.color: Qt.rgba(
                            root.accentColor.r,
                            root.accentColor.g,
                            root.accentColor.b,
                            0.30
                        )
                        border.width: 1
                        clip: true
                        z: 300

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 4
                            model: sessionModel
                            clip: true

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 36
                                radius: 10
                                color: index === sessionListView.currentIndex
                                    ? Qt.rgba(
                                        root.accentColor.r,
                                        root.accentColor.g,
                                        root.accentColor.b,
                                        0.15
                                    )
                                    : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: name
                                    font.pixelSize: 13
                                    font.family: root.effectiveFontFamily
                                    color: root.accentColor
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        sessionListView.currentIndex = index
                                        sessionSelector.expanded = false
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: root.loginErrorText.length > 0
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: root.loginErrorText
                    font.pixelSize: 13
                    font.family: root.effectiveFontFamily
                    color: "#ff8a9d"
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Rectangle {
                        id: passwordBox
                        width: parent.parent.width - 60
                        height: 48
                        radius: 24
                        color: Qt.rgba(1, 1, 1, 0.08)
                        border.color: Qt.rgba(
                            root.accentColor.r,
                            root.accentColor.g,
                            root.accentColor.b,
                            0.40
                        )
                        border.width: 1

                        TextInput {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 44
                            anchors.topMargin: 14
                            anchors.bottomMargin: 14
                            echoMode: root.showPassword
                                ? TextInput.Normal
                                : TextInput.Password
                            color: root.accentColor
                            selectionColor: Qt.rgba(
                                root.accentColor.r,
                                root.accentColor.g,
                                root.accentColor.b,
                                0.35
                            )
                            selectedTextColor: "#111111"
                            font.pixelSize: 16
                            font.family: root.effectiveFontFamily
                            clip: true

                            Keys.onReturnPressed: root.doLogin()
                            Keys.onEnterPressed: root.doLogin()
                            Keys.onEscapePressed: function(event) {
                                text = ""
                                root.showLogin = false
                                root.forceActiveFocus()
                                event.accepted = true
                            }
                        }

                        Item {
                            id: eyeIcon
                            width: 22
                            height: 22
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                id: eyeShape
                                anchors.centerIn: parent
                                width: 20
                                height: 12
                                radius: 6
                                color: "transparent"
                                border.color: Qt.rgba(
                                    root.accentColor.r,
                                    root.accentColor.g,
                                    root.accentColor.b,
                                    0.85
                                )
                                border.width: 1.5
                            }

                            Rectangle {
                                anchors.centerIn: eyeShape
                                width: 5
                                height: 5
                                radius: 2.5
                                color: Qt.rgba(
                                    root.accentColor.r,
                                    root.accentColor.g,
                                    root.accentColor.b,
                                    0.85
                                )
                            }

                            Rectangle {
                                visible: root.showPassword
                                anchors.centerIn: parent
                                width: 24
                                height: 1.6
                                rotation: 45
                                color: Qt.rgba(
                                    root.accentColor.r,
                                    root.accentColor.g,
                                    root.accentColor.b,
                                    0.95
                                )
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                onClicked: root.showPassword = !root.showPassword
                            }
                        }
                    }

                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: root.accentColor

                        Text {
                            anchors.centerIn: parent
                            text: "→"
                            font.pixelSize: 20
                            color: "#1a1a1a"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.doLogin()
                        }
                    }
                }
            }
        }
    }

    // =====================================================
    // Acciones de energía
    // =====================================================
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 20
        z: 100

        Text {
            text: "⏾"
            font.pixelSize: 20
            color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.85
            )
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: confirmDialog.show("suspend")
            }
        }

        Text {
            text: "⟳"
            font.pixelSize: 20
            color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.85
            )
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: confirmDialog.show("reboot")
            }
        }

        Text {
            text: "⏻"
            font.pixelSize: 20
            color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.85
            )
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: confirmDialog.show("shutdown")
            }
        }
    }

    Item {
        id: confirmDialog
        anchors.fill: parent
        visible: false
        z: 200
        property string action: ""

        function show(actionName) {
            action = actionName
            visible = true
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.60
        }

        Rectangle {
            width: Math.min(420, root.width - 40)
            height: 180
            radius: 20
            anchors.centerIn: parent
            color: Qt.rgba(0.08, 0.03, 0.05, 0.95)

            Column {
                anchors.centerIn: parent
                spacing: 30

                Text {
                    text: {
                        if (confirmDialog.action === "suspend")
                            return root.language === "es"
                                ? "¿Suspender el equipo?"
                                : "Suspend the computer?"
                        if (confirmDialog.action === "reboot")
                            return root.language === "es"
                                ? "¿Reiniciar el equipo?"
                                : "Restart the computer?"
                        return root.language === "es"
                            ? "¿Apagar el equipo?"
                            : "Shut down the computer?"
                    }
                    color: "white"
                    font.pixelSize: 18
                    font.family: root.effectiveFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    Rectangle {
                        width: 130
                        height: 40
                        radius: 20
                        color: "transparent"
                        border.color: Qt.rgba(
                            root.accentColor.r,
                            root.accentColor.g,
                            root.accentColor.b,
                            0.40
                        )
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.language === "es" ? "Cancelar" : "Cancel"
                            color: root.accentColor
                            font.family: root.effectiveFontFamily
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: confirmDialog.visible = false
                        }
                    }

                    Rectangle {
                        width: 130
                        height: 40
                        radius: 20
                        color: root.accentColor

                        Text {
                            anchors.centerIn: parent
                            text: root.language === "es" ? "Aceptar" : "OK"
                            color: "#1a1a1a"
                            font.family: root.effectiveFontFamily
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (confirmDialog.action === "suspend")
                                    sddm.suspend()
                                else if (confirmDialog.action === "reboot")
                                    sddm.reboot()
                                else
                                    sddm.powerOff()

                                confirmDialog.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}