import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../services"

// Now-playing card. Hidden when nothing is playing.
Rectangle {
    id: card

    readonly property var player: {
        const list = Mpris.players.values;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }

    visible: card.player !== null
    implicitHeight: card.visible ? 80 : 0
    radius: Theme.radiusCard
    color: Theme.tileOff
    border.width: Theme.borderWidth
    border.color: Theme.cardEdge

    Behavior on color {
        ColorAnimation { duration: Theme.motionLong; easing.type: Theme.easing }
    }

    // position is not pushed by most players, so nudge it once a second
    Timer {
        interval: 1000
        repeat: true
        running: card.visible && card.player !== null && card.player.isPlaying
        onTriggered: card.player.positionChanged()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            radius: 14
            clip: true
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.accent }
                GradientStop { position: 1; color: Theme.accentEdge }
            }

            Image {
                anchors.fill: parent
                source: card.player ? card.player.trackArtUrl : ""
                visible: source !== ""
                fillMode: Image.PreserveAspectCrop
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Txt {
                Layout.fillWidth: true
                text: card.player ? (card.player.trackTitle || "Unknown") : ""
                strong: true
            }
            Txt {
                Layout.fillWidth: true
                text: card.player ? (card.player.trackArtist || card.player.identity) : ""
                size: 11
                color: Theme.muted
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 6
                implicitHeight: 4
                radius: 2
                color: Qt.alpha(Theme.fg, 0.14)

                Rectangle {
                    height: 4
                    radius: 2
                    color: Theme.accent
                    width: card.player && card.player.length > 0 ? parent.width * Math.max(0, Math.min(1, card.player.position / card.player.length)) : 0

                    Behavior on width {
                        NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
                    }
                }
            }
        }

        RowLayout {
            spacing: 2

            IconButton {
                surfaceColor: Theme.tileOff
                glyph: ""
                color: "transparent"
                border.width: 0
                onClicked: card.player.previous()
            }
            IconButton {
                primary: true
                glyph: card.player && card.player.isPlaying ? "" : ""
                onClicked: card.player.togglePlaying()
            }
            IconButton {
                surfaceColor: Theme.tileOff
                glyph: ""
                color: "transparent"
                border.width: 0
                onClicked: card.player.next()
            }
        }
    }
}
