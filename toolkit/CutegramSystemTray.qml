import QtQuick 2.4
import AsemanTools 1.0
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import "../globals"

SystemTray {
    icon: {
        switch(CutegramSettings.trayIconStyle)
        {
        case CutegramEnums.trayIconStyleDark:
            return "files/systray-dark.png"
        case CutegramEnums.trayIconStyleAuto:
            switch(Desktop.desktopSession)
            {
            case Desktop.GnomeFallBack:
            case Desktop.Mac:
            case Desktop.Kde:
            case Desktop.Plasma:
                return "files/systray-dark.png"
            case Desktop.Windows:
            case Desktop.Gnome:
            case Desktop.Unknown:
                return "files/systray.png"
            case Desktop.Unity:
                if(Desktop.titleBarIsDark)
                    return "files/systray.png"
                else
                    return "files/systray-dark.png"
            }

            return "files/systray.png"
        case CutegramEnums.trayIconStyleLight:
            return "files/systray.png"
        }
    }
    visible: true
    menu: [qsTr("Show"), qsTr("About"), "", qsTr("Quit")]

    property AsemanWindow window
    signal aboutRequest()

    onMenuTriggered: {
        switch(index) {
        case 0:
            window.visible = true
            window.requestActivate()
            break
        case 1:
            aboutRequest()
            break
        case 3:
            AsemanApp.exit(0)
            break
        }
    }

    onActivated: {
        switch(reason) {
        case SystemTray.ActivateTrigger:
            if(!window.active && window.visible) {
                window.requestActivate()
            } else {
                window.visible = !window.visible
            }
            break
        }
    }
}

