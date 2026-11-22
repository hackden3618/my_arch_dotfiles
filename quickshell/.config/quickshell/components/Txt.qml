import QtQuick
import "../services"

// Text with the shell's font and a readable default colour.
Text {
    property int size: 13
    property bool strong: false

    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: size
    font.weight: strong ? Font.Bold : Font.Medium
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
