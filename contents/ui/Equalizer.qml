import QtQuick

// Barritas animadas que indican que algo está sonando.
Row {
    id: eq

    property bool running: true
    property color color: "white"
    property real barWidth: 3
    property real maxHeight: 12

    spacing: barWidth * 0.7
    height: maxHeight

    Repeater {
        model: [0.55, 1.0, 0.75, 0.9]
        Rectangle {
            required property real modelData
            required property int index
            anchors.bottom: parent.bottom
            width: eq.barWidth
            radius: width / 2
            color: eq.color
            // En reposo cada barra queda a una altura distinta: sigue pareciendo un ecualizador
            height: eq.maxHeight * modelData * 0.75

            SequentialAnimation on height {
                running: eq.running
                loops: Animation.Infinite
                NumberAnimation {
                    to: eq.maxHeight * modelData
                    duration: 300 + index * 70
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: eq.maxHeight * 0.25
                    duration: 260 + index * 90
                    easing.type: Easing.InOutSine
                }
                onStopped: parent.height = eq.maxHeight * modelData * 0.75
            }
        }
    }
}
