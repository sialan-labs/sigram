import QtQuick 2.1
import QtQuick.Controls.Styles 1.1
import QtGraphicalEffects 1.0

ProgressBarStyle {

    property color backgroundColor: Qt.darker(masterPalette.window, 1.2)
    property color highlightColor: masterPalette.highlight

    SystemPalette {
        id: masterPalette
    }

    background: Item {
        implicitWidth: 100
        implicitHeight: 30

        Item {
            id: frame
            anchors.fill: parent
            anchors.margins: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 5
                color: backgroundColor
            }
        }

        InnerShadow {
            anchors.fill: source
            source: frame
            radius: 4.0
            samples: 16
            horizontalOffset: 0
            verticalOffset: 1
            opacity: control.pressed? 0.8 : 0.3
            color: "#000000"
        }
    }

    progress: Item {
        Item {
            id: pframe
            anchors.fill: parent
            anchors.margins: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 5
                color: highlightColor
            }

            RadialGradient {
                width: parent.width*0.9
                height: parent.height*0.8
                anchors.verticalCenter: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.6
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ffffff" }
                    GradientStop { position: 0.5; color: "#00000000" }
                }
            }

            RadialGradient {
                width: parent.width*0.9
                height: parent.height*0.8
                anchors.verticalCenter: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.6
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ffffff" }
                    GradientStop { position: 0.5; color: "#00000000" }
                }
            }
        }

        InnerShadow {
            anchors.fill: source
            source: pframe
            radius: 2.0
            samples: 16
            color: "#888888"
        }
    }
}
