import QtQuick 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#2d0a15"
    focus: true

    Component.onCompleted: root.forceActiveFocus()

    // ==== Lectura de theme.conf / theme.conf.user ====
    property string clockPosition: config.keys().indexOf("ClockPosition") !== -1
                                    ? config.stringValue("ClockPosition") : "center"
    property string clockPositionV: config.keys().indexOf("ClockPositionV") !== -1
                                     ? config.stringValue("ClockPositionV") : "center"
    property string clockOrientation: config.keys().indexOf("ClockOrientation") !== -1
                                       ? config.stringValue("ClockOrientation") : "horizontal"
    property string language: config.keys().indexOf("Language") !== -1
                               ? config.stringValue("Language") : "es"
    property bool use12Hour: config.keys().indexOf("Use12Hour") !== -1
                              ? config.stringValue("Use12Hour") === "true" : false
    property string backgroundImage: config.keys().indexOf("BackgroundImage") !== -1
                                      ? config.stringValue("BackgroundImage") : "assets/background.jpg"
    property real overlayOpacity: config.keys().indexOf("OverlayOpacity") !== -1
                                   ? parseFloat(config.stringValue("OverlayOpacity")) : 0.35
    property real textBgOpacity: config.keys().indexOf("TextBackgroundOpacity") !== -1
                                  ? parseFloat(config.stringValue("TextBackgroundOpacity")) : 0.45
    property string accentMode: config.keys().indexOf("AccentMode") !== -1
                                 ? config.stringValue("AccentMode") : "auto"
    property string accentColorConfig: config.keys().indexOf("AccentColor") !== -1
                                        ? config.stringValue("AccentColor") : "#f4c6cf"
    property real clockMarginH: config.keys().indexOf("ClockMarginH") !== -1
                                 ? parseFloat(config.stringValue("ClockMarginH")) : 80
    property real clockMarginV: config.keys().indexOf("ClockMarginV") !== -1
                                 ? parseFloat(config.stringValue("ClockMarginV")) : 40
    property bool splitLayout: config.keys().indexOf("SplitLayout") !== -1
                                ? config.stringValue("SplitLayout") === "true" : false
    property bool dateBold: config.keys().indexOf("DateBold") !== -1
                             ? config.stringValue("DateBold") === "true" : false
    property real clockFontSize: config.keys().indexOf("ClockFontSize") !== -1
                                  ? parseFloat(config.stringValue("ClockFontSize")) : 110
    property real dateFontSize: config.keys().indexOf("DateFontSize") !== -1
                                 ? parseFloat(config.stringValue("DateFontSize")) : 24
    property bool unlockCentered: config.keys().indexOf("UnlockCentered") !== -1
                                   ? config.stringValue("UnlockCentered") === "true" : false
    property string panelStyle: config.keys().indexOf("PanelStyle") !== -1
                                 ? config.stringValue("PanelStyle") : "gradient"
    property real panelBlurRadius: config.keys().indexOf("PanelBlurRadius") !== -1
                                    ? parseFloat(config.stringValue("PanelBlurRadius")) : 64
    property real panelRadius: config.keys().indexOf("PanelRadius") !== -1
                                ? parseFloat(config.stringValue("PanelRadius")) : 32
    property real panelTintOpacity: config.keys().indexOf("PanelTintOpacity") !== -1
                                     ? parseFloat(config.stringValue("PanelTintOpacity")) : 0.25
    property string fontFamily: config.keys().indexOf("FontFamily") !== -1
                                 ? config.stringValue("FontFamily") : ""
    property string customFontFile: config.keys().indexOf("CustomFontFile") !== -1
                                     ? config.stringValue("CustomFontFile") : ""
    property string backgroundType: config.keys().indexOf("BackgroundType") !== -1
                                     ? config.stringValue("BackgroundType") : "image"
    property string backgroundVideo: config.keys().indexOf("BackgroundVideo") !== -1
                                      ? config.stringValue("BackgroundVideo") : ""
    property string backgroundVideoFallbackGif: config.keys().indexOf("BackgroundVideoFallbackGif") !== -1
                                      ? config.stringValue("BackgroundVideoFallbackGif") : "assets/videos/fallback.gif"
    property bool loginDarkenEnabled: config.keys().indexOf("LoginDarkenEnabled") !== -1
                                       ? config.stringValue("LoginDarkenEnabled") === "true" : true
    property real loginDarkenOpacity: config.keys().indexOf("LoginDarkenOpacity") !== -1
                                       ? parseFloat(config.stringValue("LoginDarkenOpacity")) : 0.25
    property string loginPanelStyle: config.keys().indexOf("LoginPanelStyle") !== -1
                                      ? config.stringValue("LoginPanelStyle") : "glass"

    property string effectiveFontFamily: customFontLoader.status === FontLoader.Ready
                                          ? customFontLoader.name
                                          : (fontFamily.length > 0 ? fontFamily : Qt.application.font.family)

    FontLoader {
        id: customFontLoader
        source: customFontFile.length > 0 ? customFontFile : ""
    }

    property bool splitActive: splitLayout && clockPosition !== "center"

    property color extractedAccentColor: "#f4c6cf"
    property color accentColor: (accentMode === "custom" || backgroundType === "video")
                                 ? accentColorConfig : extractedAccentColor

    property bool clockAtBottom: clockPositionV === "bottom"
    property bool unlockShouldCenter: unlockCentered || splitActive

    property string currentTimeText: use12Hour
                                      ? Qt.formatTime(new Date(), "h:mm AP")
                                      : Qt.formatTime(new Date(), "hh:mm")
    property string currentHourText: {
        var h = new Date().getHours()
        if (use12Hour) { h = h % 12; if (h === 0) h = 12 }
        var s = h.toString()
        return s.length < 2 ? "0" + s : s
    }
    property string currentMinuteText: {
        var m = new Date().getMinutes()
        var s = m.toString()
        return s.length < 2 ? "0" + s : s
    }
    property string currentAmPmText: new Date().getHours() < 12 ? "AM" : "PM"

    // ✅ FECHA CORREGIDA - Sin usar Qt.locale() que causa [object Object]
    property string currentDateText: {
        var d = new Date()
        if (language === "es") {
            var days = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]
            var months = ["enero", "febrero", "marzo", "abril", "mayo", "junio",
                          "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
            return days[d.getDay()] + ", " + d.getDate() + " de " + months[d.getMonth()]
        } else {
            var daysEn = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            var monthsEn = ["January", "February", "March", "April", "May", "June",
                            "July", "August", "September", "October", "November", "December"]
            return daysEn[d.getDay()] + ", " + monthsEn[d.getMonth()] + " " + d.getDate()
        }
    }

    property string unlockText: language === "es"
                                 ? "Presiona cualquier tecla para desbloquear"
                                 : "Press any key to unlock"

    // ==== Estado: pantalla de bloqueo vs pantalla de usuario/contraseña ====
    property bool showLogin: false
    property bool showPassword: false

    Keys.onPressed: {
        if (!showLogin) {
            showLogin = true
            event.accepted = true
        }
    }
    onShowLoginChanged: {
        if (showLogin) {
            passwordInput.forceActiveFocus()
        } else {
            root.forceActiveFocus()
        }
    }

    function doLogin() {
        var uname = userListView.currentItem ? userListView.currentItem.userName : ""
        var sidx = sessionListView.currentIndex >= 0 ? sessionListView.currentIndex : 0
        sddm.login(uname, passwordInput.text, sidx)
    }

    // Modelos ocultos
    ListView {
        id: userListView
        visible: false
        width: 1; height: 1
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
        visible: false
        width: 1; height: 1
        cacheBuffer: 100000
        model: sessionModel
        currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
        delegate: Item {
            property string sessionName: name
        }
    }

    // ======================================================
    // GESTIÓN DE FONDO ROBUSTA (Imagen, Video Externo y Fallback)
    // ======================================================

    Image {
        id: staticBackground
        anchors.fill: parent
        source: backgroundImage
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: backgroundType === "image" || (backgroundType === "video" && videoLoader.status !== Loader.Ready)
        onStatusChanged: if (status === Image.Ready) colorCanvas.requestPaint()
    }

    AnimatedImage {
        id: gifFallback
        anchors.fill: parent
        source: backgroundVideoFallbackGif
        fillMode: Image.PreserveAspectCrop
        visible: backgroundType === "video" && videoLoader.status !== Loader.Ready
        playing: visible
        asynchronous: true
        cache: false
    }

    Loader {
        id: videoLoader
        anchors.fill: parent
        active: backgroundType === "video"
        visible: status === Loader.Ready
        source: backgroundType === "video" ? "VideoBackground.qml" : ""
        onLoaded: {
            console.log("Video cargado correctamente desde archivo externo.")
            if (item) {
                item.videoSource = backgroundVideo
            }
        }
        onStatusChanged: {
            if (status === Loader.Error) {
                console.log("No se pudo cargar VideoBackground.qml. Usando GIF de respaldo.")
                gifFallback.visible = true
            }
        }
    }

    Canvas {
        id: colorCanvas
        width: 32; height: 32
        opacity: 0
        onPaint: {
            if (backgroundType === "video" || staticBackground.status !== Image.Ready) return
            var ctx = getContext("2d")
            ctx.drawImage(staticBackground, 0, 0, width, height)
            var imgData = ctx.getImageData(0, 0, width, height)
            var data = imgData.data
            var totalLum = 0, count = 0, sumSin = 0, sumCos = 0, sumSat = 0
            for (var i = 0; i < data.length; i += 4) {
                var pr = data[i] / 255, pg = data[i+1] / 255, pb = data[i+2] / 255
                var lum = 0.299 * pr + 0.587 * pg + 0.114 * pb
                totalLum += lum; count++
                var pc = Qt.rgba(pr, pg, pb, 1)
                var pSat = pc.hslSaturation, pHue = pc.hslHue
                if (pHue < 0) pHue = 0
                var angle = pHue * 2 * Math.PI
                sumSin += Math.sin(angle) * pSat
                sumCos += Math.cos(angle) * pSat
                sumSat += pSat
            }
            var avgLuminance = totalLum / count
            var finalHue = 0
            if (sumSat > 0.001) {
                var avgAngle = Math.atan2(sumSin, sumCos)
                finalHue = avgAngle / (2 * Math.PI)
                if (finalHue < 0) finalHue += 1
            }
            var finalSat = Math.max(0.45, Math.min(0.9, (sumSat / count) * 3))
            var targetLightness = avgLuminance < 0.5 ? 0.85 : 0.22
            root.extractedAccentColor = Qt.hsla(finalHue, finalSat, targetLightness, 1)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: overlayOpacity
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: (showLogin && loginDarkenEnabled) ? loginDarkenOpacity : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // ======================================================
    // PANTALLA DE BLOQUEO
    // ======================================================
    Item {
        id: lockScreen
        anchors.fill: parent
        opacity: showLogin ? 0 : 1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        MouseArea {
            anchors.fill: parent
            onClicked: showLogin = true
        }

        // ---- LAYOUT NORMAL ----
        Item {
            id: contentBlock
            visible: !splitActive
            width: 560
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.left: clockPosition === "left" ? parent.left : undefined
            anchors.leftMargin: clockMarginH
            anchors.horizontalCenter: clockPosition === "center" ? parent.horizontalCenter : undefined
            anchors.right: clockPosition === "right" ? parent.right : undefined
            anchors.rightMargin: clockMarginH

            Rectangle {
                visible: panelStyle === "gradient"
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop { position: 0.15; color: Qt.rgba(0, 0, 0, textBgOpacity) }
                    GradientStop { position: 0.85; color: Qt.rgba(0, 0, 0, textBgOpacity) }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            Rectangle {
                visible: panelStyle === "glass"
                anchors.fill: parent
                radius: panelRadius
                color: Qt.rgba(0, 0, 0, panelTintOpacity + 0.12)
                border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.08)
                border.width: 1
            }

            Column {
                id: clockColumn
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: clockPositionV === "top" ? parent.top : undefined
                anchors.topMargin: clockMarginV
                anchors.verticalCenter: clockPositionV === "center" ? parent.verticalCenter : undefined
                anchors.bottom: clockPositionV === "bottom" ? parent.bottom : undefined
                anchors.bottomMargin: clockMarginV
                spacing: 12

                Text {
                    visible: clockOrientation === "horizontal"
                    text: currentTimeText
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: clockFontSize
                    font.family: effectiveFontFamily
                    font.weight: Font.Medium
                    color: accentColor
                }

                Column {
                    visible: clockOrientation === "vertical"
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: -clockFontSize * 0.12

                    Text {
                        text: currentHourText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: clockFontSize
                        font.family: effectiveFontFamily
                        font.weight: Font.Medium
                        color: accentColor
                    }
                    Text {
                        text: currentMinuteText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: clockFontSize
                        font.family: effectiveFontFamily
                        font.weight: Font.Medium
                        color: accentColor
                    }
                    Text {
                        visible: use12Hour
                        text: currentAmPmText
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Math.max(14, clockFontSize * 0.18)
                        font.family: effectiveFontFamily
                        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.75)
                    }
                }

                // ✅ FECHA - Ahora se muestra correctamente
                Text {
                    text: currentDateText
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: dateFontSize
                    font.family: effectiveFontFamily
                    font.bold: dateBold
                    color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.75)
                }
            }
        }

        // ---- LAYOUT DIVIDIDO ----
        Item {
            id: splitBlock
            visible: splitActive
            anchors.fill: parent

            Text {
                id: splitClockText
                text: currentTimeText
                font.pixelSize: clockFontSize
                font.family: effectiveFontFamily
                font.weight: Font.Medium
                color: accentColor

                anchors.left: clockPosition === "left" ? parent.left : undefined
                anchors.leftMargin: clockMarginH
                anchors.right: clockPosition === "right" ? parent.right : undefined
                anchors.rightMargin: clockMarginH

                anchors.top: clockPositionV === "top" ? parent.top : undefined
                anchors.topMargin: clockMarginV
                anchors.verticalCenter: clockPositionV === "center" ? parent.verticalCenter : undefined
                anchors.bottom: clockPositionV === "bottom" ? parent.bottom : undefined
                anchors.bottomMargin: clockMarginV
            }

            // ✅ FECHA en layout dividido - También corregida
            Text {
                text: currentDateText
                font.pixelSize: dateFontSize
                font.family: effectiveFontFamily
                font.bold: dateBold
                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.75)

                anchors.right: clockPosition === "left" ? parent.right : undefined
                anchors.rightMargin: clockMarginH
                anchors.left: clockPosition === "right" ? parent.left : undefined
                anchors.leftMargin: clockMarginH

                anchors.verticalCenter: splitClockText.verticalCenter
            }
        }

        Item {
            id: unlockFollowBlock
            visible: !unlockShouldCenter
            width: 560
            anchors.left: clockPosition === "left" ? parent.left : undefined
            anchors.leftMargin: clockMarginH
            anchors.horizontalCenter: clockPosition === "center" ? parent.horizontalCenter : undefined
            anchors.right: clockPosition === "right" ? parent.right : undefined
            anchors.rightMargin: clockMarginH
            anchors.top: clockAtBottom ? parent.top : undefined
            anchors.topMargin: 40
            anchors.bottom: clockAtBottom ? undefined : parent.bottom
            anchors.bottomMargin: 40

            Text {
                text: unlockText
                font.pixelSize: 16
                font.family: effectiveFontFamily
                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.7)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            visible: unlockShouldCenter
            text: unlockText
            font.pixelSize: 16
            font.family: effectiveFontFamily
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.7)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: clockAtBottom ? parent.top : undefined
            anchors.topMargin: 40
            anchors.bottom: clockAtBottom ? undefined : parent.bottom
            anchors.bottomMargin: 40
        }
    }

    // ======================================================
    // PANTALLA DE USUARIO / CONTRASEÑA
    // ======================================================
    Item {
        id: loginScreen
        anchors.fill: parent
        opacity: showLogin ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        Item {
            id: loginPanel
            width: 560
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Rectangle {
                visible: loginPanelStyle === "gradient"
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop { position: 0.15; color: Qt.rgba(0, 0, 0, textBgOpacity) }
                    GradientStop { position: 0.85; color: Qt.rgba(0, 0, 0, textBgOpacity) }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            Rectangle {
                visible: loginPanelStyle === "glass"
                anchors.fill: parent
                radius: panelRadius
                color: Qt.rgba(0, 0, 0, panelTintOpacity + 0.12)
                border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.08)
                border.width: 1
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: 70
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Rectangle {
                    width: 96; height: 96
                    radius: width / 2
                    color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
                    border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: userListView.currentItem ? userListView.currentItem.userIcon : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    text: userListView.currentItem
                          ? (userListView.currentItem.userRealName.length > 0
                             ? userListView.currentItem.userRealName
                             : userListView.currentItem.userName)
                          : ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 22
                    font.family: effectiveFontFamily
                    color: accentColor
                }
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 70
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
                        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: sessionListView.currentItem ? sessionListView.currentItem.sessionName : ""
                                font.pixelSize: 14
                                font.family: effectiveFontFamily
                                color: accentColor
                            }
                            Text {
                                text: sessionSelector.expanded ? "▲" : "▼"
                                font.pixelSize: 10
                                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.7)
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
                        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                        border.width: 1
                        clip: true
                        z: 300

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 4
                            model: sessionModel
                            clip: true
                            delegate: Rectangle {
                                width: parent.width
                                height: 36
                                radius: 10
                                color: index === sessionListView.currentIndex
                                       ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
                                       : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: name
                                    font.pixelSize: 13
                                    font.family: effectiveFontFamily
                                    color: accentColor
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

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Rectangle {
                        id: passwordBox
                        width: parent.parent.width - 60
                        height: 48
                        radius: 24
                        color: Qt.rgba(1, 1, 1, 0.08)
                        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.4)
                        border.width: 1

                        TextInput {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 44
                            anchors.topMargin: 14
                            anchors.bottomMargin: 14
                            echoMode: showPassword ? TextInput.Normal : TextInput.Password
                            color: accentColor
                            font.pixelSize: 16
                            font.family: effectiveFontFamily
                            clip: true
                            Keys.onReturnPressed: doLogin()
                            Keys.onEnterPressed: doLogin()
                            Keys.onEscapePressed: {
                                text = ""
                                showLogin = false
                                root.forceActiveFocus()
                                event.accepted = true
                            }
                        }

                        Item {
                            id: eyeIcon
                            width: 22; height: 22
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                id: eyeShape
                                anchors.centerIn: parent
                                width: 20; height: 12
                                radius: 6
                                color: "transparent"
                                border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.85)
                                border.width: 1.5
                            }
                            Rectangle {
                                anchors.centerIn: eyeShape
                                width: 5; height: 5
                                radius: 2.5
                                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.85)
                            }

                            Rectangle {
                                visible: showPassword
                                anchors.centerIn: parent
                                width: 24; height: 1.6
                                rotation: 45
                                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.95)
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                onClicked: showPassword = !showPassword
                            }
                        }
                    }

                    Rectangle {
                        width: 48; height: 48
                        radius: 24
                        color: accentColor

                        Text {
                            anchors.centerIn: parent
                            text: "→"
                            font.pixelSize: 20
                            color: "#1a1a1a"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: doLogin()
                        }
                    }
                }
            }
        }
    }

    // ======================================================
    // BOTONES: suspender, reiniciar, apagar
    // ======================================================
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 20
        z: 100

        Text {
            text: "⏾"
            font.pixelSize: 20
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.85)
            MouseArea { anchors.fill: parent; onClicked: confirmDialog.show("suspend") }
        }
        Text {
            text: "⟳"
            font.pixelSize: 20
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.85)
            MouseArea { anchors.fill: parent; onClicked: confirmDialog.show("reboot") }
        }
        Text {
            text: "⏻"
            font.pixelSize: 20
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.85)
            MouseArea { anchors.fill: parent; onClicked: confirmDialog.show("shutdown") }
        }
    }

    Item {
        id: confirmDialog
        anchors.fill: parent
        visible: false
        z: 200
        property string action: ""
        function show(a) { action = a; visible = true }

        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.6 }

        Rectangle {
            width: 420; height: 180
            radius: 20
            anchors.centerIn: parent
            color: Qt.rgba(0.08, 0.03, 0.05, 0.95)

            Column {
                anchors.centerIn: parent
                spacing: 30

                Text {
                    text: confirmDialog.action === "suspend"
                          ? (language === "es" ? "¿Suspender el equipo?" : "Suspend the computer?")
                          : confirmDialog.action === "reboot"
                          ? (language === "es" ? "¿Reiniciar el equipo?" : "Restart the computer?")
                          : (language === "es" ? "¿Apagar el equipo?" : "Shut down the computer?")
                    color: "white"
                    font.pixelSize: 18
                    font.family: effectiveFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    Rectangle {
                        width: 130; height: 40
                        radius: 20
                        color: "transparent"
                        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.4)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: language === "es" ? "Cancelar" : "Cancel"
                            color: accentColor
                            font.family: effectiveFontFamily
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: confirmDialog.visible = false
                        }
                    }

                    Rectangle {
                        width: 130; height: 40
                        radius: 20
                        color: accentColor

                        Text {
                            anchors.centerIn: parent
                            text: language === "es" ? "Aceptar" : "OK"
                            color: "#1a1a1a"
                            font.family: effectiveFontFamily
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (confirmDialog.action === "suspend") sddm.suspend()
                                else if (confirmDialog.action === "reboot") sddm.reboot()
                                else sddm.powerOff()
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
        onTriggered: {
            root.currentTimeText = use12Hour
                        ? Qt.formatTime(new Date(), "h:mm AP")
                        : Qt.formatTime(new Date(), "hh:mm")
            var h = new Date().getHours()
            if (use12Hour) { h = h % 12; if (h === 0) h = 12 }
            var hs = h.toString()
            root.currentHourText = hs.length < 2 ? "0" + hs : hs
            var m = new Date().getMinutes()
            var ms = m.toString()
            root.currentMinuteText = ms.length < 2 ? "0" + ms : ms
            root.currentAmPmText = new Date().getHours() < 12 ? "AM" : "PM"
        }
    }
}