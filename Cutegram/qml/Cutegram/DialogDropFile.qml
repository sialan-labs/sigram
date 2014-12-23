import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Item {
    id: am_dropfile
    width: 100
    height: 62

    property Dialog currentDialog
    property bool isChat: currentDialog? currentDialog.peer.chatId != 0 : false

    property alias color: back.color
    property real visibleRatio: drop_area.containsDrag && currentDialog != telegramObject.nullDialog? 1 : 0

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
            border.color: masterPalette.highlight
            border.width: 2*Devices.density
            radius: 3*Devices.density
            color: "#00000000"
        }

        Text {
            anchors.centerIn: parent
            font.family: AsemanApp.globalFontFamily
            font.pixelSize: 12*Devices.fontDensity
            color: masterPalette.highlight
            text: qsTr("Drop files here to send")
        }
    }

    DropArea {
        id: drop_area
        anchors.fill: parent
        onDropped: {
            if( currentDialog == telegramObject.nullDialog )
                return

            var dId = isChat? currentDialog.peer.chatId : currentDialog.peer.userId
            if( drop.hasUrls ) {
                var urls = drop.urls
                for( var i=0; i<urls.length; i++ )
                    telegramObject.sendFile(dId, urls[i])
            }
            else
            if( drop.hasText ) {

            }
        }
    }
}
