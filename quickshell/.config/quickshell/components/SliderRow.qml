import QtQuick
import QtQuick.Layouts
import "../services"

// Full-width tonal slider for brightness and volume.
Rectangle {
    id: root

    property string glyph: ""
    property string label: ""
    property string detail: ""
    property real value: 0
    property bool hasMore: false

    signal moved(real v)
    signal more

    implicitHeight: 44
    radius: 22
    color: Theme.surface
    border.width: Theme.borderWidth
    border.color: Theme.cardEdge
    clip: true

    Rectangle {
        width: Math.max(root.height, root.width * Math.max(0, Math.min(1, root.value)))
        height: parent.height
        radius: 22
        color: Theme.accentContainer

        Behavior on width {
            enabled: !drag.pressed
            NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
        }
    }

    Behavior on color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Glyph {
            text: root.glyph
            color: Theme.fg
        }
        Txt {
            Layout.fillWidth: true
            text: root.label
            strong: true
        }
        Txt {
            visible: root.detail.length > 0
            text: root.detail
            size: 11
            color: Theme.fg
            Layout.maximumWidth: 120
        }
        Txt {
            text: Math.round(root.value * 100) + "%"
            strong: true
        }
        Item {
            visible: root.hasMore
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: mouse => root.moved(Math.max(0, Math.min(1, mouse.x / width)))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(Math.max(0, Math.min(1, mouse.x / width)));
        }
    }

    // chevron sits above the drag area so it can open the detail page
    Rectangle {
        visible: root.hasMore
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        radius: 15
        color: chevron.containsMouse ? Qt.alpha(Theme.fg, 0.18) : "transparent"

        Glyph {
            anchors.centerIn: parent
            text: "\uf054"
            size: 12
        }
        MouseArea {
            id: chevron
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.more()
        }
    }
}
