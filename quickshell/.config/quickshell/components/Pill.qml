import QtQuick
import "../services"

// Compact status control used throughout the bar.
// default, hover (brighter outline), active (filled), urgent (red outline),
// and an optional tint (e.g. green while charging).
Rectangle {
    id: pill

    property bool active: false
    property bool urgent: false
    property color tint: "transparent"       // any non-transparent colour overrides the outline
    readonly property bool hovered: area.containsMouse
    // colour children should use for text and icons inside this pill
    readonly property color ink: pill.active ? Theme.onAccent : Theme.fg

    default property alias contents: row.data

    signal clicked
    signal rightClicked
    signal scrolled(int dir)

    implicitHeight: 24
    implicitWidth: row.implicitWidth + 28
    radius: Theme.radiusPill

    color: pill.active ? Theme.accent : (pill.hovered ? Theme.pillHover : Theme.pill)
    border.width: Theme.borderWidthStrong
    border.color: {
        if (pill.urgent)
            return Theme.danger;
        if (pill.active)
            return Theme.windowBorder;
        if (pill.tint.a > 0)
            return pill.tint;
        return pill.hovered ? Theme.edgeHi : Theme.edge;
    }

    Behavior on color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    // sits below the row so interactive children (tray icons) get clicks first
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                pill.rightClicked();
            else
                pill.clicked();
        }
        onWheel: wheel => pill.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
    }
}
