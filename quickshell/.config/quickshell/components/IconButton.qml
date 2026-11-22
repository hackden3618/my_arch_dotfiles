import QtQuick
import "../services"

Rectangle {
    id: btn

    property string glyph: ""
    property bool primary: false
    property int size: 36

    signal clicked

    implicitWidth: btn.size
    implicitHeight: btn.size
    radius: btn.size / 2
    color: btn.primary ? Theme.warm : (area.containsMouse ? Qt.alpha(Theme.fg, 0.16) : Qt.alpha(Theme.fg, 0.08))
    border.width: btn.primary ? 0 : 1
    border.color: Qt.alpha(Theme.fg, 0.1)

    Glyph {
        anchors.centerIn: parent
        text: btn.glyph
        size: Math.round(btn.size * 0.44)
        color: btn.primary ? Theme.ink : Theme.fg
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
