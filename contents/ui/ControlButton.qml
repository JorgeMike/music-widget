import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

// Botón redondo con ícono. "primary" lo pinta como el botón grande de play.
Item {
    id: btn

    property string iconName
    property string tip
    property bool checked: false
    property bool primary: false
    property color accent: "white"
    property real size: Kirigami.Units.gridUnit * 2

    signal clicked()

    implicitWidth: size
    implicitHeight: size
    opacity: enabled ? 1 : 0.35
    activeFocusOnTab: true

    Keys.onSpacePressed: btn.clicked()
    Keys.onReturnPressed: btn.clicked()

    Kirigami.ShadowedRectangle {
        anchors.fill: parent
        radius: width / 2
        color: btn.primary ? "white"
             : mouse.containsMouse || btn.activeFocus ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
        shadow.size: btn.primary ? (mouse.containsMouse ? 22 : 14) : 0
        shadow.color: Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.55)
        scale: mouse.pressed ? 0.9 : (btn.primary && mouse.containsMouse ? 1.06 : 1)

        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on shadow.size { NumberAnimation { duration: 200 } }

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Math.round(btn.size * (btn.primary ? 0.48 : 0.55))
            height: width
            source: btn.iconName
            isMask: true
            color: btn.primary ? "#141414" : btn.checked ? btn.accent : "white"
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: -2
        width: 4; height: 4; radius: 2
        color: btn.accent
        visible: btn.checked
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: btn.clicked()
    }

    PlasmaComponents3.ToolTip {
        text: btn.tip
        visible: mouse.containsMouse && btn.tip !== ""
        delay: Kirigami.Units.toolTipDelay
    }
}
