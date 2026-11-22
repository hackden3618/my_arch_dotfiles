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
    // Move a preferred palette color toward whichever of ink or white gives
    // better contrast, stopping once it meets the requested WCAG ratio.
    function contrastColor(preferred, background, minimum) {
        if (root.ratio(preferred, background) >= minimum)
            return preferred;
        const target = root.ratio(root.white, background) >= root.ratio(root.ink, background)
            ? root.white : root.ink;
        for (let i = 1; i <= 40; i++) {
            const candidate = root.mix(preferred, target, i / 40);
            if (root.ratio(candidate, background) >= minimum)
                return candidate;
        }
        return target;
    }
    function textOn(background) { return root.contrastColor(root.fgRaw, background, 4.5); }
    function mutedOn(background) {
        const readable = root.textOn(background);
        return root.contrastColor(root.mix(readable, background, 0.38), background, 4.5);
    }
    function onColor(background) { return root.textOn(background); }

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
    // Use the opaque panel as the reference surface for shell text.
    readonly property color fg: root.textOn(root.panel)
    readonly property color muted: root.mutedOn(root.panel)

    readonly property bool dark: root.lum(root.bg) < 0.45
    // Hyprland's focused-window border uses Wallust color12.
    readonly property color windowBorder: root.c12
    readonly property color accent: root.ratio(root.c12, root.bg) < 2.5 ? root.mix(root.c12, root.white, 0.4) : root.c12
    readonly property color onAccent: root.onColor(root.accent)
    readonly property color accentEdge: root.mix(root.accent, root.white, 0.3)
    readonly property color accentContainer: root.mix(root.bg, root.accent, root.dark ? 0.34 : 0.18)
    readonly property color onAccentContainer: root.onColor(root.accentContainer)

    readonly property color surfaceLow: root.mix(root.bg, root.fg, 0.045)
    readonly property color surface: root.mix(root.bg, root.fg, 0.075)
    readonly property color surfaceHigh: root.mix(root.bg, root.fg, 0.12)
    readonly property color pill: root.mix(root.mix(root.bg, root.c1, 0.18), root.fg, 0.08)
    readonly property color pillHover: root.mix(root.pill, root.accent, 0.18)
    readonly property color edge: root.windowBorder
    readonly property color edgeHi: root.windowBorder

    // Keep floating surfaces fully opaque so the Control Center remains clear
    // over bright or detailed wallpapers. Both colors still follow Wallust.
    readonly property color panel: root.mix(root.bg, root.c1, 0.72)
    readonly property color panelEdge: root.windowBorder
    readonly property color card: root.surfaceLow
    readonly property color cardEdge: root.mix(root.bg, root.windowBorder, 0.52)
    readonly property color tileOff: root.surface
    readonly property color scrim: Qt.alpha(root.bg, 0.55)

    readonly property int motionShort: 170
    readonly property int motionMedium: 260
    readonly property int motionLong: 360
    readonly property int easing: Easing.OutCubic

    // ---- type and shape ----------------------------------------------------
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property string iconFont: root.font
    readonly property int radiusPill: 20
    readonly property int radiusChip: 14
    readonly property int radiusCard: 22
    readonly property int radiusPanel: 32
    readonly property real borderWidth: 1.5
    readonly property real borderWidthStrong: 2

    // Reload only when the file content really changed. Assigning a fresh
    // object to `raw` re-evaluates every colour binding in the shell, so doing
    // it blindly (as a timer used to) burns CPU for nothing.
    property string lastText: ""

    FileView {
        id: file
        path: Quickshell.shellPath("qml_color.json")
        watchChanges: true
        onFileChanged: debounce.restart()
        onLoaded: {
            const t = text();
            if (t === root.lastText)
                return;
            try {
                const parsed = JSON.parse(t);
                root.lastText = t;
                root.raw = parsed;
            } catch (e) {
                console.warn("Theme: bad qml_color.json, keeping previous palette:", e);
            }
        }
    }

    // wallust writes several templates in a burst; wait for it to settle
    Timer {
        id: debounce
        interval: 250
        onTriggered: file.reload()
    }

    // safety net in case an atomic replace drops the inotify watch (cheap now:
    // an unchanged file is ignored above)
    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: file.reload()
    }
}
