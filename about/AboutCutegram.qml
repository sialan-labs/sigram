import QtQuick 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import Cutegram 3.0
import "../globals"

Rectangle {
    width: 100
    height: 62
    color: "#eeeeee"

    WindowDragArea {
        anchors.fill: parent
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: cblist.left
        spacing: 4*Devices.density

        Image {
            id: logo_img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 192
            height: width
            sourceSize: Qt.size(width,height)
            source: "icon.png"
        }

        Text {
            id: cutegram_txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(30*Devices.fontDensity)
            color: "#333333"
            text: "Cutegram"
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40*Devices.density
            anchors.rightMargin: 40*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#333333"
            text: qsTr("Cutegram is a Telegram client by Aseman. It's free, open source and released under the GPLv3 license.")
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40*Devices.density
            anchors.rightMargin: 40*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#333333"
            text: qsTr("Cutegram uses Qt5, QML, libqtelegram, libappindicator, AsemanQtTools, some KDE tools, Faenza icons and Twitter emojis.")
        }

        Item { width: 4; height: 10*Devices.density }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Home Page")
            radius: 4*Devices.density
            onClicked: Qt.openUrlExternally("http://aseman.co/en/projects/cutegram")
            normalColor: CutegramGlobals.highlightColors
            highlightColor: Qt.darker(normalColor)
            textColor: "#ffffff"
            width: 120*Devices.density
            height: 40*Devices.density
        }
    }

    ContributorsList {
        id: cblist
        anchors.right: parent.right
        width: 400*Devices.density
        height: parent.height


        Rectangle {
            y: -height
            width: parent.height
            height: 6*Devices.density
            rotation: 90
            transformOrigin: Item.BottomLeft
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#000000" }
            }
        }
    }

    AsemanLogo {
        anchors.right: cblist.left
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        height: 30*Devices.density
        dark: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("http://aseman.co")
        }
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        font: AsemanApp.globalFont
        color: "#333333"
        text: AsemanApp.applicationVersion
    }

    Header {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        light: false
    }
}

