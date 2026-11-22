import QtQuick
import "../services"

Rectangle {
    id: chip

    property string text: ""
    property bool primary: false

    signal clicked

    implicitHeight: 28
    implicitWidth: label.implicitWidth + 24
    radius: 14
    color: chip.primary ? Theme.accent : (area.containsMouse ? Qt.alpha(Theme.fg, 0.16) : Qt.alpha(Theme.fg, 0.08))
    border.width: 1
    border.color: chip.primary ? Theme.accentEdge : Qt.alpha(Theme.fg, 0.16)

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
