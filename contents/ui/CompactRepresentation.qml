import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

// En el panel: miniatura de la portada con barritas cuando suena.
// Clic: abre el reproductor · Clic medio: play/pausa · Rueda: volumen.
MouseArea {
    id: compact

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton

    onClicked: mouse => {
        switch (mouse.button) {
        case Qt.MiddleButton:  root.togglePlaying(); break
        case Qt.BackButton:    root.previous(); break
        case Qt.ForwardButton: root.next(); break
        default:               root.expanded = !root.expanded
        }
    }
    onWheel: wheel => root.changeVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)

    Item {
        id: thumb
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) - 4
        height: width
        scale: compact.pressed ? 0.92 : 1
        Behavior on scale { NumberAnimation { duration: 120 } }

        RoundedImage {
            anchors.fill: parent
            radius: Math.max(3, width * 0.18)
            source: root.hasMedia ? root.albumArt : ""
            sourceResolution: 96
            fallbackIcon: Plasmoid.icon
            fallbackColor: Kirigami.Theme.textColor
        }

        Rectangle {
            anchors.fill: parent
            radius: Math.max(3, width * 0.18)
            color: Qt.rgba(0, 0, 0, 0.45)
            visible: root.isPlaying && root.albumArt !== ""
            opacity: compact.containsMouse ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Equalizer {
                anchors.centerIn: parent
                running: false   // barras quietas en el panel: cero redibujos
                barWidth: Math.max(2, Math.round(thumb.width / 12))
                maxHeight: thumb.height * 0.45
            }
        }
    }
}
