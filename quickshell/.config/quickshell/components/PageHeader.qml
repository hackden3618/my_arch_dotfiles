import QtQuick
import QtQuick.Layouts
import "../services"

// Back arrow + title + optional on/off switch, shared by every sub page.
RowLayout {
    id: head

    property string title: ""
    property bool switchable: false
    property bool checked: false

    signal toggled

    spacing: 10

    IconButton {
        glyph: ""
        onClicked: UiState.back()
    }

    Txt {
        Layout.fillWidth: true
        text: head.title
        size: 15
        strong: true
    }

    Rectangle {
        visible: head.switchable
        Layout.preferredWidth: 48
        Layout.preferredHeight: 28
        radius: 14
        color: head.checked ? Theme.accent : Qt.alpha(Theme.fg, 0.16)
        border.width: 1
        border.color: head.checked ? Theme.accentEdge : Theme.cardEdge

        Rectangle {
            width: 22
            height: 22
            radius: 11
            y: 3
            x: head.checked ? parent.width - width - 3 : 3
            color: head.checked ? Theme.onAccent : Theme.fg

            Behavior on x {
                NumberAnimation { duration: 120 }
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: head.toggled()
        }
    }
}
