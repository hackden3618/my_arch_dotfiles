pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Wi-Fi scanning and connecting through nmcli. The Wi-Fi page sets `active`
// while it is visible, which is the only time scanning runs.
Singleton {
    id: root

    property bool active: false
    property bool scanning: false
    property var networks: []        // [{ ssid, signal, secure, inUse, known }]
    property string busySsid: ""     // network a connect/disconnect is running for
    property string status: ""       // last error, empty when fine
    property bool needsPassword: false

    // nmcli -t escapes ':' and '\' with a backslash
    function splitTerse(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[i + 1];
                i++;
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }
        out.push(cur);
        return out;
    }

    function _parse(text) {
        const known = {};
        const best = {};
        for (const line of text.split("\n")) {
            if (line.startsWith("K:")) {
                const f = root.splitTerse(line.slice(2));
                if (f.length >= 2 && f[1].indexOf("wireless") >= 0)
                    known[f[0]] = true;
            } else if (line.startsWith("W:")) {
                const f = root.splitTerse(line.slice(2));
                if (f.length < 4 || f[3].length === 0)
                    continue;
                const n = {
                    inUse: f[0] === "*",
                    signal: Number(f[1]) || 0,
                    secure: f[2].length > 0 && f[2] !== "--",
                    ssid: f[3],
                    known: false
                };
                const prev = best[n.ssid];
                if (!prev || n.inUse || (!prev.inUse && n.signal > prev.signal))
                    best[n.ssid] = n;
            }
        }
        const list = Object.values(best);
        for (const n of list)
            n.known = known[n.ssid] === true;
        list.sort((a, b) => (b.inUse - a.inUse) || (b.known - a.known) || (b.signal - a.signal));
        root.networks = list;
    }

    function scan() {
        if (scanProc.running)
            return;
        root.scanning = true;
        scanProc.running = true;
    }

    function connect(ssid, password) {
        if (actionProc.running)
            return;
        root.busySsid = ssid;
        root.status = "";
        root.needsPassword = false;
        const cmd = ["nmcli", "--wait", "20", "dev", "wifi", "connect", ssid];
        if (password && password.length > 0)
            cmd.push("password", password);
        actionProc.command = cmd;
        actionProc.running = true;
    }

    function disconnect(ssid) {
        if (actionProc.running)
            return;
        root.busySsid = ssid;
        actionProc.command = ["nmcli", "connection", "down", "id", ssid];
        actionProc.running = true;
    }

    function forget(ssid) {
        if (actionProc.running)
            return;
        root.busySsid = ssid;
        actionProc.command = ["nmcli", "connection", "delete", "id", ssid];
        actionProc.running = true;
    }

    Process {
        id: scanProc
        command: ["bash", "-c", "nmcli -t -f NAME,TYPE connection show | sed 's/^/K:/'; nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan auto | sed 's/^/W:/'"]
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
        onExited: root.scanning = false
    }

    Process {
        id: actionProc
        stdout: StdioCollector {
            id: actionOut
        }
        stderr: StdioCollector {
            id: actionErr
        }
        onExited: (code, status) => {
            root.busySsid = "";
            if (code === 0) {
                root.status = "";
            } else {
                const msg = (actionErr.text || actionOut.text).trim();
                root.needsPassword = msg.indexOf("Secrets were required") >= 0 || msg.indexOf("password") >= 0;
                root.status = root.needsPassword ? "Password needed" : (msg.length > 0 ? msg : "Could not complete that");
            }
            root.scan();
        }
    }

    Timer {
        interval: 8000
        repeat: true
        running: root.active && Sys.wifiOn
        triggeredOnStart: true
        onTriggered: root.scan()
    }
}
