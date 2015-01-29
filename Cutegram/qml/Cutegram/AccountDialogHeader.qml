import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Rectangle {
    id: header
    height: 60*Devices.density

    property Dialog currentDialog

    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false
    property User user: telegramObject.user(currentDialog.encrypted?enChatUid:currentDialog.peer.userId)
    property Chat chat: telegramObject.chat(currentDialog.peer.chatId)

    property EncryptedChat enchat: telegramObject.encryptedChat(currentDialog.peer.userId)
    property int enChatUid: enchat.adminId==telegramObject.me? enchat.participantId : enchat.adminId

    property bool refreshing: false

    property real typeUserStatusOffline: 0x8c703f
    property real typeUserStatusEmpty: 0x9d05049
    property real typeUserStatusOnline: 0xedb93949

    signal clicked()

    onRefreshingChanged: {
        if( refreshing )
            indicator.start()
        else
            indicator.stop()
    }

    Image {
        id: secret_img
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.margins: 10*Devices.density
        source: "files/lock.png"
        sourceSize: Qt.size(width, height)
        visible: currentDialog.encrypted
        width: 14*Devices.density
        height: width
    }

    Text {
        id: secret_txt
        anchors.bottom: secret_img.bottom
        anchors.left: secret_img.right
        anchors.leftMargin: 8*Devices.density
        anchors.bottomMargin: -8*Devices.density
        font.pixelSize: 10*Devices.fontDensity
        font.family: AsemanApp.globalFont.family
        text: qsTr("Secret chat (experimental)")
        color: "#ffffff"
        visible: currentDialog.encrypted
    }

    Text {
        id: title_txt
        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        color: currentDialog.encrypted? "#eeeeee" : "#111111"
        font.pixelSize: 15*Devices.fontDensity
        font.family: AsemanApp.globalFont.family
        text: {
            if( !currentDialog )
                return ""
            if( isChat )
                return chat? chat.title : ""
            else
                return user? user.firstName + " " + user.lastName : ""
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: title_txt.horizontalCenter
        anchors.bottomMargin: 2*Devices.density
        color: Cutegram.highlightColor
        font.pixelSize: 9*Devices.fontDensity
        font.family: AsemanApp.globalFont.family
        visible: currentDialog != telegramObject.nullDialog && user.id != telegramObject.cutegramId
        text: {
            var result = ""
            var list = currentDialog.typingUsers
            if( list.length == 0 ) {
                if( isChat ) {
                    result += qsTr("%1 participants").arg(chat.participantsCount)
                } else {
                    var isOnline = header.user.status.classType == typeUserStatusOnline
                    result += isOnline? qsTr("Online") : qsTr("%1 was online").arg(Cutegram.getTimeString(CalendarConv.fromTime_t(header.user.status.wasOnline)))
                }

                return result
            }

            for( var i=0; i<list.length; i++ ) {
                var uid = list[i]
                var user = telegramObject.user(list[i])
                var uname = user.firstName + " " + user.lastName
                result += uname.trim()

                if( i < list.length-1 )
                    result += ", "
            }

            result = result.trim() + " typing..."
            return result
        }
    }

    Indicator {
        id: indicator
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: y
        light: false
        modern: true
        indicatorSize: 20*Devices.density
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: header.clicked()
    }

    Button {
        id: files_btn
        anchors.right: parent.right
        height: parent.height
        width: height
        icon: "files/files.png"
        iconHeight: 18*Devices.density
        cursorShape: Qt.PointingHandCursor
        highlightColor: "#1f000000"
        onClicked: {
            if(currentDialog == telegramObject.nullDialog)
                return

            var dId = currentDialog.peer.chatId
            if(dId == 0)
                dId = currentDialog.peer.userId

            Qt.openUrlExternally("file://" + telegramObject.downloadPath + "/" + dId)
        }
    }
}
