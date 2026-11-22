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

    signal clicked

    implicitHeight: 52
    radius: Theme.radiusCard
    color: row.active ? Qt.alpha(Theme.accent, 0.28) : (area.containsMouse ? Qt.alpha(Theme.fg, 0.1) : Theme.tileOff)
    border.width: 1
    border.color: row.active ? Theme.accentEdge : Theme.cardEdge

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
            color: row.active ? Theme.accent : Qt.alpha(Theme.fg, 0.1)

            Glyph {
                anchors.centerIn: parent
                text: row.glyph
                size: 14
                opacity: row.glyphOpacity
                color: row.active ? Theme.onAccent : Theme.fg
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Txt {
                Layout.fillWidth: true
                text: row.title
                strong: true
            }
            Txt {
                Layout.fillWidth: true
                visible: text.length > 0
                text: row.busy ? "Working…" : row.subtitle
                size: 11
                color: Theme.muted
            }
        }

        Row {
            id: actionRow
            spacing: 6
        }
    }
}
