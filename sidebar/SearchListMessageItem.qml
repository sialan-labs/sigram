import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    id: item
    height: 64*Devices.density
    width: parent.width

    property alias engine: avatar.engine

    signal loadRequest(variant peer, variant message)

    Row {
        id: row
        width: parent.width - 20*Devices.density
        anchors.centerIn: parent
        spacing: 6*Devices.density

        ToolKit.ProfileImage {
            id: avatar
            height: 42*Devices.density
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: model.fromUserItem
        }

        Item {
            width: row.width - avatar.width - row.spacing
            height: 24*Devices.density
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.left: parent.left
                anchors.right: date_txt.left
                anchors.rightMargin: 10*Devices.density
                anchors.verticalCenter: parent.top
                font.pixelSize: 9*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 2
                color: "#333333"
                text: {
                    var chat = model.toChatItem? model.toChatItem.title : ""
                    var user = model.fromUserItem? (model.fromUserItem.firstName + " " + model.fromUserItem.lastName).trim() : ""

                    var result
                    if(chat.length != 0)
                        result = chat + "\n" + user
                    else
                        result = user
                    return CutegramEmojis.parse(result)
                }
            }

            Text {
                id: date_txt
                anchors.right: parent.right
                anchors.verticalCenter: parent.top
                font.pixelSize: 9*Devices.fontDensity
                color: "#666666"
                text: model.dateTime
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 10*Devices.density
                anchors.verticalCenter: parent.bottom
                font.pixelSize: 9*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                color: "#666666"
                text: model.message
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: loadRequest(model.toPeerItem, model.item)
    }
}

