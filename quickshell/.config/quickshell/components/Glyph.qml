import QtQuick
import "../services"

// One Nerd Font icon (JetBrainsMono Nerd Font, Font Awesome range).
Text {
    property int size: 16

    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
