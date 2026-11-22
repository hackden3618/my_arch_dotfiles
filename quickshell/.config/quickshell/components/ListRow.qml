import QtQuick
import QtQuick.Layouts
import "../services"

// One row in a device/network list. Click the row for the main action; chips
// declared inside it appear on the right for secondary actions.
Rectangle {
    id: row

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false          // connected / selected
    property bool busy: false
    property real glyphOpacity: 1

    default property alias actions: actionRow.data

    readonly property color surface: row.active ? Theme.accentContainer : (area.containsMouse ? Theme.surfaceHigh : Theme.tileOff)

    signal clicked

    implicitHeight: 52
    radius: Theme.radiusCard
    color: row.surface
    border.width: Theme.borderWidth
    border.color: row.active ? Theme.windowBorder : Theme.cardEdge
    scale: area.pressed ? 0.99 : 1

    Behavior on color {
        ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 10
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 16
            color: row.active ? Theme.accent : Theme.mix(row.color, Theme.fg, 0.08)

            Behavior on color {
                ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
            }

            Glyph {
                anchors.fill: parent
                text: row.glyph
                size: 14
                opacity: row.glyphOpacity
                color: row.active ? Theme.onAccent : Theme.textOn(parent.color)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Txt {
                Layout.fillWidth: true
                text: row.title
                strong: true
                color: Theme.textOn(row.surface)
            }
            Txt {
                Layout.fillWidth: true
                visible: text.length > 0
                text: row.busy ? "Working…" : row.subtitle
                size: 11
                color: Theme.mutedOn(row.surface)
            }
        }

        Row {
            id: actionRow
            spacing: 6
        }
    }
}
