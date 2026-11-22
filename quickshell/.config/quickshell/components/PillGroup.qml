import QtQuick
import "../services"

// One continuous pill made of several Segments (battery | speed | bluetooth |
// control center). Same outline and fill as a single Pill.
Rectangle {
    id: group

    property bool urgent: false

    default property alias segments: row.data

    implicitHeight: 24
    implicitWidth: row.implicitWidth + 4
    radius: Theme.radiusPill
    color: Theme.pill
    border.width: Theme.borderWidthStrong
    border.color: group.urgent ? Theme.danger : Theme.edge

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
    }

    Behavior on border.color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0
    }
}
