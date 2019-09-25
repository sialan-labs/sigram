import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0
import TelegramQml 2.0 as Telegram
import QtQuick 2.4
import QtGraphicalEffects 1.0
import "../globals"
import "../awesome"

Item {
    height: listv.contentHeight + listv.anchors.topMargin*2

    property ProfileManagerModel profileManager
    property alias currentIndex: listv.currentIndex

    signal closeRequest()

    AsemanListView {
        id: listv
        anchors.fill: parent
        anchors.topMargin: 4*Devices.density
        anchors.bottomMargin: anchors.topMargin
        model: profileManager
        clip: true
        onCountChanged: currentIndex = count-1
        delegate: Item {
            id: item
            width: listv.width
            height: 60*Devices.density

            property User user: {
                var userFull = model.engine.our
                if(!userFull) return null
                return userFull.user
            }

            Rectangle {
                anchors.fill: parent
                color: CutegramGlobals.baseColor
                opacity: marea.pressed? 0.1 : 0
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14*Devices.density
                spacing: 8*Devices.density

                ProfileImage {
                    width: 42*Devices.density
                    height: width
                    source: item.user
                    engine: model.engine
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4*Devices.density

                    Text {
                        font.pixelSize: 10*Devices.fontDensity
                        color: "#333333"
                        text: {
                            if(model.phoneNumber.length == 0) return qsTr("New Account")
                            if(!item.user) return ""
                            return (item.user.firstName + " " + item.user.lastName).trim()
                        }
                    }

                    Text {
                        font.pixelSize: 9*Devices.fontDensity
                        color: "#666666"
                        text: model.phoneNumber
                    }
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    currentIndex = index
                    closeRequest()
                }
            }
        }

        footer: Item {
            width: listv.width
            height: 60*Devices.density

            Rectangle {
                anchors.fill: parent
                color: CutegramGlobals.baseColor
                opacity: marea.pressed? 0.1 : 0
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14*Devices.density
                spacing: 8*Devices.density

                Rectangle {
                    width: 42*Devices.density
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    radius: width/2
                    color: "#959595"

                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16*Devices.fontDensity
                        font.family: Awesome.family
                        text: Awesome.fa_plus
                        color: "#ffffff"
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#555555"
                    text: qsTr("Add Account")
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    profileManager.addNew()
                    closeRequest()
                }
            }
        }
    }
}

