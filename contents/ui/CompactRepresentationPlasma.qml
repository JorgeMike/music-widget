import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

// Estilo Plasma en el panel: el ícono del tema, como el reproductor de KDE.
// Clic: abre · Clic medio: play/pausa · Rueda: volumen · Atrás/adelante: canción.
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

    Kirigami.Icon {
        anchors.fill: parent
        source: Plasmoid.icon
        active: compact.containsMouse
    }
}
