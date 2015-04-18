import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: msg_link
    width: 1<maximumMediaRatio? maximumMediaHeight : maximumMediaWidth
    height: 1<maximumMediaRatio? maximumMediaHeight : maximumMediaWidth

    property real maximumMediaRatio: maximumMediaWidth/maximumMediaHeight
    property string link
    property variant item

    onLinkChanged: {
        if(item)
            item.destroy()
        if(link.length != 0) {
            item = image_component.createObject(msg_link)
        }
    }

    Component {
        id: image_component
        Image {
            id: img
            anchors.fill: parent
            asynchronous: true
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectCrop

            property bool finished: false

            Component.onCompleted: {
                indicator.start()
                webPageGrabber.addToQueue(link, done)
            }

            Indicator {
                id: indicator
                anchors.fill: parent
                modern: true
                light: false
            }

            function done(path) {
                source = path
                indicator.stop()
                finished = true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(img.source)
            }
        }
    }
}

