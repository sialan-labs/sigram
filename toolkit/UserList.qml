import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

AsemanListView {
    id: listv

    property variant engine

    signal peerSelected(variant peer)

    delegate: Rectangle {
        id: item
        width: listv.width
        height: 56*Devices.density
        color: marea.pressed? "#11000000" : "#00000000"

        Row {
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6*Devices.density

            Column {
                width: 18*Devices.density
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Awesome.family
                    font.pixelSize: 12*Devices.fontDensity
                    color: "#666666"
                    text: {
                        switch(model.type)
                        {
                        case Telegram.MembersListModel.TypeAdmin:
                        case Telegram.MembersListModel.TypeCreator:
                            return Awesome.fa_key
                        case Telegram.MembersListModel.TypeModerator:
                            return Awesome.fa_black_tie
                        case Telegram.MembersListModel.TypeEditor:
                            return Awesome.fa_pencil
                        case Telegram.MembersListModel.TypeKicked:
                            return Awesome.fa_ban
                        case Telegram.MembersListModel.TypeNormal:
                        case Telegram.MembersListModel.TypeSelf:
                        case Telegram.MembersListModel.TypeUnknown:
                        default:
                            return " "
                        }
                    }
                }
            }

            Rectangle {
                id: avatar
                height: item.height - 8*Devices.density
                width: height
                anchors.verticalCenter: parent.verticalCenter
                color: "#00000000"
                radius: width/2
                border.width: 1*Devices.density
                border.color: model.isOnline? "#75CB46" : "#00000000"

                ToolKit.ProfileImage {
                    id: img
                    anchors.fill: parent
                    anchors.margins: 3*Devices.density
                    source: model.user
                    engine: listv.engine
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                width: row.width - avatar.width - row.spacing
                height: 20*Devices.density
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    width: parent.width
                    anchors.verticalCenter: parent.top
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: 10*Devices.fontDensity
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    color: "#333333"
                    text: (model.user.firstName + " " + model.user.lastName).trim()
                }

                Text {
                    width: parent.width
                    anchors.verticalCenter: parent.bottom
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#666666"
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    text: model.status
                }
            }
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            onClicked: listv.peerSelected(model.peer)
        }
    }
}
