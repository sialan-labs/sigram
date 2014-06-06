import QtQuick 2.0

Rectangle {
    width: 100
    height: 62

    gradient: Gradient {
        GradientStop { position: 0.00; color: "#33b7cc" }
        GradientStop { position: 0.35; color: "#33b7cc" }
        GradientStop { position: 0.65; color: "#33ccad" }
        GradientStop { position: 1.00; color: "#33ccad" }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Image {
            id: icon
            sourceSize: Qt.size(width,height)
            width: 128
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "files/about_icon.png"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sigram")
            font.pointSize: 30
            font.weight: Font.Light
            font.family: globalNormalFontFamily
            color: "#ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("A different telegram client from Sialan.Labs")
            font.pointSize: 16
            font.weight: Font.Light
            font.family: globalNormalFontFamily
            color: "#ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sigram project are released under the terms of the GPLv3 license.")
            font.pointSize: 9
            font.weight: Font.Light
            font.family: globalNormalFontFamily
            color: "#ffffff"
        }

        Image {
            id: sialan_logo
            sourceSize: Qt.size(width,height)
            width: 128
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "files/sialan_logo.png"
        }
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        font.family: globalNormalFontFamily
        font.pointSize: 10
        color: "#ffffff"
        text: "version 0.5"
    }
}
