import QtQuick 2.2
import SialanTools 1.0
import Sigram 1.0

SialanMain {
    id: main
    width: 1024
    height: 600
    color: "#333333"
    mainFrame: main_frame
    focus: true

    property variant authDialog
    property alias profiles: profile_model
    property alias emojis: emojis_obj

    property color backColor0: "#eeeeee"
    property color backColor1: "#cccccc"
    property color backColor2: "#fafafa"
    property color textColor0: "#111111"
    property color textColor1: "#333333"
    property color textColor2: "#888888"

    Keys.onEscapePressed: {
        SApp.back()
    }

    Connections {
        target: Sigram
        onBackRequest: SApp.back()
    }

    Connections {
        target: SApp
        onBackRequest: {
            var res = BackHandler.back()
            if( !res && !Devices.isDesktop )
                Sigram.close()
        }
    }

    Emojis {
        id: emojis_obj
        currentTheme: "twitter"
    }

    ProfilesModel {
        id: profile_model
    }

    Timer {
        id: init_timer
        interval: 1500
        Component.onCompleted: start()
        onTriggered: {
            if( profiles.count == 0 )
                qlist.currentIndex = 2
            else
                qlist.currentIndex = 1
        }
    }

    Item {
        id: main_frame
        anchors.fill: parent

        QueueList {
            id: qlist
            anchors.fill: parent
            components: [splash_component, accounts_frame, auth_dlg_component]
            currentIndex: 0
        }
    }

    Component {
        id: auth_dlg_component
        AuthenticateDialog {
            anchors.fill: parent
            onAccepted: {
                var item = profiles.add(number)
                item.name = "AA"
                qlist.currentIndex = 1
            }
        }
    }

    Component {
        id: accounts_frame
        AccountsTabFrame {
            anchors.fill: parent
            property bool onceInstance: true
        }
    }

    Component {
        id: splash_component
        SigramSplash {
            id: splash
            anchors.fill: parent
        }
    }

    function addAccount() {
        qlist.currentIndex = 2
        BackHandler.pushHandler(main, main.backToAccounts )
    }

    function backToAccounts() {
        qlist.currentIndex = 1
        BackHandler.removeHandler(main)
    }
}
