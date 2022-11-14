pragma Singleton
import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import AsemanQml.Widgets 2.0
import QtQuick.Controls 1.3
import QtQuick.Window 2.2

AsemanObject {
    property AsemanWindow mainWindow
    property alias systemPalette: palette

    property color titleBarColor
    readonly property bool titleBarIsDarkColor: (titleBarColor.r + titleBarColor.g + titleBarColor.b)/3 < 0.5
    readonly property color titleBarTextsColor: titleBarIsDarkColor? "#ffffff" : "#333333"

    property color foregroundColor: "#e6e6e6"
    property color baseColor: defaultBaseColor
    readonly property color defaultBaseColor: {
        if(systemPalette.highlight == "#f07746" && Desktop.desktopSession == Desktop.Unity)
            return "#E77E54"
        else
            return "#5a5397"
    }
    property color linkColor: highlightColors
    property color highlightColors: "#489fcd"
    property real panelWidth: 46*Devices.density
    property string profilePath: AsemanApp.homePath + "/3/"
    property alias fontHandler: font_handler

    FontHandler {
        id: font_handler
    }

    SystemPalette {
        id: palette
        colorGroup: SystemPalette.Active
    }

    function textAlignment(txt) {
        var dir = Tools.directionOf(txt)
        switch(dir) {
        case Qt.LeftToRight:
            return TextEdit.AlignLeft
        case Qt.RightToLeft:
            return TextEdit.AlignRight
        }
        return TextEdit.AlignLeft
    }
}

