import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.0

Item {
    width: 100
    height: 62*Devices.density

    property alias filePath: player.source

    DropShadow {
        anchors.fill: play_btn_scene
        radius: 4.0
        samples: 16
        color: play_marea.containsMouse? masterPalette.highlight : "#80000000"
        source: play_btn_scene
    }

    MediaPlayer {
        id: player
        autoLoad: false
    }

    Item {
        id: play_btn_scene
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height

        Rectangle {
            id: play_btn
            anchors.fill: parent
            anchors.margins: 3*Devices.density
            radius: width/2
            color: "#ffffff"
        }

        MouseArea {
            id: play_marea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if(player.playbackState == MediaPlayer.PlayingState)
                    player.pause()
                else
                    player.play()
            }
        }
    }

    Canvas {
        id: play_item
        anchors.centerIn: play_btn_scene
        width: height
        height: play_btn_scene.height*0.35
        visible: player.playbackState != MediaPlayer.PlayingState
        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.fillStyle = "#777777"
            ctx.beginPath();

            var r = height-height*Math.pow(3/4, 0.5)

            ctx.moveTo(r,0)
            ctx.lineTo(width,height/2)
            ctx.lineTo(r,height)
            ctx.lineTo(r,0)

            ctx.stroke()
            ctx.fill()
        }
    }

    Row {
        anchors.centerIn: play_btn_scene
        width: height
        height: play_btn_scene.height*0.35
        visible: player.playbackState == MediaPlayer.PlayingState
        spacing: width/4

        Rectangle {height: parent.height; width: parent.width/2.7; color: masterPalette.highlight}
        Rectangle {height: parent.height; width: parent.width/2.7; color: masterPalette.highlight}
    }

    Rectangle {
        id: seeker_scene
        anchors.left: play_btn_scene.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4*Devices.density
        height: 6*Devices.density
        radius: 2*Devices.density
        color: "#555555"

        Rectangle {
            anchors.left: parent.left
            anchors.right: seeker.horizontalCenter
            height: parent.height
            radius: parent.radius
            color: masterPalette.highlight
        }

        Rectangle {
            id: seeker
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height*3
            width: height
            radius: width/2
            color: "#ffffff"
            border.color: "#aaaaaa"
            border.width: 1*Devices.density
            x: (seeker_scene.width-seeker.width)*player.position/player.duration
        }
    }

    MouseArea {
        anchors.left: seeker_scene.left
        anchors.right: seeker_scene.right
        height: seeker.height
        anchors.verticalCenter: seeker_scene.verticalCenter
        cursorShape: Qt.PointingHandCursor
        onMouseXChanged: player.seek((mouseX-seeker.width/2)*player.duration/(seeker_scene.width-seeker.width))
    }
}

