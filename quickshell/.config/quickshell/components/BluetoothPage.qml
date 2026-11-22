import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../services"

// Bluetooth: switch, paired + nearby devices, connect / disconnect / pair /
// forget. Scanning runs only while this page is open.
ColumnLayout {
    id: page

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: page.adapter ? page.adapter.enabled : false

    readonly property var devices: {
        if (!page.adapter)
            return [];
        const scanning = page.adapter.discovering;
        const list = page.adapter.devices.values.filter(d => d.connected || d.paired || (scanning && d.name && d.name.length > 0));
        list.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name));
        return list;
    }

    function glyphFor(icon) {
        const i = icon || "";
        if (i.indexOf("headset") >= 0 || i.indexOf("headphone") >= 0) return "";
        if (i.indexOf("mouse") >= 0) return "";
        if (i.indexOf("keyboard") >= 0) return "";
        if (i.indexOf("phone") >= 0) return "";
        return "";
    }

    spacing: 10

    onVisibleChanged: {
        if (page.adapter && page.adapter.enabled)
            page.adapter.discovering = page.visible;
        else if (page.adapter && !page.visible)
            page.adapter.discovering = false;
    }

    PageHeader {
        Layout.fillWidth: true
        title: "Bluetooth"
        switchable: true
        checked: page.btOn
        onToggled: {
            if (page.adapter)
                page.adapter.enabled = !page.adapter.enabled;
        }
    }

    Txt {
        Layout.fillWidth: true
        visible: !page.adapter
        text: "No Bluetooth adapter found"
        color: Theme.muted
    }
    Txt {
        Layout.fillWidth: true
        visible: page.adapter && !page.btOn
        text: "Bluetooth is off"
        color: Theme.muted
    }
    Txt {
        Layout.fillWidth: true
        visible: page.btOn && page.devices.length === 0
        text: page.adapter && page.adapter.discovering ? "Searching for devices…" : "No devices. Tap Scan."
        color: Theme.muted
    }

    Flickable {
        Layout.fillWidth: true
        visible: page.btOn && page.devices.length > 0
        implicitHeight: Math.min(list.implicitHeight, 340)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list
            width: parent.width
            spacing: 6

            Repeater {
                model: page.devices
                delegate: ListRow {
                    id: dev
                    required property var modelData
                    readonly property bool working: dev.modelData.state === BluetoothDeviceState.Connecting || dev.modelData.state === BluetoothDeviceState.Disconnecting

                    Layout.fillWidth: true
                    glyph: page.glyphFor(dev.modelData.icon)
                    title: dev.modelData.name
                    subtitle: dev.modelData.connected ? "Connected" + (dev.modelData.batteryAvailable ? " · " + Math.round(dev.modelData.battery * 100) + "%" : "") : (dev.modelData.paired ? "Paired" : "Available")
                    active: dev.modelData.connected
                    busy: dev.working

                    onClicked: {
                        if (dev.working)
                            return;
                        if (dev.modelData.connected)
                            dev.modelData.disconnect();
                        else if (dev.modelData.paired)
                            dev.modelData.connect();
                        else
                            dev.modelData.pair();
                    }

                    Chip {
                        visible: dev.modelData.paired
                        text: "Forget"
                        onClicked: dev.modelData.forget()
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Chip {
            visible: page.btOn
            text: page.adapter && page.adapter.discovering ? "Stop scan" : "Scan"
            onClicked: {
                if (page.adapter)
                    page.adapter.discovering = !page.adapter.discovering;
            }
        }
        Chip {
            text: "More settings"
            onClicked: {
                UiState.ccOpen = false;
                Quickshell.execDetached(["blueman-manager"]);
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }
}
