import QtQuick
import "../services"

Rectangle {
    id: chip

    property string text: ""
    property bool primary: false

    signal clicked

    implicitHeight: 28
    implicitWidth: label.implicitWidth + 24
    radius: Theme.radiusChip
    color: chip.primary ? Theme.accent : (area.containsMouse ? Qt.alpha(Theme.fg, 0.16) : Qt.alpha(Theme.fg, 0.08))
    border.width: Theme.borderWidth
    border.color: chip.primary ? Theme.windowBorder : Theme.edge
    scale: area.pressed ? 0.96 : 1

    Behavior on color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    Txt {
        id: label
        anchors.centerIn: parent
        text: chip.text
        size: 11
        strong: true
        color: chip.primary ? Theme.onAccent : Theme.fg
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.clicked()
    }
}
