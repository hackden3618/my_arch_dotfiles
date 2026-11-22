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

    readonly property color surface: tile.on ? Theme.accentContainer : (area.containsMouse ? Theme.surfaceHigh : Theme.tileOff)
    readonly property color ink: Theme.textOn(tile.surface)
    readonly property color inkSub: Theme.mutedOn(tile.surface)

    signal clicked
    signal more

    implicitHeight: 68
    radius: Theme.radiusCard
    color: tile.on ? Theme.accentContainer : (area.containsMouse ? Theme.surfaceHigh : Theme.tileOff)
    border.width: Theme.borderWidth
    border.color: tile.on ? Theme.windowBorder : Theme.cardEdge
    scale: area.pressed ? 0.985 : 1

    Behavior on color {
        ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

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
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 14
            color: tile.on ? Theme.accent : Theme.mix(tile.surface, Theme.fg, 0.08)

            Behavior on color {
                ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
            }

            Glyph {
                anchors.fill: parent
                text: tile.glyph
                color: tile.on ? Theme.onAccent : Theme.textOn(parent.color)
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
                anchors.fill: parent
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
