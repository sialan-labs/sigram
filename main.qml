import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Window {
    id: main
    visible: true
    width: 1024
    height: 600

    property real physicalPlatformScale: 1
    property real fontsScale: 1
    property string globalNormalFontFamily: "Open Sans"
    property string globalTextFontFamily: "Droid Arabic Naskh"

    property bool imageBack: Gui.background.length != 0

    property alias current: chat_frame.current
    property bool about: false
    property bool aboutSialan: false

    property alias menu: mnu_item
    property alias mainFrame: main_frame
    property alias chatFrame: chat_frame
    property alias flipMenu: flip_menu

    property alias focus: main_frame.focus

    property int forwarding: 0
    property int forwardTo: 0

    property variant auth_object

    Connections {
        target: Telegram
        onStartedChanged: status_changer.restart()
        onAuthenticatingChanged: {
            if(Telegram.authenticating)
                startAuthenticating()
            else
            if( auth_object ) {
                auth_object.destroy()
                Gui.firstTime = false
            }
        }
    }
    Component {
        id: font_loader
        FontLoader {}
    }

    onActiveChanged: status_changer.restart()
    onVisibleChanged: status_changer.restart()
    Component.onCompleted: {
        var fonts = Gui.fonts()
        for( var i=0; i<fonts.length; i++ ) {
            var obj = font_loader.createObject(main)
            obj.source = "file://" + fonts[i]
        }

        if( Telegram.authenticating || Gui.firstTime )
            startAuthenticating()
    }

    Component {
        id: auth_component
        StartPage {
            anchors.fill: parent
        }
    }

    AboutSialan {
        anchors.fill: parent
        start: aboutSialan
    }

    About {
        y: aboutSialan? main.height : 0
        width: parent.width
        height: parent.height
        color: "#0d80ec"

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    Rectangle {
        id: main_frame
        y: about || aboutSialan? main.height : 0
        width: parent.width
        height: parent.height
        color: "#4098BF"

        Keys.onEscapePressed: {
            if( aboutSialan )
                aboutSialan = false
            else
            if( about )
                about = false
            else
            if( flipMenu.start )
                flipMenu.hide()
        }

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        ChatFrame {
            id: chat_frame
            width: parent.width
            height: parent.height
        }

        FlipMenu {
            id: flip_menu
            anchors.fill: chat_frame
        }
    }

    MenuWindow {
        id: mnu_item
        anchors.fill: parent
//        flags: Qt.Popup
    }

    Timer {
        id: status_changer
        interval: 1
        repeat: false
        onTriggered: refreshStatus()
    }

    function refreshStatus() {
        if( !Telegram.started )
            return

        Telegram.setStatusOnline( visible )
        if( visible )
            Telegram.markRead(current)
    }

    function sendNotify( msg_id ) {
        if( Telegram.messageUnread(msg_id) !== 1 )
            return

        Gui.sendNotify(msg_id)
    }

    function showMyConfigure() {
        chatFrame.chatView.showConfigure(Telegram.me)
    }

    function startAuthenticating() {
        if( auth_object )
            return

        Gui.firstTime = true
        auth_object = auth_component.createObject(main)
    }
}
