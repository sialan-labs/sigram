import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    id: message_action
    width: 100
    height: column.height

    property Message message
    property MessageAction action: message.action
    property User user: telegramObject.user(action.userId)
    property User fromUser: telegramObject.user(message.fromId)
    property FileLocation imgLocation: action.photo.sizes.first? action.photo.sizes.first.location : telegramObject.nullLocation

    property real typeMessageActionEmpty: 0xb6aef7b0
    property real typeMessageActionChatDeletePhoto: 0x95e3fbef
    property real typeMessageActionChatCreate: 0xa6638b9a
    property real typeMessageActionChatEditTitle: 0xb5a1ce5a
    property real typeMessageActionChatEditPhoto: 0x7fcb13a8
    property real typeMessageActionGeoChatCreate: 0x6f038ebc
    property real typeMessageActionChatDeleteUser: 0xb2ae9b0c
    property real typeMessageActionChatAddUser: 0x5e3cfc4b
    property real typeMessageActionGeoChatCheckin: 0xc7d53de

    property bool hasAction: action.classType != typeMessageActionEmpty

    onImgLocationChanged: {
        if(imgLocation == telegramObject.nullLocation)
            return

        telegramObject.getFile(imgLocation)
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: hasAction

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            color: "#333333"
            textFormat: Text.RichText
            text: {
                var res = ""
                var userName
                var fromUserName = fromUser.firstName + " " + fromUser.lastName
                fromUserName = fromUserName.trim()

                switch(action.classType) {
                case typeMessageActionChatCreate:
                    res = qsTr("%1 created the group \"%2\"").arg(fromUserName).arg(action.title)
                    break

                case typeMessageActionChatAddUser:
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    res = qsTr("%1 added %2 to group").arg(fromUserName).arg(userName)
                    break

                case typeMessageActionChatDeleteUser:
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    if(user.id == fromUser.id)
                        res = qsTr("%1 left the group").arg(userName)
                    else
                        res = qsTr("%1 kicked %2").arg(fromUserName).arg(userName)
                    break;

                case typeMessageActionChatEditTitle:
                    res = qsTr("%1 changed group name to \"%2\"").arg(fromUserName).arg(action.title)
                    break

                case typeMessageActionChatEditPhoto:
                    res = qsTr("%1 changed group photo.").arg(fromUserName)
                    break

                case typeMessageActionChatDeletePhoto:
                    res = qsTr("%1 deleted group photo").arg(fromUserName)
                    break

                case typeMessageActionEmpty:
                default:
                    break
                }

                return emojis.textToEmojiText(res, 16, true)
            }
        }

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 64*Devices.density
            height: 80*Devices.density
            sourceSize: Qt.size(width,width)
            source: {
                if(imgPath.length==0)
                    return ""
                else
                    return imgPath
            }
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            visible: imgPath.length != 0

            property string imgPath: imgLocation!=telegramObject.nullLocation? imgLocation.download.location : ""
        }
    }
}
