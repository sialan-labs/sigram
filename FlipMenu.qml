import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: flip_menu
    width: 100
    height: 62
    visible: false

    property bool start

    onStartChanged: {
        if( start ) {
            flip_menu.visible = true
        } else {
            frame.width = 0
            item_destroyer.restart()
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
        onClicked: flip_menu.hide()
    }

    QtObject {
        id: privates
        property variant item

        onItemChanged: {
            if( item ) {
                item.parent = back_frame
                frame.width = item.width + 2*back_frame.anchors.margins
                item.anchors.top = back_frame.top
                item.anchors.bottom = back_frame.bottom
            } else {
                flip_menu.visible = false
            }
        }
    }

    Timer {
        id: item_destroyer
        interval: 350
        repeat: false
        onTriggered: if( privates.item ) privates.item.destroy()
    }

    Rectangle {
        anchors.fill: parent
        color: "#66000000"
        opacity: flip_menu.start? 1 : 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: item_destroyer.interval }
        }
    }

    Item {
        id: frame
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        clip: true

        Behavior on width {
            NumberAnimation{ easing.type: Easing.OutBack; duration: item_destroyer.interval }
        }

        FastBlur {
            width: chatFrame.width
            height: chatFrame.height
            anchors.top: parent.top
            anchors.right: parent.right
            source: chatFrame
            radius: 64
            cached: true
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            hoverEnabled: true
            onWheel: wheel.accepted = true
        }

        Rectangle {
            anchors.fill: parent
            color: imageBack? "#88ffffff" : "#d9d9d9"
        }

        Item {
            id: back_frame
            anchors.fill: parent
            anchors.margins: 0
        }
    }

    function show( component ) {
        privates.item = component.createObject(back_frame)
        start = true
        return privates.item
    }

    function hide() {
        start = false
    }
}
