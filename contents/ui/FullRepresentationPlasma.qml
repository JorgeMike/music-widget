import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

// Estilo Plasma: componentes estándar y colores del tema (claro u oscuro).
// Sin efectos: lo más ligero posible.
Item {
    id: full

    readonly property int gu: Kirigami.Units.gridUnit

    Layout.minimumWidth: gu * 16
    Layout.minimumHeight: gu * 7
    Layout.preferredWidth: gu * 21
    Layout.preferredHeight: gu * 8.5

    // ---- Posición: el reproductor no la emite cada segundo, así que la avanzamos aquí ----
    property real position: 0
    readonly property real length: root.player?.length ?? 0
    readonly property real playerPosition: root.player?.position ?? 0
    onPlayerPositionChanged: if (!slider.pressed) position = playerPosition
    onLengthChanged: {
        position = 0
        root.player?.updatePosition()
    }
    Timer {
        interval: 1000
        repeat: true
        running: root.isPlaying && full.length > 0 && !slider.pressed
                 && (root.expanded || !root.inPanel)
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

    WheelHandler {
        enabled: root.hasMedia
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.changeVolume(event.angleDelta.y > 0 ? 0.05 : -0.05)
    }

    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - full.gu * 2
        visible: !root.hasMedia
        iconName: "media-playback-start"
        text: "Nada sonando"
        explanation: "Reproduce algo en Spotify, Elisa, VLC o el navegador"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.largeSpacing
        visible: root.hasMedia

        // Portada
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.maximumWidth: full.width * 0.35

            Image {
                id: cover
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                source: root.albumArt
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 256
                sourceSize.height: 256
                visible: status === Image.Ready
            }
            Kirigami.Icon {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * 0.6
                height: width
                source: root.playerIcon
                visible: cover.status !== Image.Ready
            }
            MouseArea {
                anchors.fill: parent
                enabled: root.canRaise
                cursorShape: Qt.PointingHandCursor
                onClicked: root.raise()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: Math.max(cover.width, implicitHeight)
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 3
                    text: root.track
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }
                // Un botón por app abierta (solo si hay más de una)
                Repeater {
                    id: playerButtons
                    model: root.model
                    delegate: PlasmaComponents3.ToolButton {
                        required property int index
                        required property var model
                        visible: !model.isMultiplexer && playerButtons.count > 2
                        icon.name: model.iconName
                        checkable: true
                        checked: index === root.model.currentIndex
                        display: PlasmaComponents3.AbstractButton.IconOnly
                        text: model.identity
                        onClicked: root.model.currentIndex = index
                        PlasmaComponents3.ToolTip.text: text
                        PlasmaComponents3.ToolTip.visible: hovered
                    }
                }
            }
            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: [root.artist, root.album].filter(s => s).join(" — ")
                opacity: 0.7
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                visible: text !== ""
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: full.length > 0

                PlasmaComponents3.Label {
                    text: full.formatTime(slider.pressed ? slider.value : full.position)
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                }
                PlasmaComponents3.Slider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0
                    to: Math.max(1, full.length)
                    value: full.position
                    enabled: root.canSeek
                    onPressedChanged: if (!pressed) {
                        full.position = value
                        root.player.position = value
                    }
                }
                PlasmaComponents3.Label {
                    text: "-" + full.formatTime(full.length - full.position)
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0

                PlasmaComponents3.ToolButton {
                    icon.name: "media-playlist-shuffle"
                    checkable: true
                    checked: root.shuffle === Mpris.ShuffleStatus.On
                    enabled: root.canControl && root.shuffle !== Mpris.ShuffleStatus.Unknown
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    text: "Aleatorio"
                    onClicked: root.toggleShuffle()
                    PlasmaComponents3.ToolTip.text: text
                    PlasmaComponents3.ToolTip.visible: hovered
                }
                PlasmaComponents3.ToolButton {
                    icon.name: "media-skip-backward"
                    enabled: root.canGoPrevious
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    text: "Anterior"
                    onClicked: root.previous()
                }
                PlasmaComponents3.ToolButton {
                    icon.name: root.isPlaying ? "media-playback-pause" : "media-playback-start"
                    icon.width: Kirigami.Units.iconSizes.medium
                    icon.height: Kirigami.Units.iconSizes.medium
                    enabled: root.isPlaying ? root.canPause : root.canPlay
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    text: root.isPlaying ? "Pausar" : "Reproducir"
                    onClicked: root.togglePlaying()
                }
                PlasmaComponents3.ToolButton {
                    icon.name: "media-skip-forward"
                    enabled: root.canGoNext
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    text: "Siguiente"
                    onClicked: root.next()
                }
                PlasmaComponents3.ToolButton {
                    icon.name: root.loopStatus === Mpris.LoopStatus.Track
                        ? "media-playlist-repeat-song" : "media-playlist-repeat"
                    checkable: true
                    checked: root.loopStatus === Mpris.LoopStatus.Track
                          || root.loopStatus === Mpris.LoopStatus.Playlist
                    enabled: root.canControl && root.loopStatus !== Mpris.LoopStatus.Unknown
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    text: root.loopStatus === Mpris.LoopStatus.Track ? "Repetir canción" : "Repetir"
                    onClicked: root.cycleLoop()
                    PlasmaComponents3.ToolTip.text: text
                    PlasmaComponents3.ToolTip.visible: hovered
                }
            }
        }
    }
}
