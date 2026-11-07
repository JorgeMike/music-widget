import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

Item {
    id: full

    readonly property int gu: Kirigami.Units.gridUnit
    readonly property real cardRadius: gu * 1.1
    // Margen para que la sombra de la tarjeta se vea en el escritorio.
    readonly property real shadowMargin: root.inPanel ? 0 : Kirigami.Units.largeSpacing
    readonly property color fgDim: Qt.rgba(1, 1, 1, 0.68)

    Layout.preferredWidth: gu * 25
    Layout.preferredHeight: gu * 11
    Layout.minimumWidth: gu * 19
    Layout.minimumHeight: gu * 9

    // ---- Color de acento sacado de la portada ----
    Kirigami.ImageColors {
        id: colors
        source: cover
    }
    Timer {
        id: colorsDelay
        interval: 350           // espera al fundido de la portada
        onTriggered: colors.update()
    }
    Connections {
        target: cover
        function onReadyChanged() { if (cover.ready) colorsDelay.restart() }
    }
    function vivid(c) {
        return Qt.hsla(c.hslHue,
                       Math.max(c.hslSaturation, 0.5),
                       Math.min(Math.max(c.hslLightness, 0.55), 0.72), 1)
    }
    property color accent: cover.ready && colors.palette.length > 0
        ? vivid(colors.dominant) : Kirigami.Theme.highlightColor
    Behavior on accent { ColorAnimation { duration: 400 } }

    // ---- Posición: el reproductor no la emite cada segundo, así que la avanzamos aquí ----
    property real position: 0
    readonly property real length: root.player?.length ?? 0
    readonly property real playerPosition: root.player?.position ?? 0
    onPlayerPositionChanged: if (!seekBar.dragging) position = playerPosition
    onLengthChanged: {
        position = 0
        root.player?.updatePosition()
    }
    Timer {
        interval: 1000
        repeat: true
        running: root.isPlaying && full.length > 0 && !seekBar.dragging
        onTriggered: {
            const next = full.position + 1000000 * (root.player?.rate ?? 1)
            if (next >= full.length) root.player?.updatePosition()
            else full.position = next
        }
    }
    function formatTime(us) {
        const total = Math.max(0, Math.floor(us / 1000000))
        const h = Math.floor(total / 3600)
        const m = Math.floor((total % 3600) / 60)
        const s = (total % 60).toString().padStart(2, "0")
        return h > 0 ? h + ":" + m.toString().padStart(2, "0") + ":" + s : m + ":" + s
    }

    // ---- Tarjeta ----
    Kirigami.ShadowedRectangle {
        id: cardShadow
        anchors.fill: parent
        anchors.margins: full.shadowMargin
        radius: full.cardRadius
        color: "#161616"
        shadow.size: full.shadowMargin > 0 ? 28 : 0
        shadow.yOffset: 6
        shadow.color: Qt.rgba(0, 0, 0, 0.45)
    }

    Item {
        id: card
        anchors.fill: cardShadow
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: cardMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        // Fondo base teñido con el acento (se ve sin portada)
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Qt.darker(full.accent, 2.6) }
                GradientStop { position: 1; color: "#111111" }
            }
        }

        // Portada desenfocada de fondo
        Image {
            id: bgArt
            anchors.fill: parent
            source: root.albumArt
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 256
            sourceSize.height: 256
            asynchronous: true
            visible: false
        }
        MultiEffect {
            anchors.fill: parent
            source: bgArt
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            autoPaddingEnabled: false
            saturation: 0.25
            brightness: -0.05
            opacity: bgArt.status === Image.Ready && root.hasMedia ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 500 } }
        }
        // Velo oscuro para que el texto siempre se lea
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.rgba(0, 0, 0, 0.30) }
                GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.62) }
            }
        }

        // Rueda del mouse en cualquier parte: volumen (muestra el OSD de Plasma)
        WheelHandler {
            enabled: root.hasMedia
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => root.changeVolume(event.angleDelta.y > 0 ? 0.05 : -0.05)
        }

        // ---- Estado vacío ----
        ColumnLayout {
            anchors.centerIn: parent
            visible: !root.hasMedia
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: full.gu * 3
                implicitHeight: implicitWidth
                source: "media-playback-start-symbolic"
                isMask: true
                color: full.fgDim
            }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Nada sonando"
                color: "white"
                font.pixelSize: full.gu * 1.15
                font.weight: Font.DemiBold
            }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Reproduce algo en Spotify, Elisa, VLC o el navegador"
                color: full.fgDim
                font: Kirigami.Theme.smallFont
            }
        }

        // ---- Contenido ----
        RowLayout {
            anchors.fill: parent
            anchors.margins: full.gu
            spacing: full.gu
            visible: root.hasMedia

            // Portada
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.maximumWidth: full.width * 0.4

                Kirigami.ShadowedRectangle {
                    anchors.fill: cover
                    radius: cover.radius
                    color: Qt.rgba(1, 1, 1, 0.08)
                    shadow.size: 18
                    shadow.yOffset: 4
                    shadow.color: Qt.rgba(0, 0, 0, 0.5)
                    scale: cover.scale
                }
                RoundedImage {
                    id: cover
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width
                    radius: full.gu * 0.7
                    source: root.albumArt
                    fallbackIcon: root.playerIcon
                    // Se encoge un poco en pausa
                    scale: root.isPlaying ? 1 : 0.93
                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }

                    // Contorno sutil para portadas muy oscuras
                    Rectangle {
                        anchors.fill: parent
                        radius: cover.radius
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.12)
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.canRaise
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.raise()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                // Igual de alta que la portada, para no separarse en tarjetas altas
                Layout.maximumHeight: Math.max(cover.height, implicitHeight)
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                // Encabezado: app actual + selector de reproductor
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: implicitWidth
                        source: root.playerIcon
                    }
                    PlasmaComponents3.Label {
                        text: root.identity
                        color: full.fgDim
                        font: Kirigami.Theme.smallFont
                        elide: Text.ElideRight
                        Layout.maximumWidth: full.gu * 8
                    }
                    Equalizer {
                        running: root.isPlaying
                        color: full.accent
                        barWidth: 2
                        maxHeight: 10
                        opacity: root.isPlaying ? 1 : 0.4
                    }
                    Item { Layout.fillWidth: true }

                    // Un botón por app abierta (solo si hay más de una)
                    Repeater {
                        id: playerChips
                        model: root.model
                        delegate: Rectangle {
                            required property int index
                            required property var model
                            visible: !model.isMultiplexer && playerChips.count > 2
                            width: Kirigami.Units.iconSizes.small + 8
                            height: width
                            radius: width / 2
                            color: index === root.model.currentIndex ? Qt.rgba(1, 1, 1, 0.2)
                                 : chipMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: Kirigami.Units.iconSizes.small
                                height: width
                                source: model.iconName
                            }
                            MouseArea {
                                id: chipMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.model.currentIndex = index
                            }
                            PlasmaComponents3.ToolTip {
                                text: model.identity
                                visible: chipMouse.containsMouse
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: root.track
                    color: "white"
                    font.pixelSize: Math.round(full.gu * 1.3)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: [root.artist, root.album].filter(s => s).join("  ·  ")
                    color: full.fgDim
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                    visible: text !== ""
                }

                Item { Layout.fillHeight: true }

                SeekBar {
                    id: seekBar
                    Layout.fillWidth: true
                    position: full.position
                    length: full.length
                    accent: full.accent
                    enabled: root.canSeek && full.length > 0
                    onSeekRequested: us => {
                        full.position = us
                        root.player.position = us
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: full.length > 0
                    PlasmaComponents3.Label {
                        text: full.formatTime(seekBar.dragging ? seekBar.dragFraction * full.length : full.position)
                        color: full.fgDim
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        font.features: { "tnum": 1 }
                    }
                    Item { Layout.fillWidth: true }
                    PlasmaComponents3.Label {
                        text: "-" + full.formatTime(full.length - full.position)
                        color: full.fgDim
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        font.features: { "tnum": 1 }
                    }
                }

                Item { Layout.preferredHeight: Kirigami.Units.smallSpacing }

                // Controles
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    ControlButton {
                        iconName: "media-playlist-shuffle"
                        tip: root.shuffle === Mpris.ShuffleStatus.On ? "Aleatorio: activado" : "Aleatorio"
                        size: full.gu * 1.8
                        accent: full.accent
                        checked: root.shuffle === Mpris.ShuffleStatus.On
                        enabled: root.canControl && root.shuffle !== Mpris.ShuffleStatus.Unknown
                        onClicked: root.toggleShuffle()
                    }
                    Item { Layout.fillWidth: true }
                    ControlButton {
                        iconName: "media-skip-backward"
                        tip: "Anterior"
                        accent: full.accent
                        enabled: root.canGoPrevious
                        onClicked: root.previous()
                    }
                    ControlButton {
                        iconName: root.isPlaying ? "media-playback-pause" : "media-playback-start"
                        tip: root.isPlaying ? "Pausar" : "Reproducir"
                        primary: true
                        size: full.gu * 2.6
                        accent: full.accent
                        enabled: root.isPlaying ? root.canPause : root.canPlay
                        onClicked: root.togglePlaying()
                    }
                    ControlButton {
                        iconName: "media-skip-forward"
                        tip: "Siguiente"
                        accent: full.accent
                        enabled: root.canGoNext
                        onClicked: root.next()
                    }
                    Item { Layout.fillWidth: true }
                    ControlButton {
                        iconName: root.loopStatus === Mpris.LoopStatus.Track
                            ? "media-playlist-repeat-song" : "media-playlist-repeat"
                        tip: root.loopStatus === Mpris.LoopStatus.Track ? "Repetir canción"
                           : root.loopStatus === Mpris.LoopStatus.Playlist ? "Repetir lista" : "Repetir"
                        size: full.gu * 1.8
                        accent: full.accent
                        checked: root.loopStatus === Mpris.LoopStatus.Track
                              || root.loopStatus === Mpris.LoopStatus.Playlist
                        enabled: root.canControl && root.loopStatus !== Mpris.LoopStatus.Unknown
                        onClicked: root.cycleLoop()
                    }
                }
            }
        }
    }

    Item {
        id: cardMask
        anchors.fill: card
        layer.enabled: true
        layer.smooth: true
        visible: false
        Rectangle { anchors.fill: parent; radius: full.cardRadius }
    }

    // Borde sutil tipo vidrio
    Rectangle {
        anchors.fill: card
        radius: full.cardRadius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.09)
    }
}
