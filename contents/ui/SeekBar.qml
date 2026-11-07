import QtQuick

// Barra de progreso fina que crece al pasar el mouse; clic o arrastre para buscar.
Item {
    id: seek

    property real position: 0     // microsegundos
    property real length: 0       // microsegundos
    property color accent: "white"
    readonly property bool dragging: mouse.pressed
    property real dragFraction: 0
    readonly property real fraction: length <= 0 ? 0
        : dragging ? dragFraction
        : Math.max(0, Math.min(1, position / length))
    readonly property bool hot: (mouse.containsMouse || dragging) && enabled

    signal seekRequested(real microseconds)

    implicitHeight: 16

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: seek.hot ? 6 : 4
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.18)
        Behavior on height { NumberAnimation { duration: 120 } }

        Rectangle {
            width: parent.width * seek.fraction
            height: parent.height
            radius: height / 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Qt.lighter(seek.accent, 1.35) }
                GradientStop { position: 1; color: seek.accent }
            }
        }
    }

    Rectangle {
        width: 12; height: 12; radius: 6
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        x: seek.fraction * seek.width - width / 2
        scale: seek.hot ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        hoverEnabled: true
        cursorShape: seek.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        function frac(x) { return Math.max(0, Math.min(1, x / width)) }
        onPressed: mouse => seek.dragFraction = frac(mouse.x)
        onPositionChanged: mouse => { if (pressed) seek.dragFraction = frac(mouse.x) }
        onReleased: seek.seekRequested(seek.dragFraction * seek.length)
    }
}
