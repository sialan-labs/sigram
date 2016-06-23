import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import "toolkit" as ToolKit
import "account" as Account
import "globals"
import "."

AsemanApplication {
    applicationName: "Cutegram"
    applicationDisplayName: "Cutegram"
    applicationVersion: "3.0.0"
    organizationName: "Aseman"
    organizationDomain: "land.aseman"

    ToolKit.CutegramSystemTray {
        window: mainWindow
        badgeCount: profiles_model.unreadCount
    }

    Notification {
        id: notification
    }

    Telegram.DocumentExporter {
        destination: "/home/bardia/docs"
        Component.onCompleted: exportDocuments()
    }

    Telegram.ProfileManagerModel {
        id: profiles_model
        source: CutegramGlobals.profilePath + "/profiles.sqlite"
        engineDelegate: Account.CutegramAccountEngine {
            window: mainWindow
            notificationManager: notification
        }

        readonly property int unreadCount: {
            var res = 0
            for(var i=0; i<count; i++)
                res += get(i, Telegram.ProfileManagerModel.DataEngine).unreadCount
            return res
        }

        Component.onCompleted: if(count == 0) addNew()
    }

    TitleBarColorGrabber {
        id: tgrabber
        window: mainWindow
        defaultColor: Desktop.titleBarColor
        autoRefresh: true
        onColorChanged: CutegramGlobals.titleBarColor = color
    }

    Timer {
        id: refreshTimer
        interval: 300
        repeat: false
        onTriggered: tgrabber.refresh()
    }

    ApplicationWindow {
        id: mainWindow
        width: CutegramSettings.windowWidth*Devices.density
        height: CutegramSettings.windowHeight*Devices.density
        onXChanged: refreshTimer.restart()
        onYChanged: refreshTimer.restart()
        onActiveChanged: refreshTimer.restart()
        onVisibleChanged: refreshTimer.restart()

        onWidthChanged: CutegramSettings.windowWidth = width/Devices.density
        onHeightChanged: CutegramSettings.windowHeight = height/Devices.density

        ToolKit.CutegramMain {
            anchors.fill: parent
            profilesModel: profiles_model
        }

        Component.onCompleted: {
            CutegramGlobals.mainWindow = mainWindow
            switch(CutegramSettings.windowStateOnStart)
            {
            case CutegramEnums.windowStateAuto:
                visible = CutegramSettings.lastWindowState
                break
            case CutegramEnums.windowStateHidden:
                visible = false
                break
            case CutegramEnums.windowStateVisible:
                visible = true
                break
            }
        }
        Component.onDestruction: CutegramSettings.lastWindowState = visible
    }

    FontLoader {
        source: "awesome/fontawesome-webfont.ttf"
    }

    Component.onCompleted: CutegramEmojiDatabase.initDatabase()
}

