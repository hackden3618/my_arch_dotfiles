import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import "../services"

// Control Center: quick toggles, sliders, now playing and the notification
// shade on the main page, plus detail pages for Wi-Fi, Bluetooth, Sound and
// Theme. Replaces swaync's control center.
PanelWindow {
    id: win

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    readonly property var bt: Bluetooth.defaultAdapter
    readonly property int btConnected: win.bt ? win.bt.devices.values.filter(d => d.connected).length : 0

    function profileLabel(p) {
        if (p === PowerProfile.PowerSaver) return "Saver";
        if (p === PowerProfile.Performance) return "Performance";
        return "Balanced";
    }
    function cycleProfile() {
        const order = [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance];
        let next = order[(order.indexOf(PowerProfiles.profile) + 1) % order.length];
        if (next === PowerProfile.Performance && !PowerProfiles.hasPerformanceProfile)
            next = PowerProfile.PowerSaver;
        PowerProfiles.profile = next;
    }
    function run(cmd) {
        UiState.ccOpen = false;
        Quickshell.execDetached(cmd);
    }

    screen: win.focusedScreen
    visible: UiState.ccOpen
    color: "transparent"
    anchors {
        top: true
        right: true
    }
    margins {
        top: 56
        right: 12
    }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 420
    implicitHeight: panel.implicitHeight

    WlrLayershell.namespace: "qs-controlcenter"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: UiState.ccOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // click anywhere else to close
    HyprlandFocusGrab {
        windows: [win]
        active: UiState.ccOpen
        onCleared: UiState.ccOpen = false
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        id: panel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        implicitHeight: col.implicitHeight + 32
        radius: Theme.radiusPanel
        color: Theme.panel
        border.width: 1
        border.color: Theme.panelEdge

        focus: true
        Keys.onEscapePressed: UiState.back()

        ColumnLayout {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 12

            // ================= sub pages =================
            WifiPage {
                Layout.fillWidth: true
                visible: UiState.ccPage === "wifi"
            }
            BluetoothPage {
                Layout.fillWidth: true
                visible: UiState.ccPage === "bluetooth"
            }
            AudioPage {
                Layout.fillWidth: true
                visible: UiState.ccPage === "audio"
            }
            // built only while open: the wallpaper grid decodes images
            Loader {
                Layout.fillWidth: true
                active: UiState.ccOpen && UiState.ccPage === "theme"
                visible: active
                sourceComponent: ThemePage {
                    width: parent ? parent.width : 0
                }
            }

            // ================= main page =================
            ColumnLayout {
                id: mainPage
                Layout.fillWidth: true
                visible: UiState.ccPage === "main"
                spacing: 12

                // ---- header ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Txt {
                            text: Qt.formatDateTime(clock.date, "dddd, d MMM")
                            size: 15
                            strong: true
                        }
                        Txt {
                            text: "up " + Sys.fmtUptime(Sys.uptimeSec)
                            size: 11
                            color: Theme.muted
                        }
                    }
                    IconButton {
                        glyph: ""
                        onClicked: UiState.ccPage = "theme"
                    }
                    IconButton {
                        glyph: ""
                        onClicked: win.run([Sys.scriptsDir + "/Kool_Quick_Settings.sh"])
                    }
                    IconButton {
                        glyph: ""
                        onClicked: win.run([Sys.scriptsDir + "/LockScreen.sh"])
                    }
                    IconButton {
                        glyph: ""
                        onClicked: UiState.togglePower()
                    }
                }

                // ---- toggles ----
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 8

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        glyph: ""
                        title: "Wi-Fi"
                        sub: Sys.wifiOn ? (Sys.ssid || "On") : "Off"
                        on: Sys.wifiOn
                        hasMore: true
                        onClicked: Sys.toggleWifi()
                        onMore: UiState.ccPage = "wifi"
                    }
                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        glyph: ""
                        title: "Bluetooth"
                        sub: !win.bt || !win.bt.enabled ? "Off" : (win.btConnected > 0 ? win.btConnected + " connected" : "On")
                        on: win.bt ? win.bt.enabled : false
                        hasMore: true
                        onClicked: {
                            if (win.bt)
                                win.bt.enabled = !win.bt.enabled;
                        }
                        onMore: UiState.ccPage = "bluetooth"
                    }
                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        glyph: ""
                        title: "Do Not Disturb"
                        sub: Notifs.dnd ? "On" : "Off"
                        on: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        glyph: ""
                        title: "Night Light"
                        sub: Sys.nightOn ? "On" : "Off"
                        on: Sys.nightOn
                        onClicked: Sys.toggleNight()
                    }
                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        glyph: ""
                        title: "Power Mode"
                        sub: win.profileLabel(PowerProfiles.profile)
                        on: PowerProfiles.profile !== PowerProfile.Balanced
                        onClicked: win.cycleProfile()
                    }
                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        glyph: ""
                        title: "Caffeine"
                        sub: UiState.caffeine ? "Screen stays on" : "Idle allowed"
                        on: UiState.caffeine
                        onClicked: UiState.caffeine = !UiState.caffeine
                    }
                }

                // ---- sliders ----
                SliderRow {
                    Layout.fillWidth: true
                    glyph: ""
                    label: "Display"
                    value: Sys.bright
                    onMoved: v => Sys.setBrightness(v)
                }
                SliderRow {
                    Layout.fillWidth: true
                    glyph: Audio.muted ? "" : ""
                    label: "Sound"
                    detail: Audio.sinkName
                    value: Audio.muted ? 0 : Audio.volume
                    hasMore: true
                    onMoved: v => Audio.setVolume(v)
                    onMore: UiState.ccPage = "audio"
                }

                MediaCard {
                    Layout.fillWidth: true
                }

                // ---- notifications ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Txt {
                        text: "Notifications"
                        size: 14
                        strong: true
                    }
                    Rectangle {
                        visible: Notifs.count > 0
                        implicitWidth: Math.max(20, badge.implicitWidth + 12)
                        implicitHeight: 20
                        radius: 10
                        color: Theme.danger
                        Txt {
                            id: badge
                            anchors.centerIn: parent
                            text: Notifs.count
                            size: 11
                            strong: true
                            color: Theme.ink
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Chip {
                        visible: Notifs.count > 0
                        text: "Clear all"
                        onClicked: Notifs.clearAll()
                    }
                }

                // empty state
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    visible: Notifs.count === 0
                    spacing: 6

                    Glyph {
                        Layout.alignment: Qt.AlignHCenter
                        text: Notifs.dnd ? "" : ""
                        size: 26
                        color: Theme.muted
                    }
                    Txt {
                        Layout.alignment: Qt.AlignHCenter
                        text: "All caught up"
                        strong: true
                    }
                    Txt {
                        Layout.alignment: Qt.AlignHCenter
                        text: Notifs.dnd ? "Do Not Disturb is on" : "Nothing new"
                        size: 11
                        color: Theme.muted
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    visible: Notifs.count > 0
                    implicitHeight: Math.min(list.implicitHeight, Math.max(160, (win.screen ? win.screen.height : 900) - 760))
                    contentHeight: list.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: list
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: Notifs.groups
                            delegate: NotifGroup {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
