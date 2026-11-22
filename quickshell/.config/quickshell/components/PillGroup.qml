import QtQuick
import "../services"

// One continuous pill made of several Segments (battery | speed | bluetooth |
// control center). Same outline and fill as a single Pill.
Rectangle {
    id: group

    property bool urgent: false

    default property alias segments: row.data

    implicitHeight: 38
    implicitWidth: row.implicitWidth + 4
    radius: Theme.radiusPill
    color: Theme.pill
    border.width: 2
    border.color: group.urgent ? Theme.danger : Theme.edge

    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0
    }
}
