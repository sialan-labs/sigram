import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import "../awesome"
import "../toolkit" as ToolKit
import "messageitems" as MessageItems
import "../globals"

ToolKit.TgRectangle {
    id: fwdArea
    color: "#00000000"

    property alias messages: mlmodel.messageList
    property alias fromPeer: mlmodel.currentPeer

    property bool secondStep: false

    onCurrentPeerChanged: {
        if(messages.length) {
            secondStep = true
            BackHandler.removeHandler(fwdArea)
            BackHandler.pushHandler(fwdArea, discard)
        }
    }

    onMessagesChanged: {
        if(messages.length != 0) {
            BackHandler.pushHandler(fwdArea, discard)
        } else {
            BackHandler.removeHandler(fwdArea)
            secondStep = false
        }
    }

    Telegram.MessageListModel {
        id: mlmodel
        engine: fwdArea.engine
        dateConvertorMethod: function(date) {
            var hours = date.getHours()
            if(hours < 10)
                hours = "0" + hours

            var minutes = date.getMinutes()
            if(minutes < 10)
                minutes = "0" + minutes

            return hours + ":" + minutes
        }
    }

    NullMouseArea {
        anchors.fill: parent
        visible: mlmodel.messageList.length
    }

    Item {
        anchors.fill: parent
        opacity: mlmodel.messageList.length? 1 : 0
        visible: opacity != 0

        Behavior on opacity {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.8
        }

        Text {
            id: label
            anchors.centerIn: parent
            font.pixelSize: 15*Devices.fontDensity
            color: "#ffffff"
            text: qsTr("Choose a conversation")
            opacity: secondStep? 0 : 1

            Behavior on opacity {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
            }
        }

        Item {
            id: title_row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20*Devices.density
            height: 92*Devices.density
            opacity: secondStep? 1 : 0
            y: secondStep? 0 : -100*Devices.density

            Behavior on opacity {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
            }
            Behavior on y {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
            }

            Row {
                id: images_row
                spacing: 10*Devices.density
                anchors.verticalCenter: parent.verticalCenter

                ToolKit.ProfileImage {
                    engine: fwdArea.engine
                    source: fwdArea.fromPeer
                    anchors.verticalCenter: parent.verticalCenter
                    height: 48*Devices.density
                    width: height
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ffffff"
                    font.pixelSize: 20*Devices.fontDensity
                    font.family: Awesome.family
                    text: Awesome.fa_angle_right + Awesome.fa_angle_right + Awesome.fa_angle_right
                }

                ToolKit.ProfileImage {
                    engine: fwdArea.engine
                    source: fwdArea.currentPeer
                    anchors.verticalCenter: parent.verticalCenter
                    height: 48*Devices.density
                    width: height
                }
            }

            Button {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                height: images_row.height
                width: height
                normalColor: "#00000000"
                highlightColor: "#88000000"
                hoverColor: "#55000000"
                textColor: "#ffffff"
                radius: 4*Devices.density
                textFont.family: Awesome.family
                textFont.pixelSize: 16*Devices.fontDensity
                text: Awesome.fa_close
                onClicked: discard()
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height - title_row.height
            opacity: secondStep? 1 : 0

            Behavior on opacity {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
            }

            ListView {
                id: listv
                clip: true
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 80*Devices.density
                height: parent.height
                y: secondStep? 0 : 100*Devices.density
                verticalLayoutDirection: ListView.BottomToTop

                Behavior on y {
                    NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
                }

                model: mlmodel
                maximumFlickVelocity: View.flickVelocity
                boundsBehavior: Flickable.StopAtBounds
                rebound: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 0
                    }
                }
                delegate: MessageListDelegate {
                    width: listv.width
                    maximumHeight: listv.height*0.4
                    maximumWidth: listv.width*0.7
                    messagesModel: mlmodel
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            NormalWheelScroll {
                flick: listv
            }

            PhysicalScrollBar {
                anchors.left: listv.right
                anchors.leftMargin: 20*Devices.density
                height: listv.height
                width: 6*Devices.density
                color: "#888888"
                scrollArea: listv
            }
        }
    }

    function discard() {
        fromPeer = null
        messages = new Array
    }
}

