import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Rectangle {
    id: header
    height: Cutegram.currentTheme.headerHeight*Devices.density
    clip: true

    property Dialog currentDialog

    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false
    property User user: telegramObject.user(currentDialog.encrypted?enChatUid:currentDialog.peer.userId)
    property Chat chat: telegramObject.chat(currentDialog.peer.chatId)

    property EncryptedChat enchat: telegramObject.encryptedChat(currentDialog.peer.userId)
    property int enChatUid: enchat.adminId==telegramObject.me? enchat.participantId : enchat.adminId

    property bool refreshing: false

    property int onlineCount: 0

    property real typeUserStatusOffline: 0x8c703f
    property real typeUserStatusEmpty: 0x9d05049
    property real typeUserStatusOnline: 0xedb93949
    property real typeUserStatusRecently: 0xe26f42f1
    property real typeUserStatusLastWeek: 0x7bf09fc
    property real typeUserStatusLastMonth: 0x77ebc742

    property bool lightIcons: {
        if(currentDialog.encrypted)
            return Cutegram.currentTheme.headerSecretLightIcon
        else
            return Cutegram.currentTheme.headerLightIcon
    }

    signal clicked()

    onRefreshingChanged: {
        if( refreshing )
            indicator.start()
        else
            indicator.stop()
    }

    onChatChanged: if(chat != telegram.nullChat) telegram.messagesGetFullChat(chat.id)
    onIsChatChanged: {
        if(isChat) {
            online_count_refresher.restart()
        } else {
            online_count_refresher.stop()
        }
    }

    Image {
        anchors.fill: parent
        anchors.margins: -3*Devices.density
        fillMode: Image.PreserveAspectCrop
        source: headerManager.background
        opacity: 0.6
        sourceSize: Qt.size(width, width*imageSize.height/imageSize.width)

        property size imageSize: Cutegram.imageSize(source)
    }

    Timer {
        id: online_count_refresher
        interval: 2000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            onlineCount = 0
            var chatFull = telegram.chatFull(chat.id)
            var participants = chatFull.participants.participants
            for(var i=0; i<participants.count; i++) {
                var userId = participants.at(i).userId
                var user = telegram.user(userId)
                if(user.status.classType == typeUserStatusOnline)
                    onlineCount++
            }
        }
    }

    Image {
        id: secret_img
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.margins: 10*Devices.density
        source: lightIcons? "files/lock.png" : "files/lock-dark.png"
        sourceSize: Qt.size(width, height)
        visible: currentDialog.encrypted
        width: 14*Devices.density
        height: width
    }

    Text {
        id: secret_txt
        anchors.verticalCenter: secret_img.verticalCenter
        anchors.left: secret_img.right
        anchors.leftMargin: 8*Devices.density
        font.pixelSize: Math.floor(10*Devices.fontDensity)
        font.family: AsemanApp.globalFont.family
        text: qsTr("Secret chat")
        color: Cutegram.currentTheme.headerSecretTitleColor
        visible: currentDialog.encrypted
    }

    Column {
        anchors.centerIn: parent

        Text {
            id: title_txt
            anchors.horizontalCenter: parent.horizontalCenter
            color: currentDialog.encrypted? Cutegram.currentTheme.headerSecretTitleColor : Cutegram.currentTheme.headerTitleColor
            font.pixelSize: Math.floor( (currentDialog.encrypted? Cutegram.currentTheme.headerSecretTitleFont.pointSize : Cutegram.currentTheme.headerTitleFont.pointSize)*Devices.fontDensity)
            font.family: currentDialog.encrypted? Cutegram.currentTheme.headerSecretTitleFont.family : Cutegram.currentTheme.headerTitleFont.family
            textFormat: Text.RichText
            text: {
                if( !currentDialog )
                    return ""
                if( isChat )
                    return emojis.textToEmojiText( chat? chat.title : "", 18, true )
                else
                    return emojis.textToEmojiText( user? user.firstName + " " + user.lastName : "", 18, true )
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: currentDialog.encrypted? Cutegram.currentTheme.headerSecretDateColor : Cutegram.currentTheme.headerDateColor
            font.pixelSize: Math.floor( (currentDialog.encrypted? Cutegram.currentTheme.headerSecretDateFont.pointSize : Cutegram.currentTheme.headerDateFont.pointSize)*Devices.fontDensity)
            font.family: currentDialog.encrypted? Cutegram.currentTheme.headerSecretDateFont.family : Cutegram.currentTheme.headerDateFont.family
            visible: currentDialog != telegramObject.nullDialog && user.id != telegramObject.cutegramId
            text: {
                var result = ""
                var list = currentDialog.typingUsers
                if( list.length == 0 ) {
                    if( isChat ) {
                        result += qsTr("%1 participants (%2 online)").arg(chat.participantsCount).arg(onlineCount)
                    } else {
                        switch(header.user.status.classType)
                        {
                        case typeUserStatusRecently:
                            result = qsTr("Recently")
                            break;
                        case typeUserStatusLastMonth:
                            result = qsTr("Last Month")
                            break;
                        case typeUserStatusLastWeek:
                            result = qsTr("Last Week")
                            break;
                        case typeUserStatusOnline:
                            result = qsTr("Online")
                            break;
                        case typeUserStatusOffline:
                            result = qsTr("%1 was online").arg(Cutegram.getTimeString(CalendarConv.fromTime_t(header.user.status.wasOnline)))
                            break;
                        }
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
        icon: lightIcons? "files/files-light.png" : "files/files.png"
        iconHeight: 18*Devices.density
        cursorShape: Qt.PointingHandCursor
        highlightColor: "#1f000000"
        onClicked: {
            if(currentDialog == telegramObject.nullDialog)
                return

            var dId = currentDialog.peer.chatId
            if(dId == 0)
                dId = currentDialog.peer.userId

            Tools.mkDir(telegramObject.downloadPath + "/" + dId)
            Qt.openUrlExternally(Devices.localFilesPrePath + telegramObject.downloadPath + "/" + dId)
        }
    }
}
