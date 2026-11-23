pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick

// Quickshell is the notification daemon (replaces swaync). One tracked list
// feeds the bar badge, the toasts and the Control Center shade.
Singleton {
    id: root

    property bool dnd: false

    // notifications currently shown as toasts (newest first)
    property var popups: []

    // toasts that are sliding out; they stay in the list until the animation
    // finishes, then dropPopup's timer removes them for real
    property var closing: ({})

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

    // Ask a toast to leave. The card plays the SwayNC slide-out and the timer
    // below removes it once the motion is over.
    function dropPopup(n) {
        if (!n || root.popups.indexOf(n) === -1)
            return;
        if (root.closing[n.id])
            return;
        const next = Object.assign({}, root.closing);
        next[n.id] = true;
        root.closing = next;
        closingTimer.restart();
    }

    function flushClosing() {
        if (root.popups.some(p => root.closing[p.id]))
            root.popups = root.popups.filter(p => !root.closing[p.id]);
        if (Object.keys(root.closing).length > 0)
            root.closing = {};
    }

    // Clicking a notification invokes its default action (what SwayNC does).
    // When an app sends no action, focus its window instead so the click still
    // takes you to the thing that notified you.
    function focusApp(appName) {
        if (!appName)
            return false;
        const needle = appName.toLowerCase().replace(/\s+/g, "");
        const wins = Hyprland.toplevels.values.filter(w => w.address && w.address.length > 0);
        const match = wins.find(w => {
            const cls = (((w.wayland && w.wayland.appId) || (w.lastIpcObject && w.lastIpcObject.class) || "") + "")
                .toLowerCase().replace(/\s+/g, "");
            return cls.length > 0 && (cls === needle || cls.includes(needle) || needle.includes(cls));
        });
        if (!match)
            return false;
        Quickshell.execDetached(["hyprctl", "eval",
            'local w = hl.get_window("address:' + match.address + '"); if w then hl.dispatch(hl.dsp.focus({ window = w })) end']);
        return true;
    }

    function defaultAction(n) {
        if (!n || !n.actions)
            return null;
        for (const action of n.actions) {
            if (action.identifier === "default")
                return action;
        }
        return null;
    }

    function activate(n, appName) {
        const action = root.defaultAction(n);
        if (action) {
            action.invoke();
            root.dropPopup(n);
            return true;
        }
        const focused = root.focusApp(appName);
        root.dropPopup(n);
        return focused;
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

    // Long enough for the card's 200 ms slide-out to finish.
    Timer {
        id: closingTimer
        interval: 260
        repeat: false
        onTriggered: root.flushClosing()
    }
}
