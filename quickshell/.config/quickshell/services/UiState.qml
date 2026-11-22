pragma Singleton

import Quickshell
import QtQuick

// Shared UI state: which panels are open, caffeine, and the OSD.
Singleton {
    id: root

    property bool ccOpen: false
    // which page of the Control Center is showing
    property string ccPage: "main"      // main | wifi | bluetooth | audio | theme
    property bool powerOpen: false
    property bool caffeine: false

    property bool osdVisible: false
    property string osdKind: "volume"   // volume | brightness | mute
    property real osdValue: 0

    function showOsd(kind, value) {
        root.osdKind = kind;
        root.osdValue = value;
        root.osdVisible = true;
        osdTimer.restart();
    }

    function toggleCc() {
        root.powerOpen = false;
        if (!root.ccOpen)
            root.ccPage = "main";
        root.ccOpen = !root.ccOpen;
    }

    // open the Control Center straight onto a page (right-click on a bar pill)
    function openPage(page) {
        root.powerOpen = false;
        root.ccPage = page;
        root.ccOpen = true;
    }

    // Escape / back arrow: leave a sub page first, then close the panel
    function back() {
        if (root.ccPage !== "main")
            root.ccPage = "main";
        else
            root.ccOpen = false;
    }

    function togglePower() {
        root.ccOpen = false;
        root.powerOpen = !root.powerOpen;
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.osdVisible = false
    }
}
