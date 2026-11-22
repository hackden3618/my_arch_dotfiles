import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import "../services"

// Theme: pick a wallpaper and the whole desktop retheme itself. SetWallpaper.sh
// sets the image and runs wallust, which rewrites qml_color.json (this shell),
// the rofi, kitty and GTK palettes and the Hyprland borders.
ColumnLayout {
    id: page

    readonly property string wallDir: Sys.home + "/Pictures/wallpapers"

    function apply(path) {
        Quickshell.execDetached([Sys.scriptsDir + "/SetWallpaper.sh", path]);
    }

    spacing: 10

    PageHeader {
        Layout.fillWidth: true
        title: "Theme"
    }

    // live palette preview: the colours wallust just produced
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: 8
            delegate: Rectangle {
                required property int index
                Layout.fillWidth: true
                implicitHeight: 22
                radius: 11
                color: Theme.pick("color" + (index + 1), "#000000")
                border.width: 1
                border.color: Theme.cardEdge
            }
        }
    }

    Txt {
        Layout.fillWidth: true
        text: "Colours follow the wallpaper. Pick one and the bar, panels, rofi, terminal and borders recolour."
        size: 11
        color: Theme.muted
        wrapMode: Text.Wrap
        maximumLineCount: 2
    }

    Txt {
        Layout.fillWidth: true
        visible: wallpapers.count === 0
        text: "No images in ~/Pictures/wallpapers"
        color: Theme.muted
    }

    GridView {
        id: grid
        Layout.fillWidth: true
        visible: wallpapers.count > 0
        implicitHeight: 3 * cellHeight
        cellWidth: Math.floor(width / 3)
        cellHeight: Math.round(cellWidth * 0.62)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        model: FolderListModel {
            id: wallpapers
            folder: "file://" + page.wallDir
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"]
            showDirs: false
            sortField: FolderListModel.Name
        }

        delegate: Item {
            id: cell
            required property string filePath
            required property url fileUrl
            required property string fileName

            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 12
                clip: true
                color: Theme.card
                border.width: thumb.containsMouse ? 2 : 1
                border.color: thumb.containsMouse ? Theme.accentEdge : Theme.cardEdge

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: cell.fileUrl
                    sourceSize: Qt.size(260, 170)
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }

                MouseArea {
                    id: thumb
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.apply(cell.filePath)
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Chip {
            text: "Random"
            onClicked: Quickshell.execDetached([Sys.home + "/.config/hypr/UserScripts/WallpaperRandom.sh"])
        }
        Chip {
            text: "Dark / Light"
            onClicked: Quickshell.execDetached([Sys.scriptsDir + "/DarkLight.sh"])
        }
        Chip {
            text: "Rofi picker"
            onClicked: {
                UiState.ccOpen = false;
                Quickshell.execDetached([Sys.home + "/.config/hypr/UserScripts/WallpaperSelect.sh"]);
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }
}
