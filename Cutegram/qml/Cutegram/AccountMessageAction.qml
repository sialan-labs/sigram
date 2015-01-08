import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: message_action
    width: 100
    height: column.height

    property Message message
    property MessageAction action: message.action
    property User user: telegramObject.user(action.userId)
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
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 9*Devices.fontDensity
            color: "#333333"
            text: {
                var res = ""
                var userName
                switch(action.classType) {
                case typeMessageActionChatCreate:
                {
                    var users = Cutegram.intListToVariantList(action.users)
                    var userObj = user
                    if(users.length != 0) {
                        userObj = telegramObject.user(users[0])
                    }

                    userName = userObj.firstName + " " + userObj.lastName
                    userName = userName.trim()

                    res = qsTr("%1 created the group \"%2\"").arg(userName).arg(action.title)
                }
                    break

                case typeMessageActionChatAddUser:
                {
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    res = qsTr("%1 invited someone to group").arg(userName)
                }
                    break

                case typeMessageActionChatDeleteUser:
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    res = qsTr("%1 left the group").arg(userName)
                    break;

                case typeMessageActionChatEditTitle:
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    res = qsTr("%1 changed group name to \"%2\"").arg(userName).arg(action.title)
                    break

                case typeMessageActionChatEditPhoto:
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    res = qsTr("%1 changed group photo.").arg(userName)
                    break

                case typeMessageActionChatDeletePhoto:
                    userName = user.firstName + " " + user.lastName
                    userName = userName.trim()

                    res = qsTr("%1 deleted group photo").arg(userName)
                    break

                case typeMessageActionEmpty:
                default:
                    break
                }

                return res
            }
        }


        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(width,height)
            source: {
                if(imgPath.length==0)
                    return ""
                else
                    return "file://" + imgPath
            }
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            visible: imgPath.length != 0

            property string imgPath: imgLocation!=telegramObject.nullLocation? imgLocation.download.location : ""
        }
    }
}
