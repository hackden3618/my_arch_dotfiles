pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// System state sampled by scripts/sysstats.sh: CPU, memory, disk, temperature,
// network speed, Wi-Fi, night light and backlight.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string scriptsDir: root.home + "/.config/hypr/scripts"

    property real cpu: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real diskUsedGb: 0
    property real diskTotalGb: 0
    property int temp: 0
    property int uptimeSec: 0

    property real rxRate: 0
    property real txRate: 0

    property bool wifiOn: true
    property string ssid: ""
    property bool nightOn: false
    property real bright: 0.5       // 0..1

    // ---- formatting helpers -------------------------------------------------
    function fmtRate(b) {
        if (b >= 1048576) return (b / 1048576).toFixed(1) + "MB/s";
        if (b >= 1024) return (b / 1024).toFixed(1) + "kB/s";
        return b.toFixed(1) + "B/s";
    }
    function fmtUptime(s) {
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    // ---- actions ---------------------------------------------------------------
    function toggleWifi() {
        Quickshell.execDetached(["nmcli", "radio", "wifi", root.wifiOn ? "off" : "on"]);
        root.wifiOn = !root.wifiOn;
    }
    function toggleNight() {
        Quickshell.execDetached([root.scriptsDir + "/Hyprsunset.sh", "toggle"]);
        root.nightOn = !root.nightOn;
    }
    function setBrightness(frac) {
        const f = Math.max(0.01, Math.min(1, frac));
        root.bright = f;
        Quickshell.execDetached(["brightnessctl", "set", Math.round(f * 100) + "%"]);
    }
    function stepBrightness(dir) {
        const f = Math.max(0.01, Math.min(1, root.bright + dir * 0.05));
        root.setBrightness(f);
        UiState.showOsd("brightness", f);
    }

    // ---- sampling ----------------------------------------------------------------
    property var _prev: null

    function _parse(text) {
        const kv = {};
        for (const line of text.split("\n")) {
            const i = line.indexOf("=");
            if (i > 0)
                kv[line.slice(0, i)] = line.slice(i + 1).trim();
        }
        const now = Date.now();
        const cpuTotal = Number(kv.cpu_total), cpuIdle = Number(kv.cpu_idle);
        const rx = Number(kv.rx), tx = Number(kv.tx);

        if (root._prev) {
            const dt = Math.max(0.5, (now - root._prev.t) / 1000);
            const dTotal = cpuTotal - root._prev.cpuTotal;
            const dIdle = cpuIdle - root._prev.cpuIdle;
            if (dTotal > 0)
                root.cpu = Math.max(0, Math.min(1, 1 - dIdle / dTotal));
            root.rxRate = Math.max(0, (rx - root._prev.rx) / dt);
            root.txRate = Math.max(0, (tx - root._prev.tx) / dt);
        }
        root._prev = { t: now, cpuTotal: cpuTotal, cpuIdle: cpuIdle, rx: rx, tx: tx };

        const gb = 1048576; // KiB -> GiB
        root.memTotalGb = Number(kv.mem_total) / gb;
        root.memUsedGb = (Number(kv.mem_total) - Number(kv.mem_avail)) / gb;
        root.diskTotalGb = Number(kv.disk_total) / gb;
        root.diskUsedGb = Number(kv.disk_used) / gb;
        root.temp = Number(kv.temp) || 0;
        root.uptimeSec = Number(kv.uptime) || 0;

        if (kv.wifi !== undefined) root.wifiOn = kv.wifi === "enabled";
        root.ssid = kv.ssid || "";
        root.nightOn = kv.night === "1";
        if (kv.bright !== undefined && kv.bright !== "")
            root.bright = Math.max(0, Math.min(1, Number(kv.bright) / 100));
    }

    Process {
        id: sampler
        command: ["bash", Quickshell.shellPath("scripts/sysstats.sh")]
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!sampler.running)
                sampler.running = true;
        }
    }
}
