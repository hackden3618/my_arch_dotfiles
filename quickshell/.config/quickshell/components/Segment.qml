import QtQuick
import "../services"

// One clickable section inside a PillGroup. Hover and active states draw an
// inset rounded plate so the outer pill outline stays unbroken.
Item {
    id: seg

    property bool active: false
    property bool divider: false          // thin line on the left edge
    readonly property bool hovered: area.containsMouse
    readonly property color ink: seg.active ? Theme.onAccent : Theme.fg

    default property alias contents: row.data

    signal clicked
    signal rightClicked
    signal scrolled(int dir)

    implicitWidth: row.implicitWidth + 28
    implicitHeight: 34

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: height / 2
        color: seg.active ? Theme.accent : (seg.hovered ? Qt.alpha(Theme.fg, 0.12) : "transparent")

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Rectangle {
        visible: seg.divider && !seg.active
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 16
        color: Qt.alpha(Theme.fg, 0.2)
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                seg.rightClicked();
            else
                seg.clicked();
        }
        onWheel: wheel => seg.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
    }
}
