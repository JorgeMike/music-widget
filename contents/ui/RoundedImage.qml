import QtQuick
import QtQuick.Effects
import org.kde.kirigami as Kirigami

// Imagen con esquinas redondeadas y un ícono de respaldo mientras carga.
Item {
    id: ri

    property alias source: img.source
    property real radius: Kirigami.Units.cornerRadius
    property string fallbackIcon: "audio-x-generic-symbolic"
    property color fallbackColor: Qt.rgba(1, 1, 1, 0.6)
    property int sourceResolution: 512
    readonly property bool ready: img.status === Image.Ready && img.source != ""

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
        sourceSize.width: ri.sourceResolution
        sourceSize.height: ri.sourceResolution
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        opacity: ri.ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    Item {
        id: mask
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        visible: false
        Rectangle { anchors.fill: parent; radius: ri.radius }
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.round(parent.width * 0.45)
        height: width
        source: ri.fallbackIcon
        isMask: true
        color: ri.fallbackColor
        visible: !ri.ready
    }
}
