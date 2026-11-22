pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Volume and mic over PipeWire. Hyprland keybinds call these through
// `qs ipc call audio ...`, which also pops the OSD.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property real volume: root.sink && root.sink.audio ? root.sink.audio.volume : 0
    readonly property bool muted: root.sink && root.sink.audio ? root.sink.audio.muted : false
    readonly property string sinkName: root.sink ? (root.sink.nickname || root.sink.description || root.sink.name) : "No output"

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function setVolume(v) {
        if (!root.sink || !root.sink.audio)
            return;
        const clamped = Math.max(0, Math.min(1, v));
        root.sink.audio.muted = false;
        root.sink.audio.volume = clamped;
    }

    function step(dir) {
        const v = Math.max(0, Math.min(1, root.volume + dir * 0.05));
        root.setVolume(v);
        UiState.showOsd("volume", v);
    }
    function inc() { root.step(1); }
    function dec() { root.step(-1); }

    function toggleMute() {
        if (!root.sink || !root.sink.audio)
            return;
        const next = !root.muted;
        root.sink.audio.muted = next;
        UiState.showOsd(next ? "mute" : "volume", next ? 0 : root.volume);
    }

    function toggleMic() {
        if (!root.source || !root.source.audio)
            return;
        root.source.audio.muted = !root.source.audio.muted;
    }
}
