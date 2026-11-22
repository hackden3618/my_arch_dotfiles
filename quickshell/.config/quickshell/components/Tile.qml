import QtQuick
import QtQuick.Layouts
import "../services"

// Control Center toggle. On = filled with the wallust accent, with text that
// is picked for contrast against that accent.
Rectangle {
    id: tile

    property bool on: false
    property string glyph: ""
    property string title: ""
    property string sub: ""

    readonly property color ink: tile.on ? Theme.onAccent : Theme.fg
    readonly property color inkSub: tile.on ? Qt.alpha(Theme.onAccent, 0.85) : Theme.muted

    signal clicked

    implicitHeight: 64
    radius: Theme.radiusCard
    color: tile.on ? Theme.accent : (area.containsMouse ? Qt.alpha(Theme.fg, 0.11) : Theme.tileOff)
    border.width: 1
    border.color: tile.on ? Theme.accentEdge : Theme.cardEdge

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 18
            color: tile.on ? Qt.alpha(Theme.onAccent, 0.18) : Qt.alpha(Theme.fg, 0.1)

            Glyph {
                anchors.centerIn: parent
                text: tile.glyph
                color: tile.ink
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Txt {
                Layout.fillWidth: true
                text: tile.title
                strong: true
                color: tile.ink
            }
            Txt {
                Layout.fillWidth: true
                text: tile.sub
                size: 11
                color: tile.inkSub
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
}
