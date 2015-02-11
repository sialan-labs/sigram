import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: Desktop.titleBarColor

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4*Devices.density

        Image {
            id: logo_img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 192
            height: width
            sourceSize: Qt.size(width,height)
            source: "files/icon.png"
        }

        Text {
            id: cutegram_txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 30*Devices.fontDensity
            color: Desktop.titleBarTextColor
            text: "Cutegram"
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40*Devices.density
            anchors.rightMargin: 40*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Desktop.titleBarTextColor
            text: qsTr("Cutegram is a telegram client by Aseman. It's free and opensource and released "+
                       "under GPLv3 license.")
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40*Devices.density
            anchors.rightMargin: 40*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Desktop.titleBarTextColor
            text: qsTr("Cutegram using Qt5, QML, libqtelegram, libappindicator, AsemanQtTools, some KDE tools, Faenza icons and Twitter emojies.")
        }

        Item { width: 4; height: 10*Devices.density }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Home Page")
            radius: 4*Devices.density
            onClicked: Qt.openUrlExternally("http://aseman.co/en/projects/cutegram")
            normalColor: Cutegram.highlightColor
            highlightColor: Qt.darker(Cutegram.highlightColor)
            textColor: masterPalette.highlightedText
            width: 120*Devices.density
            height: 40*Devices.density
        }
    }

    AsemanLogo {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        height: 30*Devices.density
        dark: !Desktop.titleBarIsDark

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
        color: Desktop.titleBarTextColor
        text: AsemanApp.applicationVersion
    }

    Header {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        light: Desktop.titleBarIsDark
    }
}

