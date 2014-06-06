import QtQuick 2.0
import "sialan-bubbles"

Item {
    id: auth
    width: 100
    height: 62

    property bool start: false

    onStartChanged: {
        if( start )
            sbbls.start()
        else
            sbbls.end()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
    }

    SialanBubbles {
        id: sbbls
        anchors.fill: parent
        opacity: 0.8
    }

    Image {
        id: sialan_img
        x: parent.width/2 - width/2
        y: parent.height/2 - height/2
        width: 128
        height: width
        sourceSize: Qt.size(width,height)
        source: "files/sialan.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Text {
        id: slogo_txt
        anchors.horizontalCenter: sialan_img.horizontalCenter
        anchors.top: sialan_img.bottom
        anchors.topMargin: 10
        text: "SIALAN LABS"
        font.weight: Font.Bold
        font.family: globalNormalFontFamily
        font.pointSize: 30
        color: "#333333"
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: website.top
        anchors.margins: 8
        font.family: globalNormalFontFamily
        font.pointSize: 10
        color: "#333333"
        text: "SialanLabs twitter"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: Gui.openUrl("https://twitter.com/SialanLabs")
        }
    }

    Text {
        id: website
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        font.family: globalNormalFontFamily
        font.pointSize: 10
        color: "#333333"
        text: "Sialan labs website"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: Gui.openUrl("http://labs.sialan.org")
        }
    }
}
