import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

TabViewStyle {
    frameOverlap: 1

    SystemPalette {
        id: masterPalette
    }

    tabBar: Item {
        Rectangle {
            width: parent.width
            height: 16
            anchors.bottom: parent.bottom
            color: Qt.darker(masterPalette.window, 1.1)

            Rectangle {
                anchors.fill: parent
                opacity: 0.1
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#000000" }
                    GradientStop { position: 0.15; color: "#00000000" }
                    GradientStop { position: 0.85; color: "#00000000" }
                    GradientStop { position: 1.00; color: "#000000" }
                }
            }
        }
    }

    tab: Item {
        implicitWidth: Math.max(text.width + 20, 80)
        implicitHeight: 60

        Text {
            id: text
            anchors.top: parent.top
            anchors.bottom: select_light.top
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            text: styleData.title
            color: styleData.hovered && !styleData.selected? Qt.darker(masterPalette.highlight,1.4) : masterPalette.windowText
            opacity: styleData.selected? 1 : 0.6
            font.pointSize: styleData.selected? 14 : 11
        }

        Item {
            id: select_light
            width: parent.width
            height: 16
            anchors.bottom: parent.bottom
            clip: true

            RadialGradient {
                width: 60
                height: parent.height*2
                anchors.verticalCenter: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                visible: styleData.selected
                opacity: 0.4
                gradient: Gradient {
                    GradientStop { position: 0.0; color: masterPalette.highlight }
                    GradientStop { position: 0.5; color: "#00000000" }
                }
            }
        }
    }

    frame: Item {
    }
}
