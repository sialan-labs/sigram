import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../../../thirdparty"
import "../../../globals"

AbstractMessage {
    id: msgItem
    width: area.width
    height: area.height - 20*Devices.density

    onCopyRequest: Devices.clipboard = txt.text

    readonly property string text: {
        if(!message) return ""
        var users

        switch(message.action.classType) {
        case Telegram.MessageAction.TypeMessageActionChatCreate:
            if(!user) return ""
            return qsTr("\"%1\" created the group \"%2\"").arg((user.firstName + " " + user.lastName).trim())
                                                          .arg(message.action.title)
        case Telegram.MessageAction.TypeMessageActionChatEditTitle:
            if(user)
                return qsTr("\"%1\" changed group name to \"%2\"").arg((user.firstName + " " + user.lastName).trim())
                                                                  .arg(message.action.title)
            else
                return qsTr("Channel title changed")
        case Telegram.MessageAction.TypeMessageActionChatEditPhoto:
            if(user)
                return qsTr("\"%1\" changed group photo").arg((user.firstName + " " + user.lastName).trim())
            else
                return qsTr("Channel photo changed")
        case Telegram.MessageAction.TypeMessageActionChatDeletePhoto:
            if(user)
                return qsTr("\"%1\" removed group photo").arg((user.firstName + " " + user.lastName).trim())
            else
                return qsTr("Channel photo deleted")
        case Telegram.MessageAction.TypeMessageActionChatAddUser:
            if(!user) return ""
            return qsTr("\"%1\" invited %2").arg((user.firstName + " " + user.lastName).trim()).arg(users)
        case Telegram.MessageAction.TypeMessageActionChatDeleteUser:
            if(!user) return ""
            return qsTr("\"%1\" removed %2").arg((user.firstName + " " + user.lastName).trim()).arg(users)
        case Telegram.MessageAction.TypeMessageActionChatJoinedByLink:
            return qsTr("\"%1\" joined by link").arg(users)
        case Telegram.MessageAction.TypeMessageActionChannelCreate:
            return qsTr("Channel created")
        case Telegram.MessageAction.TypeMessageActionChatMigrateTo:
            return qsTr("Chat migrate to channel")
        case Telegram.MessageAction.TypeMessageActionChannelMigrateFrom:
            return qsTr("Channel migrate from chat \"%1\"").arg(message.action.title)
        case Telegram.MessageAction.TypeMessageActionPinMessage:
            return qsTr("Message pinned")
        case Telegram.MessageAction.TypeMessageActionEmpty:
        default:
            return qsTr("Unsupported action occurred")
        }
    }

    Rectangle {
        id: area
        color: "#55000000"
        width: txt.width + 16*Devices.density
        height: txt.height + 16*Devices.density
        radius: 5*Devices.density
        anchors.centerIn: parent

        Text {
            id: txt
            anchors.centerIn: parent
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: 9*Devices.fontDensity
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "#ffffff"
            text: msgItem.text
        }
    }
}

