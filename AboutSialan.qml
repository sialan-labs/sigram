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
        x: parent.width/2 - width/2
        y: parent.height/2 - height/2
        width: 128
        height: width
        sourceSize: Qt.size(width,height)
        source: "files/sialan.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
