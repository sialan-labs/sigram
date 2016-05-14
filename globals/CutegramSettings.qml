pragma Singleton
import QtQuick 2.4
import AsemanTools 1.0
import "."

AsemanObject {

    property alias sideBarWidth: general.sideBarWidth
    property alias windowWidth: general.windowWidth
    property alias windowHeight: general.windowHeight

    readonly property url defaultNotifySound: "../sounds/new_msg.ogg"
    property alias notifications: general.notifications
    property alias notifySound: general.notifySound

    property alias lastWindowState: general.lastWindowState
    property alias windowStateOnStart: general.windowStateOnStart

    property alias trayIconStyle: general.trayIconStyle
    property alias defaultEmoji: general.defaultEmoji
    property alias masterColor: general.masterColor
    property alias minimalMode: general.minimalMode

    readonly property real messageItemRadius: 5*Devices.density

    Connections {
        target: CutegramGlobals.fontHandler
        onFontsChanged: general.fonts = CutegramGlobals.fontHandler.save()
    }

    Settings {
        id: general
        source: CutegramGlobals.profilePath + "/settings.ini"
        category: "General"

        property real sideBarWidth: 280
        property real windowWidth: 1100
        property real windowHeight: 640

        property bool notifications: true
        property url notifySound: "../sounds/new_msg.ogg"

        property bool lastWindowState: false
        property int windowStateOnStart: 0

        property string defaultEmoji: "twemoji"
        property string masterColor: ""
        property bool minimalMode: false

        property int trayIconStyle: 0

        property variant fonts

        onDefaultEmojiChanged: CutegramEmojis.defaultEmoji = defaultEmoji
        onMasterColorChanged: {
            if(masterColor.length != 0)
                CutegramGlobals.baseColor = masterColor
            else
                CutegramGlobals.baseColor = CutegramGlobals.defaultBaseColor
        }
        Component.onCompleted: {
            CutegramGlobals.fontHandler.load(fonts)
            CutegramEmojis.defaultEmoji = defaultEmoji
            if(masterColor.length != 0)
                CutegramGlobals.baseColor = masterColor
        }
    }
}

