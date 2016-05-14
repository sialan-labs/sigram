pragma Singleton
import QtQuick 2.4
import AsemanTools 1.0
import QtQuick.Controls 1.3
import QtQuick.Window 2.2


AsemanObject {
    property Window mainWindow
    property alias systemPalette: palette

    property color titleBarColor
    readonly property color titleBarTextsColor: {
        var mid = (titleBarColor.r + titleBarColor.g + titleBarColor.b)/3
        if(mid > 0.5)
            return "#333333"
        else
            return "#ffffff"
    }

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

