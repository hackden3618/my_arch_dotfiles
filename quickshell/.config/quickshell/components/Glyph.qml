import QtQuick
import "../services"

// Nerd Font glyph, kept separate from the interface typeface.
Text {
    property int size: 16

    color: Theme.fg
    font.family: Theme.iconFont
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation { duration: Theme.motionMedium; easing.type: Theme.easing }
    }
}
