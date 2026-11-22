import QtQuick
import QtQuick.Layouts
import "../services"

// Full-width pill slider (brightness, volume). The fill is a blend of the
// accent and the panel so the white label stays readable on both halves.
Rectangle {
    id: root

    property string glyph: ""
    property string label: ""
    property string detail: ""
    property real value: 0

    signal moved(real v)

    implicitHeight: 44
    radius: 22
    color: Theme.tileOff
    border.width: 1
    border.color: Theme.cardEdge
    clip: true

    Rectangle {
        width: Math.max(root.height, root.width * Math.max(0, Math.min(1, root.value)))
        height: parent.height
        radius: 22
        color: Theme.mix(Theme.bg, Theme.accent, 0.55)

        Behavior on width {
            enabled: !drag.pressed
            NumberAnimation { duration: 90 }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Glyph {
            text: root.glyph
            color: Theme.fg
        }
        Txt {
            Layout.fillWidth: true
            text: root.label
            strong: true
        }
        Txt {
            visible: root.detail.length > 0
            text: root.detail
            size: 11
            color: Theme.fg
            Layout.maximumWidth: 120
        }
        Txt {
            text: Math.round(root.value * 100) + "%"
            strong: true
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: mouse => root.moved(Math.max(0, Math.min(1, mouse.x / width)))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(Math.max(0, Math.min(1, mouse.x / width)));
        }
    }
}
