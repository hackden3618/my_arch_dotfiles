pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Every colour in the shell comes from here, and every value here comes from
// wallust (~/.config/quickshell/qml_color.json, rendered from the template in
// hypr/.config/wallust/templates/qml_color.json). Change wallpaper -> wallust
// rewrites the file -> this singleton reloads it -> the whole shell recolours
// live, no restart.
Singleton {
    id: root

    property var raw: ({})

    function pick(key, fallback) {
        const v = root.raw[key];
        return (typeof v === "string" && /^#[0-9a-fA-F]{6,8}$/.test(v)) ? v : fallback;
    }

    // WCAG relative luminance of a colour
    function lum(c) {
        function ch(v) { return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }
        return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
    }
    function ratio(a, b) {
        const x = lum(a), y = lum(b);
        return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05);
    }
    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }
    // readable text colour for a given background
    function onColor(c) { return root.lum(c) > 0.35 ? root.ink : root.snow; }

    // ---- fixed anchors -----------------------------------------------------
    readonly property color white: "#ffffff"
    readonly property color snow: "#f4f7ff"
    readonly property color ink: "#10141c"

    // semantic colours that should not follow the wallpaper (same as your CSS)
    readonly property color warm: "#ffa726"      // active workspace, play button
    readonly property color danger: "#ff5d5d"    // unread dot, critical, low battery
    readonly property color ok: "#2fb36b"

    // ---- raw wallust palette ----------------------------------------------
    readonly property color bg: root.pick("background", "#0f1218")
    readonly property color fgRaw: root.pick("foreground", "#cdd3d6")
    readonly property color c1: root.pick("color1", "#1a2030")
    readonly property color c7: root.pick("color7", "#b0b8bc")
    readonly property color c11: root.pick("color11", "#505c62")
    readonly property color c12: root.pick("color12", "#606e76")
    readonly property color c13: root.pick("color13", "#718189")

    // ---- derived, contrast-checked tokens ----------------------------------
    // wallust's foreground can be dim on some wallpapers, so lift it until it
    // reads on the dark panels. This is what keeps text legible everywhere.
    readonly property color fg: root.lum(root.fgRaw) < 0.5 ? root.mix(root.fgRaw, root.white, 0.7) : root.fgRaw
    readonly property color muted: root.mix(root.fg, root.bg, 0.38)

    readonly property color accent: root.ratio(root.c12, root.bg) < 2.5 ? root.mix(root.c12, root.white, 0.4) : root.c12
    readonly property color onAccent: root.onColor(root.accent)
    readonly property color accentEdge: root.mix(root.accent, root.white, 0.3)

    readonly property color pill: Qt.alpha(root.c1, 0.92)
    readonly property color pillHover: root.mix(root.c1, root.accent, 0.22)
    readonly property color edge: root.c13
    readonly property color edgeHi: root.mix(root.c13, root.white, 0.3)

    readonly property color panel: Qt.alpha(root.bg, 0.82)
    readonly property color panelEdge: Qt.alpha(root.c13, 0.4)
    readonly property color card: root.mix(root.bg, root.fg, 0.09)
    readonly property color cardEdge: Qt.alpha(root.fg, 0.08)
    readonly property color tileOff: Qt.alpha(root.fg, 0.07)
    readonly property color scrim: Qt.alpha(root.bg, 0.55)

    // ---- type and shape ----------------------------------------------------
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int radiusPill: 19
    readonly property int radiusCard: 20
    readonly property int radiusPanel: 28

    FileView {
        id: file
        path: Quickshell.shellPath("qml_color.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.raw = JSON.parse(text());
            } catch (e) {
                console.warn("Theme: bad qml_color.json, keeping previous palette:", e);
            }
        }
    }

    // wallust may replace the file atomically, which can drop the inotify
    // watch, so re-read cheaply as a safety net.
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: file.reload()
    }
}
