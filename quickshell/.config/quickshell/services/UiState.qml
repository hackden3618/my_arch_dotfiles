pragma Singleton

import Quickshell
import QtQuick

// Shared UI state: which panels are open, caffeine, and the OSD.
Singleton {
    id: root

    property bool ccOpen: false
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
        root.ccOpen = !root.ccOpen;
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
