import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
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
                                onClicked: Hyprland.dispatch("workspace " + wsBtn.wsId)
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

            Pill {
                id: batPill
                visible: bar.battery !== null && bar.battery.isPresent
                urgent: bar.battery !== null && bar.battery.state !== UPowerDeviceState.Charging && bar.battery.percentage < 0.15
                onClicked: UiState.toggleCc()
                Glyph {
                    text: bar.battery && bar.battery.state === UPowerDeviceState.Charging ? "" : bar.batGlyph(bar.battery ? bar.battery.percentage : 1)
                    size: 15
                    color: batPill.urgent ? Theme.danger : Theme.fg
                }
                Txt {
                    text: bar.battery ? Math.round(bar.battery.percentage * 100) + "%" : ""
                    strong: true
                    color: batPill.urgent ? Theme.danger : Theme.fg
                }
            }

            Pill {
                onClicked: UiState.toggleCc()
                Glyph {
                    text: ""
                    size: 15
                    color: Sys.wifiOn ? Theme.fg : Theme.muted
                }
                Glyph {
                    visible: bar.wide
                    text: ""
                    size: 11
                }
                Txt {
                    visible: bar.wide
                    text: Sys.fmtRate(Sys.txRate)
                    strong: true
                }
                Glyph {
                    visible: bar.wide
                    text: ""
                    size: 11
                }
                Txt {
                    visible: bar.wide
                    text: Sys.fmtRate(Sys.rxRate)
                    strong: true
                }
            }

            Pill {
                id: ctlPill
                active: UiState.ccOpen
                onClicked: UiState.toggleCc()
                Glyph {
                    text: ""
                    size: 15
                    color: ctlPill.ink
                }
            }
        }
    }
}
