import QtQuick
import QtQuick.Layouts
import "../services"

// One app's notifications. A single item is just a card. Several collapse
// into a stack (newest on top, two "peeking" cards beneath) that expands in
// place, like Android and macOS.
ColumnLayout {
    id: group

    required property var modelData   // { app, items }

    readonly property var items: group.modelData.items
    readonly property bool multi: group.items.length > 1
    readonly property bool expanded: Notifs.expandedApps[group.modelData.app] === true

    spacing: 6

    // ---- single, or the newest card of a collapsed stack ----
    Item {
        Layout.fillWidth: true
        visible: !group.multi || !group.expanded
        implicitHeight: newest.implicitHeight + (group.multi ? 14 : 0)

        Rectangle {
            visible: group.multi
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            height: 28
            radius: Theme.radiusCard
            color: Qt.alpha(Theme.card, 0.7)
            border.width: 1
            border.color: Theme.cardEdge
        }
        Rectangle {
            visible: group.multi
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.bottom: parent.bottom
            height: 24
            radius: Theme.radiusCard
            color: Qt.alpha(Theme.card, 0.45)
            border.width: 1
            border.color: Theme.cardEdge
        }

        NotifCard {
            id: newest
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            notif: group.items[0]
        }
    }

    // ---- collapsed stack controls ----
    RowLayout {
        Layout.fillWidth: true
        visible: group.multi && !group.expanded
        spacing: 6

        Chip {
            text: "Show all " + group.items.length
            onClicked: Notifs.toggleExpand(group.modelData.app)
        }
        Chip {
            text: "Clear"
            onClicked: Notifs.dismissGroup(group.modelData)
        }
        Item {
            Layout.fillWidth: true
        }
    }

    // ---- expanded ----
    RowLayout {
        Layout.fillWidth: true
        visible: group.multi && group.expanded
        spacing: 8

        Txt {
            Layout.fillWidth: true
            text: group.modelData.app + " · " + group.items.length
            strong: true
        }
        Chip {
            text: "Show less"
            onClicked: Notifs.toggleExpand(group.modelData.app)
        }
        Chip {
            text: "Clear"
            onClicked: Notifs.dismissGroup(group.modelData)
        }
    }

    Repeater {
        model: group.multi && group.expanded ? group.items : []
        delegate: NotifCard {
            required property var modelData
            Layout.fillWidth: true
            notif: modelData
        }
    }
}
