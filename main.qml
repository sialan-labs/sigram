import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Window {
    id: main
    visible: true
    width: 1024
    height: 600

    property real physicalPlatformScale: 1
    property real fontsScale: 1
    property string globalFontFamily

    property alias current: chat_frame.current
    property bool configure: false
    property bool about: false

    property alias focus: main_frame.focus

    About {
        anchors.fill: parent
        color: "#0d80ec"
    }

    Rectangle {
        id: main_frame
        y: about? main.height : 0
        width: parent.width
        height: parent.height
        color: "#4098BF"

        Keys.onEscapePressed: {
            if( about )
                about = false
            else
            if( configure )
                configure = false
        }

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Configure {
            id: confg
            width: 273
            height: parent.height
            x: configure? 0 : -width/3

            Behavior on x {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
        }

        Rectangle {
            id: shadow
            x: chat_frame.x
            y: chat_frame.y
            width: chat_frame.height
            height: 15*physicalPlatformScale
            rotation: 90
            transformOrigin: Item.TopLeft
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }

        ChatFrame {
            id: chat_frame
            x: configure? 273 : 0
            width: parent.width
            height: parent.height

            Behavior on x {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                visible: main.configure
                onClicked: main.configure = false
            }
        }

        Desaturate {
            id: main_desaturate
            anchors.fill: chat_frame
            source: chat_frame
            visible: false
            desaturation: 0.8
            cached: true
        }

        FastBlur {
            anchors.fill: main_desaturate
            source: main_desaturate
            radius: 16
            visible: opacity != 0
            opacity: main.configure? 1 : 0
            cached: true
            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
        }
    }
}
