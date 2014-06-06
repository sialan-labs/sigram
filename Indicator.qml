import QtQuick 2.0

Item {
    id: indicator

    property real indicatorSize: 22
    property string source: imageBack? "files/indicator_light.png" : "files/indicator.png"

    QtObject {
        id: privates
        property variant item
    }

    Component {
        id: img_indicator
        Image {
            id: indict_img
            width: indicator.indicatorSize
            height: width
            anchors.centerIn: parent
            source: indicator.source
            smooth: true
            transformOrigin: Item.Center

            Behavior on rotation {
                NumberAnimation{ easing.type: Easing.Linear; duration: indict_img_timer.interval }
            }

            Timer {
                id: indict_img_timer
                interval: 250
                repeat: true
                triggeredOnStart: true
                onTriggered: indict_img.rotation += 90
                Component.onCompleted: start()
            }
        }
    }

    function start() {
        if( privates.item )
            return

        privates.item = img_indicator.createObject(indicator)
    }

    function stop() {
        if( !privates.item )
            return

        privates.item.destroy()
    }
}
