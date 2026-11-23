import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../services"

// One notification. Used both as a toast and as a card in the Control Center.
Rectangle {
    id: card

    required property var notif
    property bool toast: false
    property bool revealed: false

    readonly property bool critical: card.notif.urgency === NotificationUrgency.Critical
    readonly property string app: card.notif.appName && card.notif.appName.length > 0 ? card.notif.appName : "System"
    readonly property bool hovered: hover.hovered || reply.activeFocus
    readonly property bool closing: card.toast && Notifs.closing[card.notif.id] === true

    // The SwayNC config animated toasts with
    //   slide-in-right 0.5s cubic-bezier(0.4, 0.0, 0.2, 1)
    // from translateX(100%) / opacity 0.9 to translateX(0) / opacity 1.
    // Leaving mirrors it with the config's 200 ms transition-time.
    readonly property real slide: card.toast
        ? (card.closing ? card.width : (card.revealed ? 0 : card.width))
        : 0

    function hue(s) {
        let h = 0;
        for (let i = 0; i < s.length; i++)
            h = (h * 31 + s.charCodeAt(i)) % 360;
        return h / 360;
    }

    implicitHeight: col.implicitHeight + 24
    radius: Theme.radiusCard
    color: card.toast ? Theme.panel : Theme.card
    border.width: Theme.borderWidth
    border.color: card.critical ? Theme.danger : (card.toast ? Theme.panelEdge : Theme.cardEdge)
    opacity: card.toast ? (card.closing ? 0.9 : (card.revealed ? 1 : 0.9)) : 1

    transform: Translate {
        x: card.slide

        Behavior on x {
            NumberAnimation {
                duration: card.closing ? 200 : 500
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
            }
        }
    }

    // Width is only known after the layout pass, so reveal when it arrives.
    onWidthChanged: if (card.toast && card.width > 0 && !card.revealed) card.revealed = true
    Component.onCompleted: if (card.width > 0) card.revealed = true

    Behavior on opacity {
        NumberAnimation {
            duration: card.closing ? 200 : 500
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
        }
    }
    Behavior on color {
        ColorAnimation { duration: Theme.motionLong; easing.type: Theme.easing }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
    }

    HoverHandler {
        id: hover
    }

    // Clicking the notification body invokes its default action, exactly like
    // SwayNC. Buttons, action chips and the reply field are declared above and
    // keep their own clicks.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifs.activate(card.notif, card.app)
    }

    // toasts leave on their own; critical ones stay until dismissed
    Timer {
        running: card.toast && !card.critical && !card.hovered && !card.closing
        interval: card.notif.expireTimeout > 0 ? card.notif.expireTimeout : 8000
        onTriggered: Notifs.dropPopup(card.notif)
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                Layout.alignment: Qt.AlignTop
                radius: 11
                clip: true
                color: card.critical ? Theme.danger : Qt.hsla(card.hue(card.app), 0.5, 0.36, 1)

                Image {
                    anchors.fill: parent
                    visible: card.notif.image !== ""
                    source: card.notif.image
                    fillMode: Image.PreserveAspectCrop
                }
                Txt {
                    anchors.centerIn: parent
                    visible: card.notif.image === ""
                    text: card.critical ? "!" : card.app.charAt(0).toUpperCase()
                    strong: true
                    color: card.critical ? Theme.ink : Theme.snow
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Txt {
                    Layout.fillWidth: true
                    text: (card.critical ? "CRITICAL · " : "") + card.app + (Notifs.ago(card.notif) ? " · " + Notifs.ago(card.notif) : "")
                    size: 11
                    color: card.critical ? Theme.danger : Theme.muted
                }
                Txt {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: card.notif.summary
                    strong: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                }
                Txt {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: card.notif.body
                    size: 12
                    color: Qt.alpha(Theme.fg, 0.88)
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: card.toast ? 3 : 4
                }
            }

            IconButton {
                Layout.alignment: Qt.AlignTop
                size: 28
                surfaceColor: card.toast ? Theme.panel : Theme.card
                glyph: ""
                onClicked: {
                    if (card.toast)
                        Notifs.dropPopup(card.notif);
                    else
                        card.notif.dismiss();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: card.notif.actions.length > 0
            spacing: 6

            Repeater {
                model: card.notif.actions
                delegate: Chip {
                    required property var modelData
                    visible: modelData.text !== "" && modelData.identifier !== "default"
                    text: modelData.text
                    onClicked: {
                        modelData.invoke();
                        if (card.toast)
                            Notifs.dropPopup(card.notif);
                    }
                }
            }
            Item {
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: card.notif.hasInlineReply
            spacing: 8

            TextField {
                id: reply
                Layout.fillWidth: true
                implicitHeight: 36
                placeholderText: card.notif.inlineReplyPlaceholder || "Reply"
                color: Theme.fg
                placeholderTextColor: Theme.muted
                font.family: Theme.font
                font.pixelSize: 12
                leftPadding: 14
                rightPadding: 14
                background: Rectangle {
                    radius: 18
                    color: Theme.surface
                    border.width: Theme.borderWidth
                    border.color: reply.activeFocus ? Theme.windowBorder : Theme.edge

                    Behavior on border.color {
                        ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                    }
                }
                onAccepted: {
                    if (text.length === 0)
                        return;
                    card.notif.sendInlineReply(text);
                    text = "";
                }
            }
            IconButton {
                size: 36
                primary: true
                glyph: ""
                onClicked: reply.accepted()
            }
        }
    }
}
