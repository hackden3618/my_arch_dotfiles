import QtQuick
import "../services"

Rectangle {
    id: btn

    property string glyph: ""
    property bool primary: false
    property int size: 36
    property color surfaceColor: Theme.panel

    signal clicked

    implicitWidth: btn.size
    implicitHeight: btn.size
    radius: btn.size / 2
    color: btn.primary ? Theme.accent : (area.containsMouse ? Qt.alpha(Theme.fg, 0.14) : Qt.alpha(Theme.fg, 0.07))
    border.width: btn.primary ? 0 : Theme.borderWidth
    border.color: Qt.alpha(Theme.fg, 0.1)
    scale: area.pressed ? 0.94 : 1

    Behavior on color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    Glyph {
        anchors.fill: parent
        text: btn.glyph
        size: Math.round(btn.size * 0.44)
        color: btn.primary ? Theme.onAccent : Theme.textOn(btn.surfaceColor)
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
