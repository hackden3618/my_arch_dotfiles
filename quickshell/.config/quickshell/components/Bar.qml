import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import "../services"

// The waybar layout, rebuilt: clock + media + tray + window on the left,
// workspaces + notifications in the centre, status pills on the right.
PanelWindow {
    id: bar

    required property var modelData

    readonly property bool wide: bar.width >= 1700
    readonly property var battery: UPower.displayDevice
    readonly property var player: {
        const list = Mpris.players.values;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }

    function volGlyph() {
        if (Audio.muted || Audio.volume <= 0) return "";
        return Audio.volume < 0.34 ? "" : "";
    }
    function fmtSecs(sec) {
        if (!(sec > 0))
            return "";
        const h = Math.floor(sec / 3600);
        const m = Math.floor((sec % 3600) / 60);
        return h > 0 ? h + "h " + String(m).padStart(2, "0") + "m" : m + "m";
    }
    function focusWorkspace(id) {
        // Hyprland's Lua mode evaluates dispatches as Lua, so use the native form
        Quickshell.execDetached(["hyprctl", "dispatch", 'hl.dsp.focus({ workspace = "' + id + '" })']);
    }
    function batGlyph(p) {
        if (p > 0.875) return "";
        if (p > 0.625) return "";
        if (p > 0.375) return "";
        if (p > 0.125) return "";
        return "";
    }

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 48
    color: "transparent"

    WlrLayershell.namespace: "qs-bar"

    IdleInhibitor {
        window: bar
        enabled: UiState.caffeine
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.topMargin: 5

        // ================= left =================
        Row {
            id: left
            anchors.left: parent.left
            spacing: 6

            Pill {
                onClicked: UiState.toggleCc()
                Txt {
                    text: Qt.formatDateTime(clock.date, "ddd dd")
                    strong: true
                }
                Txt {
                    text: "|"
                    color: Theme.muted
                }
                Txt {
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    strong: true
                }
            }

            Pill {
                visible: bar.player !== null
                onClicked: {
                    if (bar.player && bar.player.canTogglePlaying)
                        bar.player.togglePlaying();
                }
                Glyph {
                    text: ""
                    size: 14
                    color: bar.player && bar.player.isPlaying ? Theme.warm : Theme.fg
                }
                Txt {
                    width: Math.min(implicitWidth, 160)
                    text: bar.player ? (bar.player.trackTitle || bar.player.identity) : ""
                    strong: true
                }
            }

            Pill {
                visible: SystemTray.items.values.length > 0
                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        id: trayItem
                        required property var modelData
                        width: 20
                        height: 20

                        Image {
                            anchors.fill: parent
                            source: trayItem.modelData.icon
                            sourceSize: Qt.size(40, 40)
                            fillMode: Image.PreserveAspectFit
                        }
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) {
                                    trayItem.modelData.activate();
                                } else if (mouse.button === Qt.MiddleButton) {
                                    trayItem.modelData.secondaryActivate();
                                } else if (trayItem.modelData.hasMenu) {
                                    const p = trayItem.mapToItem(null, mouse.x, mouse.y);
                                    trayItem.modelData.display(bar, p.x, p.y);
                                }
                            }
                        }
                    }
                }
            }

            Pill {
                visible: bar.wide && title.text.length > 0
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.warm
                    anchors.verticalCenter: parent.verticalCenter
                }
                Txt {
                    id: title
                    width: Math.min(implicitWidth, 240)
                    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
                    strong: true
                }
            }
        }

        // ================= centre =================
        Row {
            id: centre
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Pill {
                // workspace strip: tighter padding, the buttons carry their own
                implicitWidth: ws.implicitWidth + 14
                Row {
                    id: ws
                    spacing: 2
                    Repeater {
                        model: 5
                        delegate: Rectangle {
                            id: wsBtn
                            required property int index
                            readonly property int wsId: wsBtn.index + 1
                            readonly property bool current: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsBtn.wsId
                            readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === wsBtn.wsId)

                            width: wsBtn.current ? 46 : 32
                            height: 26
                            radius: 9
                            color: wsBtn.current ? Theme.bg : (wsArea.containsMouse ? Qt.alpha(Theme.fg, 0.12) : "transparent")

                            Behavior on width {
                                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 5
                                Txt {
                                    text: wsBtn.wsId
                                    strong: true
                                    color: wsBtn.current ? Theme.warm : Theme.fg
                                }
                                Rectangle {
                                    visible: wsBtn.occupied
                                    width: 6
                                    height: 6
                                    radius: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: wsBtn.current ? Theme.warm : Theme.muted
                                }
                            }

                            MouseArea {
                                id: wsArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: bar.focusWorkspace(wsBtn.wsId)
                            }
                        }
                    }
                }
            }

            Pill {
                urgent: false
                onClicked: UiState.toggleCc()
                Glyph {
                    text: Notifs.dnd ? "" : ""
                    size: 15
                }
                Txt {
                    text: Notifs.count
                    strong: true
                }
                Rectangle {
                    visible: Notifs.count > 0 && !Notifs.dnd
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.danger
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ================= right =================
        Row {
            id: right
            anchors.right: parent.right
            spacing: 6

            Pill {
                onClicked: UiState.toggleCc()
                onScrolled: dir => (dir > 0 ? Audio.inc() : Audio.dec())
                Glyph {
                    text: bar.volGlyph()
                    size: 15
                }
                Txt {
                    text: Audio.muted ? "mute" : Math.round(Audio.volume * 100) + "%"
                    strong: true
                }
            }

            Pill {
                onClicked: UiState.toggleCc()
                onScrolled: dir => Sys.stepBrightness(dir)
                Glyph {
                    text: ""
                    size: 15
                }
                Txt {
                    text: Math.round(Sys.bright * 100) + "%"
                    strong: true
                }
            }

            // battery | network speed | bluetooth (only when connected) | control center
            PillGroup {
                urgent: batSeg.critical

                Segment {
                    id: batSeg

                    readonly property var dev: bar.battery
                    readonly property int st: dev ? dev.state : UPowerDeviceState.Unknown
                    readonly property bool charging: st === UPowerDeviceState.Charging
                    readonly property bool full: st === UPowerDeviceState.FullyCharged
                    readonly property bool plugged: st === UPowerDeviceState.PendingCharge
                    readonly property bool onAc: charging || full || plugged
                    readonly property real pct: dev ? dev.percentage : 1
                    readonly property bool critical: !onAc && pct < 0.15
                    readonly property bool low: !onAc && pct < 0.30
                    readonly property color tone: critical ? Theme.danger : (onAc ? Theme.ok : (low ? Theme.warm : Theme.fg))
                    // "1h 05m to full", "3h 20m left", "Full", "Plugged in"
                    readonly property string detail: {
                        if (!dev) return "";
                        if (charging) { const t = bar.fmtSecs(dev.timeToFull); return t ? t + " to full" : "Charging"; }
                        if (full) return "Full";
                        if (plugged) return "Plugged in";
                        const t = bar.fmtSecs(dev.timeToEmpty);
                        return t ? t + " left" : "";
                    }

                    visible: dev !== null && dev.isPresent
                    onClicked: UiState.toggleCc()

                    Glyph {
                        visible: batSeg.charging
                        text: "\uf0e7"
                        size: 13
                        color: Theme.ok
                    }
                    Glyph {
                        visible: batSeg.plugged
                        text: "\uf1e6"
                        size: 13
                        color: Theme.ok
                    }
                    Glyph {
                        text: bar.batGlyph(batSeg.full ? 1 : batSeg.pct)
                        size: 15
                        color: batSeg.tone
                    }
                    Txt {
                        text: Math.round(batSeg.pct * 100) + "%"
                        strong: true
                        color: batSeg.tone
                    }
                    Txt {
                        visible: bar.wide && batSeg.detail.length > 0
                        text: batSeg.detail
                        size: 11
                        color: batSeg.onAc ? Theme.ok : Theme.muted
                    }
                }

                // network throughput replaces the Wi-Fi icon; right-click for Wi-Fi settings
                Segment {
                    divider: batSeg.visible
                    onClicked: UiState.toggleCc()
                    onRightClicked: UiState.openPage("wifi")

                    Glyph {
                        text: "\uf062"
                        size: 11
                        color: Sys.wifiOn ? Theme.fg : Theme.muted
                    }
                    Txt {
                        width: Math.max(implicitWidth, 58)
                        horizontalAlignment: Text.AlignRight
                        text: Sys.fmtRate(Sys.txRate)
                        strong: true
                    }
                    Glyph {
                        text: "\uf063"
                        size: 11
                        color: Sys.wifiOn ? Theme.fg : Theme.muted
                    }
                    Txt {
                        width: Math.max(implicitWidth, 58)
                        horizontalAlignment: Text.AlignRight
                        text: Sys.fmtRate(Sys.rxRate)
                        strong: true
                    }
                }

                // only present while a Bluetooth device is connected
                Segment {
                    id: btSeg

                    readonly property var adapter: Bluetooth.defaultAdapter
                    readonly property int connected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

                    visible: connected > 0
                    divider: true
                    onClicked: UiState.toggleCc()
                    onRightClicked: UiState.openPage("bluetooth")

                    Glyph {
                        text: "\uf293"
                        size: 15
                    }
                    Txt {
                        visible: btSeg.connected > 1
                        text: btSeg.connected
                        strong: true
                    }
                }

                Segment {
                    id: ctlSeg
                    active: UiState.ccOpen
                    divider: true
                    onClicked: UiState.toggleCc()

                    Glyph {
                        text: "\uf1de"
                        size: 15
                        color: ctlSeg.ink
                    }
                }
            }
        }
    }
}
