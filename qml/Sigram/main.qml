import QtQuick 2.2
import SialanTools 1.0
import Sigram 1.0

SialanMain {
    id: main
    width: 1024
    height: 600
    color: "#333333"
    mainFrame: main_frame

    property variant authDialog

    Telegram {
        id: telegram
        configPath: SApp.homePath
        publicKeyFile: Devices.resourcePath + "/tg-server.pub"
//        phoneNumber: "+989128448407"
        onAuthNeededChanged: {
            if( !authNeeded )
                return

            authDialog = auth_dlg_component.createObject(mainFrame)
        }
    }

    Item {
        id: main_frame
        anchors.fill: parent

        QueueList {
            id: qlist
            anchors.fill: parent
            components: [splash_component, auth_dlg_component]
        }

        Timer {
            interval: 4000
            repeat: true
            onTriggered: qlist.currentIndex++
            Component.onCompleted: start()
        }
    }

    Component {
        id: auth_dlg_component
        AuthenticateDialog {
            anchors.fill: parent
        }
    }

    Component {
        id: splash_component
        SigramSplash {
            id: splash
            anchors.fill: parent
        }
    }
}
