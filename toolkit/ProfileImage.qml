import QtQuick 2.4
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Item {
    property alias source: avatar_img.source
    property alias engine: avatar_img.engine
    property alias color: back.color
    property alias error: avatar_img.errorText

    Rectangle {
        id: avatar_mask
        anchors.fill: avatar_img
        radius: width/2
        visible: false
    }

    Telegram.Image {
        id: avatar_img
        width: parent.width*2
        height: parent.height*2
        source: privates.user
        engine: privates.engine
        smooth: true
        visible: false

        Rectangle {
            id: back
            anchors.fill: parent
            color: avatar_img.thumbnailDownloaded? "#00000000" : CutegramGlobals.baseColor

            Text {
                anchors.centerIn: parent
                font.pixelSize: back.height/2
                color: avatar_img.thumbnailDownloaded? "#00000000" : "#ffffff"
                font.family: Awesome.family
                text: Awesome.fa_user
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: avatar_img
        maskSource: avatar_mask
    }
}

