//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import "components"
import "services"

// Entry point. Start with `qs` (default config) or `qs -c quickshell`.
//
// Hyprland talks to it through IPC, e.g.:
//   qs ipc call controlcenter toggle
//   qs ipc call power toggle
//   qs ipc call audio inc | dec | mute | micmute
//   qs ipc call brightness inc | dec
//   qs ipc call notifs dnd | clear
ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Bar {}
    }

    ControlCenter {}
    Toasts {}
    PowerMenu {}
    Osd {}

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { UiState.toggleCc(); }
        function open(): void { UiState.powerOpen = false; UiState.ccOpen = true; }
        function close(): void { UiState.ccOpen = false; }
    }

    IpcHandler {
        target: "power"
        function toggle(): void { UiState.togglePower(); }
    }

    IpcHandler {
        target: "audio"
        function inc(): void { Audio.inc(); }
        function dec(): void { Audio.dec(); }
        function mute(): void { Audio.toggleMute(); }
        function micmute(): void { Audio.toggleMic(); }
    }

    IpcHandler {
        target: "brightness"
        function inc(): void { Sys.stepBrightness(1); }
        function dec(): void { Sys.stepBrightness(-1); }
    }

    IpcHandler {
        target: "notifs"
        function dnd(): void { Notifs.dnd = !Notifs.dnd; }
        function clear(): void { Notifs.clearAll(); }
    }
}
