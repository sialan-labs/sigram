import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: am_dropfile
    width: 100
    height: 62

    property bool containsDrag: drop_area.containsDrag && dialogItem != telegramObject.nullDialog

    property Dialog dialogItem
    property Dialog currentDialog: telegramObject.nullDialog
    property bool isChat: dialogItem? dialogItem.peer.chatId != 0 : false

    property alias color: back.color
    property real visibleRatio: containsDrag? 1 : 0

    signal dropped()

    Behavior on visibleRatio {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    Rectangle {
        id: back
        anchors.fill: parent
        color: "#66ffffff"
        opacity: visibleRatio

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6*Devices.density
            border.color: Cutegram.highlightColor
            border.width: 2*Devices.density
            radius: 3*Devices.density
            color: "#00000000"
        }

        Text {
            anchors.centerIn: parent
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 12*Devices.fontDensity
            color: Cutegram.highlightColor
            text: qsTr("Drop files here to send")
        }
    }

    DropArea {
        id: drop_area
        anchors.fill: parent
        onDropped: {
            if( dialogItem == telegramObject.nullDialog )
                return

            var dId = isChat? dialogItem.peer.chatId : dialogItem.peer.userId
            if( drop.formats.indexOf("land.aseman.cutegram/messageId") != -1 ) {
                if(currentDialog == dialogItem)
                    return

                var msgId = drop.getDataAsString("land.aseman.cutegram/messageId")
                telegramObject.forwardMessage(msgId, dId)
                am_dropfile.dropped()
            }
            else
            if( drop.hasUrls ) {
                var urls = drop.urls
                for( var i=0; i<urls.length; i++ )
                    telegramObject.sendFile(dId, urls[i])

                am_dropfile.dropped()
            }
            else
            if( drop.hasText ) {
                telegramObject.sendMessage(dId, drop.text)
                am_dropfile.dropped()
            }
        }
    }
}
