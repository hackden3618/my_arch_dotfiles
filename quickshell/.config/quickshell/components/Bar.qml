import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        // Clicking the selected pill returns to the last workspace explicitly.
        const current = Hyprland.focusedWorkspace;
        const destination = current && current.id === id ? "previous" : id;
        Quickshell.execDetached(["hyprctl", "dispatch", 'hl.dsp.focus({ workspace = "' + destination + '" })']);
    }
    function fallbackWorkspaceIcon(appId, title) {
        const key = (appId + " " + title).toLowerCase();
        if (/brave-browser|brave/.test(key)) return "brave-browser";
        if (/firefox|chrom|browser|webkit/.test(key)) return "web-browser";
        if (/kitty|foot|terminal|alacritty|wezterm/.test(key)) return "utilities-terminal";
        if (/code|codium|zed|sublime|jetbrains|editor/.test(key)) return "accessories-text-editor";
        if (/thunar|nautilus|dolphin|file.?manager/.test(key)) return "system-file-manager";
        if (/discord|whatsapp|telegram|signal|slack|element/.test(key)) return "internet-chat";
        if (/spotify|mpv|music|video/.test(key)) return "multimedia-player";
        return "application-x-executable";
    }
    function workspaceGlyph(appId, title) {
        const app = (appId || "").toLowerCase();
        const page = (title || "").toLowerCase();
        // Prefer the app identity: window titles can mention unrelated apps
        // (for example, a VS Code terminal title containing "terminal").
        if (/^brave-browser(?:-(?:beta|dev|unstable))?$/.test(app) || /brave/.test(app)) return "🦁";
        if (/^(vscode|visual.?studio.?code|code|code-oss|code-url-handler|codium|codium-url-handler|vscodium)$/.test(app)) return "";
        if (/kitty|konsole|alacritty|wezterm|ghostty|foot|terminal/.test(app)) return "";
        if (/firefox|librewolf|floorp|waterfox|mercury/.test(app)) return "";
        if (/chrom|thorium/.test(app)) return "";
        if (/microsoft-edge/.test(app)) return "";
        const appMappings = [
            [/thunderbird|betterbird/, ""], [/telegram/, ""], [/discord|webcord|vesktop/, ""], [/signal/, "󰍩"], [/whatsapp|zapzap/, ""], [/slack/, ""],
            [/spotify/, ""], [/mpv|celluloid/, ""], [/vlc/, "󰕼"], [/youtube/, ""], [/obs/, ""],
            [/zed/, "󰵁"], [/neovim|nvim/, ""], [/sublime/, "󰅳"], [/jetbrains|idea/, ""], [/figma/, ""],
            [/thunar|nautilus|dolphin|nemo/, "󰝰"], [/steam/, ""], [/gimp/, ""], [/libreoffice.*calc/, ""], [/libreoffice/, "󰏆"],
            [/virtualbox|virt-manager|remote-viewer|remmina/, ""], [/android-studio|emulator/, ""], [/gparted/, ""], [/satty|screenshot/, ""],
            [/pavucontrol/, "󱡫"], [/settings|nwg-look/, ""], [/zoom/, ""], [/chatgpt|deepseek|qwen/, "󰚩"]
        ];
        const appMatch = appMappings.find(([pattern]) => pattern.test(app));
        if (appMatch) return appMatch[1];
        if (/brave/.test(page)) return "🦁";
        if (/visual studio code|vscode/.test(page)) return "";
        if (/firefox/.test(page)) return "";
        if (/youtube/.test(page)) return "";
        if (/gmail/.test(page)) return "󰊫";
        if (/reddit/.test(page)) return "";
        if (/amazon/.test(page)) return "";
        if (/facebook/.test(page)) return "";
        return "";
    }
    function appsForWorkspace(id) {
        const workspace = Hyprland.workspaces.values.find(w => w.id === id);
        if (!workspace || !workspace.toplevels)
            return [];

        const apps = [];
        const seen = new Set();
        for (const window of workspace.toplevels.values) {
            const ipc = window.lastIpcObject || {};
            const appId = (window.wayland && window.wayland.appId) || ipc.class || ipc.initialClass || "";
            const title = window.title || ipc.title || "";
            const entry = appId ? DesktopEntries.heuristicLookup(appId) : null;
            const icon = entry && entry.icon ? entry.icon : fallbackWorkspaceIcon(appId, title);
            const glyph = workspaceGlyph(appId, title);
            const identity = (entry && entry.id) || appId.toLowerCase() || title;
            if (!identity || seen.has(identity))
                continue;
            seen.add(identity);
            apps.push({
                icon: icon,
                glyph: glyph,
                name: entry && entry.name ? entry.name : (appId || title || "Application"),
            });
        }
        return apps;
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
    implicitHeight: 32
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
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        // ================= left =================
        Row {
            id: left
            anchors.left: parent.left
            spacing: 6

            Pill {
                onClicked: UiState.toggleCc()
                Txt {
                    size: 12
                    text: Qt.formatDateTime(clock.date, "ddd dd")
                    strong: true
                }
                Txt {
                    size: 12
                    text: "|"
                    color: Theme.muted
                }
                Txt {
                    size: 12
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
                    size: 13
                    color: bar.player && bar.player.isPlaying ? Theme.accent : Theme.fg
                }
                Txt {
                    size: 12
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
                    color: Theme.accent
                    anchors.verticalCenter: parent.verticalCenter
                }
                Txt {
                    id: title
                    size: 12
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
                            readonly property var applications: bar.appsForWorkspace(wsBtn.wsId)
                            readonly property int shownAppCount: Math.min(applications.length, 2)

                            width: 30 + shownAppCount * 17 + (applications.length > 2 ? 13 : 0)
                            height: 22
                            radius: 11
                            color: wsBtn.current ? Theme.workspaceAccent : (wsArea.containsMouse ? Theme.surfaceHigh : "transparent")
                            border.width: wsBtn.current ? 1.5 : 0
                            border.color: Theme.accentEdge

                            Behavior on width {
                                NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
                            }
                            Behavior on color {
                                ColorAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Txt {
                                    size: 11
                                    text: wsBtn.wsId
                                    strong: true
                                    color: wsBtn.current ? Theme.onWorkspaceAccent : Theme.fg
                                }
                                Repeater {
                                    model: wsBtn.applications.slice(0, wsBtn.shownAppCount)
                                    delegate: Item {
                                        required property var modelData
                                        width: 15
                                        height: 15
                                        anchors.verticalCenter: parent.verticalCenter

                                        Image {
                                            visible: !modelData.glyph
                                            anchors.centerIn: parent
                                            width: 15
                                            height: 15
                                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                            sourceSize: Qt.size(30, 30)
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                        }
                                        Txt {
                                            visible: !!modelData.glyph
                                            anchors.centerIn: parent
                                            width: parent.width
                                            height: parent.height
                                            size: 14
                                            text: modelData.glyph
                                            color: wsBtn.current ? Theme.onWorkspaceAccent : Theme.fg
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                                Txt {
                                    visible: wsBtn.applications.length > 2
                                    size: 9
                                    text: "+" + (wsBtn.applications.length - 2)
                                    strong: true
                                    color: wsBtn.current ? Theme.onAccent : Theme.muted
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
                    size: 14
                }
                Txt {
                    size: 12
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
                    size: 14
                }
                Txt {
                    size: 12
                    text: Audio.muted ? "mute" : Math.round(Audio.volume * 100) + "%"
                    strong: true
                }
            }

            Pill {
                onClicked: UiState.toggleCc()
                onScrolled: dir => Sys.stepBrightness(dir)
                Glyph {
                    text: ""
                    size: 14
                }
                Txt {
                    size: 12
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
                        size: 12
                        color: Theme.ok
                    }
                    Glyph {
                        visible: batSeg.plugged
                        text: "\uf1e6"
                        size: 12
                        color: Theme.ok
                    }
                    Glyph {
                        text: bar.batGlyph(batSeg.full ? 1 : batSeg.pct)
                        size: 14
                        color: batSeg.tone
                    }
                    Txt {
                        size: 12
                        text: Math.round(batSeg.pct * 100) + "%"
                        strong: true
                        color: batSeg.tone
                    }
                    Txt {
                        visible: bar.wide && batSeg.detail.length > 0
                        text: batSeg.detail
                        size: 10
                        color: batSeg.onAc ? Theme.ok : Theme.muted
                    }
                }

                // network throughput replaces the Wi-Fi icon; right-click for Wi-Fi settings
                Segment {
                    id: netSeg
                    property bool detailsExpanded: false
                    property bool monitorExpanded: false
                    divider: batSeg.visible
                    onClicked: netSeg.detailsExpanded = !netSeg.detailsExpanded
                    onRightClicked: UiState.openPage("wifi")

                    Glyph {
                        text: "\uf062"
                        size: 11
                        color: Sys.wifiOn ? Theme.fg : Theme.muted
                    }
                    Txt {
                        size: 12
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
                        size: 12
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
                        size: 14
                    }
                    Txt {
                        size: 12
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
                        size: 14
                        color: ctlSeg.ink
                    }
                }
            }
        }
    }

    PopupWindow {
        id: monitorPopup
        anchor.item: netSeg
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        anchor.margins.bottom: 8
        visible: netSeg.detailsExpanded || monitorCard.opacity > 0.01
        width: 312
        height: netSeg.monitorExpanded ? 276 : 176
        color: "transparent"

        Rectangle {
            id: monitorCard
            anchors.fill: parent
            radius: Theme.radiusPanel
            color: Theme.panel
            border.width: Theme.borderWidth
            border.color: Theme.panelEdge
            clip: true
            opacity: netSeg.detailsExpanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
            }
            Behavior on color {
                ColorAnimation { duration: Theme.motionLong; easing.type: Theme.easing }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                anchors.bottomMargin: 48
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    Txt {
                        Layout.fillWidth: true
                        text: "System"
                        size: 15
                        strong: true
                    }
                    Txt {
                        text: "Updated every 2s"
                        size: 10
                        color: Theme.muted
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: "CPU"; color: Theme.muted }
                    Txt { text: Math.round(Sys.cpu * 100) + "%"; strong: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: "Memory"; color: Theme.muted }
                    Txt { text: Sys.memUsedGb.toFixed(1) + " / " + Sys.memTotalGb.toFixed(1) + " GB"; strong: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: "Disk /"; color: Theme.muted }
                    Txt { text: Sys.diskUsedGb.toFixed(0) + " / " + Sys.diskTotalGb.toFixed(0) + " GB"; strong: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: "Temperature"; color: Theme.muted }
                    Txt { text: Sys.temp + " °C"; strong: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: "↑  Up"; color: Theme.muted }
                    Txt { text: Sys.fmtRate(Sys.txRate); strong: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Txt { Layout.fillWidth: true; text: "↓  Down"; color: Theme.muted }
                    Txt { text: Sys.fmtRate(Sys.rxRate); strong: true }
                }
            }

            Rectangle {
                visible: opacity > 0.01
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 76
                opacity: netSeg.monitorExpanded ? 0 : 1
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.alpha(Theme.panel, 0) }
                    GradientStop { position: 1; color: Theme.panel }
                }

                Behavior on opacity {
                    NumberAnimation { duration: Theme.motionShort; easing.type: Theme.easing }
                }
            }

            Chip {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                z: 2
                text: netSeg.monitorExpanded ? "Show less" : "Show all stats"
                onClicked: netSeg.monitorExpanded = !netSeg.monitorExpanded
            }
        }
    }

    Connections {
        target: netSeg
        function onXChanged() {
            if (netSeg.detailsExpanded)
                monitorPopup.anchor.updateAnchor();
        }
        function onWidthChanged() {
            if (netSeg.detailsExpanded)
                monitorPopup.anchor.updateAnchor();
        }
    }
}
