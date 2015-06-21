import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    id: cl_tools
    width: 100
    height: 62
    opacity: visible? 1 : 0
    visible: show || mute

    property Dialog dialog
    property variant dId: dialog.peer.chatId!=0? dialog.peer.chatId : dialog.peer.userId

    property bool show: false
    property bool mute: telegramObject.userData.isMuted(dId)

    Behavior on opacity {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 800 }
    }

    Connections {
        target: telegramObject.userData
        onMuteChanged: {
            if( id != cl_tools.dId )
                return

            cl_tools.mute = telegramObject.userData.isMuted(cl_tools.dId)
        }
    }

    Row {
        id: row
        anchors.fill: parent
        layoutDirection: Qt.RightToLeft

        Button {
            id: mute_btn
            anchors.top: row.top
            anchors.bottom: row.bottom
            width: height
            icon: cl_tools.mute? (Cutegram.currentTheme.dialogListLightIcon? "files/mute.png" : "files/mute-dark.png") : (Cutegram.currentTheme.dialogListLightIcon? "files/unmute.png" : "files/unmute-dark.png")
            normalColor: "#00000000"
            highlightColor: "#00000000"
            iconHeight: height - 10
            hoverEnabled: false
            onClicked: {
                if( cl_tools.mute )
                    telegramObject.userData.removeMute(dId)
                else
                    telegramObject.userData.addMute(dId)
            }
        }
    }
}
