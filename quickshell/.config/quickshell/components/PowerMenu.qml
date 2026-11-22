import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"

// Power menu (replaces wlogout). Keys: L E S R P, arrows + Enter, Esc.
// Restart and Shutdown count down 5 seconds so a stray click can be undone.
PanelWindow {
    id: win

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/hypr/scripts"

    readonly property var actions: [
        { key: "l", glyph: "", label: "Lock",     confirm: false, cmd: [win.scriptsDir + "/LockScreen.sh"] },
        { key: "e", glyph: "", label: "Logout",   confirm: false, cmd: ["hyprctl", "dispatch", "exit"] },
        { key: "s", glyph: "", label: "Sleep",    confirm: false, cmd: ["systemctl", "suspend"] },
        { key: "r", glyph: "", label: "Restart",  confirm: true,  cmd: ["systemctl", "reboot"] },
        { key: "p", glyph: "", label: "Shutdown", confirm: true,  cmd: ["systemctl", "poweroff"] }
    ]

    property int selected: 4
    property var pending: null
    property int countdown: 0

    function close() {
        countdownTimer.stop();
        win.pending = null;
        UiState.powerOpen = false;
    }
    function fire(a) {
        win.close();
        Quickshell.execDetached(a.cmd);
    }
    function choose(a) {
        if (!a.confirm) {
            win.fire(a);
            return;
        }
        win.pending = a;
        win.countdown = 5;
        countdownTimer.restart();
    }
    function cancel() {
        if (win.pending !== null) {
            countdownTimer.stop();
            win.pending = null;
        } else {
            win.close();
        }
    }

    screen: win.focusedScreen
    visible: UiState.powerOpen
    color: Theme.scrim
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "qs-power"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: UiState.powerOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (visible) {
            win.selected = 4;
            keys.forceActiveFocus();
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            win.countdown--;
            if (win.countdown <= 0 && win.pending !== null) {
                const a = win.pending;
                win.fire(a);
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: win.cancel()
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                win.cancel();
            } else if (event.key === Qt.Key_Left) {
                win.selected = (win.selected + win.actions.length - 1) % win.actions.length;
            } else if (event.key === Qt.Key_Right) {
                win.selected = (win.selected + 1) % win.actions.length;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                win.choose(win.actions[win.selected]);
            } else {
                const a = win.actions.find(x => x.key === event.text.toLowerCase());
                if (a)
                    win.choose(a);
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        implicitWidth: menu.implicitWidth + 44
        implicitHeight: menu.implicitHeight + 44
        radius: Theme.radiusPanel
        color: Theme.panel
        border.width: 1
        border.color: Theme.panelEdge

        ColumnLayout {
            id: menu
            anchors.centerIn: parent
            spacing: 16

            Txt {
                Layout.alignment: Qt.AlignHCenter
                text: win.pending !== null ? win.pending.label + " in " + win.countdown + "…" : "Power"
                size: 15
                strong: true
            }

            RowLayout {
                spacing: 12

                Repeater {
                    model: win.actions
                    delegate: Rectangle {
                        id: btn
                        required property var modelData
                        required property int index
                        readonly property bool sel: win.selected === btn.index

                        Layout.preferredWidth: 104
                        Layout.preferredHeight: 104
                        radius: 26
                        color: btn.sel ? Theme.accent : Theme.tileOff
                        border.width: btn.sel ? 2 : 1
                        border.color: btn.sel ? Theme.warm : Theme.cardEdge

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10

                            Glyph {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.modelData.glyph
                                size: 28
                                color: btn.sel ? Theme.onAccent : Theme.fg
                            }
                            Txt {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.modelData.label + " · " + btn.modelData.key.toUpperCase()
                                size: 12
                                strong: true
                                color: btn.sel ? Theme.onAccent : Theme.fg
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: win.selected = btn.index
                            onClicked: win.choose(btn.modelData)
                        }
                    }
                }
            }

            Txt {
                Layout.alignment: Qt.AlignHCenter
                text: win.pending !== null ? "Esc to cancel" : "Restart and Shutdown ask first. Arrow keys or the letter shown."
                size: 11
                color: Theme.muted
            }
        }
    }
}
