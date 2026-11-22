import QtQuick
import QtQuick.Layouts
import "../services"

// Control Center toggle. Left click toggles. If `hasMore` is set there is a
// chevron (and right-click) that opens the detail page instead.
Rectangle {
    id: tile

    property bool on: false
    property bool hasMore: false
    property string glyph: ""
    property string title: ""
    property string sub: ""

    readonly property color ink: tile.on ? Theme.onAccent : Theme.fg
    readonly property color inkSub: tile.on ? Qt.alpha(Theme.onAccent, 0.85) : Theme.muted

    signal clicked
    signal more

    implicitHeight: 64
    radius: Theme.radiusCard
    color: tile.on ? Theme.accent : (area.containsMouse ? Qt.alpha(Theme.fg, 0.11) : Theme.tileOff)
    border.width: 1
    border.color: tile.on ? Theme.accentEdge : Theme.cardEdge

    // below the content so the chevron's own click area wins
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton && tile.hasMore)
                tile.more();
            else
                tile.clicked();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 8
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

        Rectangle {
            visible: tile.hasMore
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: chevron.containsMouse ? Qt.alpha(tile.ink, 0.18) : "transparent"

            Glyph {
                anchors.centerIn: parent
                text: ""
                size: 12
                color: tile.ink
            }
            MouseArea {
                id: chevron
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: tile.more()
            }
        }
    }
}
