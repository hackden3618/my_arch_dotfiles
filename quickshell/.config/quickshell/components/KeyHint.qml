import QtQuick
import "../services"

// Small keyboard hint: a key cap followed by a description.
Row {
    id: hint

    property string keys: ""
    property string label: ""

    spacing: 6

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: key.implicitWidth + 12
        implicitHeight: 20
        radius: 6
        color: Theme.surfaceLow
        border.width: 1
        border.color: Theme.cardEdge

        Txt {
            id: key
            anchors.centerIn: parent
            text: hint.keys
            size: 9
            strong: true
            color: Theme.muted
        }
    }

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        text: hint.label
        size: 10
        color: Theme.muted
    }
}
