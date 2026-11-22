pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Quickshell is the notification daemon (replaces swaync). One tracked list
// feeds the bar badge, the toasts and the Control Center shade.
Singleton {
    id: root

    property bool dnd: false

    // notifications currently shown as toasts (newest first)
    property var popups: []

    // when each notification arrived (the protocol carries no timestamp)
    property var arrived: ({})
    property int tick: 0

    readonly property var all: server.trackedNotifications.values
    readonly property int count: root.all.length

    // grouped by app, newest group first; items newest first
    readonly property var groups: {
        const order = [];
        const map = {};
        const items = root.all.slice().reverse();
        for (const n of items) {
            const key = n.appName && n.appName.length > 0 ? n.appName : "System";
            if (!map[key]) {
                map[key] = { app: key, items: [] };
                order.push(map[key]);
            }
            map[key].items.push(n);
        }
        return order;
    }

    // which app groups are expanded in the shade; kept here so a new
    // notification does not collapse a group you are reading
    property var expandedApps: ({})

    function toggleExpand(app) {
        const next = Object.assign({}, root.expandedApps);
        next[app] = !next[app];
        root.expandedApps = next;
    }

    function dismissGroup(group) {
        for (const n of group.items.slice())
            n.dismiss();
    }

    function dropPopup(n) {
        root.popups = root.popups.filter(p => p !== n);
    }

    function clearAll() {
        for (const n of root.all.slice())
            n.dismiss();
        root.popups = [];
    }

    function ago(n) {
        root.tick; // re-evaluate every 30s
        const t = root.arrived[n.id];
        if (!t)
            return "";
        const s = Math.floor((Date.now() - t) / 1000);
        if (s < 45) return "now";
        if (s < 3600) return Math.max(1, Math.round(s / 60)) + "m";
        if (s < 86400) return Math.round(s / 3600) + "h";
        return Math.round(s / 86400) + "d";
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: false
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true
        inlineReplySupported: true

        onNotification: n => {
            n.tracked = true;

            const stamped = Object.assign({}, root.arrived);
            stamped[n.id] = Date.now();
            root.arrived = stamped;

            const critical = n.urgency === NotificationUrgency.Critical;
            if (n.urgency === NotificationUrgency.Low)
                return;                       // low priority goes straight to the shade
            if (root.dnd && !critical)
                return;                       // DND keeps toasts quiet, shade still fills
            root.popups = [n].concat(root.popups).slice(0, 4);
        }
    }

    Connections {
        target: server.trackedNotifications
        function onObjectRemoved(n) {
            root.dropPopup(n);
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.tick++
    }
}
