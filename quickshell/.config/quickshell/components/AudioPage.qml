import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../services"

// Sound: pick the output device and set volume per app.
ColumnLayout {
    id: page

    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: page.nodes.filter(n => n.isSink && !n.isStream)
    readonly property var streams: page.nodes.filter(n => n.isSink && n.isStream)

    spacing: 10

    PwObjectTracker {
        objects: page.sinks.concat(page.streams)
    }

    PageHeader {
        Layout.fillWidth: true
        title: "Sound"
    }

    SliderRow {
        Layout.fillWidth: true
        glyph: Audio.muted ? "" : ""
        label: "Output volume"
        value: Audio.muted ? 0 : Audio.volume
        onMoved: v => Audio.setVolume(v)
    }

    Txt {
        text: "Output device"
        size: 11
        color: Theme.muted
    }

    Repeater {
        model: page.sinks
        delegate: ListRow {
            id: sink
            required property var modelData
            Layout.fillWidth: true
            glyph: ""
            title: sink.modelData.nickname || sink.modelData.description || sink.modelData.name
            active: Audio.sink !== null && Audio.sink !== undefined && Audio.sink.id === sink.modelData.id
            onClicked: Pipewire.preferredDefaultAudioSink = sink.modelData
        }
    }

    Txt {
        visible: page.streams.length > 0
        text: "Apps"
        size: 11
        color: Theme.muted
    }

    Repeater {
        model: page.streams
        delegate: SliderRow {
            id: stream
            required property var modelData
            Layout.fillWidth: true
            glyph: ""
            label: (stream.modelData.properties && stream.modelData.properties["application.name"]) || stream.modelData.description || stream.modelData.name
            value: stream.modelData.audio ? stream.modelData.audio.volume : 0
            onMoved: v => {
                if (stream.modelData.audio)
                    stream.modelData.audio.volume = v;
            }
        }
    }
}
