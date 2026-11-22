import QtQuick
import "../services"

// The waybar pill: 38px, fully rounded, 2px outline. States match the design:
// default, hover (brighter outline), active (filled), urgent (red outline).
Rectangle {
    id: pill

    property bool active: false
    property bool urgent: false
    readonly property bool hovered: area.containsMouse
    // colour children should use for text and icons inside this pill
    readonly property color ink: pill.active ? Theme.onAccent : Theme.fg

    default property alias contents: row.data

    signal clicked
    signal scrolled(int dir)

    implicitHeight: 38
    implicitWidth: row.implicitWidth + 28
    radius: Theme.radiusPill

    color: pill.active ? Theme.accent : (pill.hovered ? Theme.pillHover : Theme.pill)
    border.width: 2
    border.color: pill.urgent ? Theme.danger : pill.active ? Theme.accentEdge : (pill.hovered ? Theme.edgeHi : Theme.edge)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

    // sits below the row so interactive children (tray icons) get clicks first
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pill.clicked()
        onWheel: wheel => pill.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
    }
}
