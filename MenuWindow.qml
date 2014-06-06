import QtQuick 2.0
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Item {
    id: menu_win
    width: 300
    height: 400
    visible: menu_frame.opacity != 0

    property bool started: false
    property variant item

    property real shadowSize: 42

    property int duration: 350

    onItemChanged: {
        if( privates.oldItem )
            privates.oldItem.destroy()
        if( item ) {
            item.parent = menu_items_parent
            item.anchors.fill = menu_items_parent
        }

        privates.oldItem = item
    }

    QtObject {
        id: privates
        property variant oldItem
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
        onClicked: menu_win.stop()
    }

    Item {
        id: menu_frame
        x: 200
        y: 200
        width: 200
        height: 300
        transformOrigin: Item.Top
        scale: menu_win.started? 1 : 0.1
        opacity: menu_win.started? 1 : 0


        Behavior on scale {
            NumberAnimation{ easing.type: Easing.OutBack; duration: menu_win.duration }
        }
        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: menu_win.duration }
        }

        DropShadow {
            anchors.fill: menu_item
            radius: shadowSize
            samples: 32
            cached: true
            spread: 0.5
            color: "#44000000"
            source: menu_item
        }

        Image {
            width: 32
            height: 18
            anchors.horizontalCenter: menu_item.horizontalCenter
            anchors.bottom: menu_item.top
            anchors.bottomMargin: -shadowSize
            sourceSize: Qt.size(width,height)
            source: "files/pointer.png"
        }

        Item {
            id: menu_item
            anchors.fill: parent
            anchors.margins: -shadowSize

            Rectangle {
                id: menu_main_item
                anchors.fill: parent
                anchors.margins: shadowSize
                color: "#ffffff"
                radius: 3
            }
        }

        Item {
            id: menu_items_parent
            anchors.fill: parent
        }
    }

    Timer {
        id: obj_destroyer
        interval: menu_win.duration
        repeat: false
        onTriggered: if( menu_win.item ) menu_win.item.destroy()
    }

    function start( component, x, y, w, h ) {
        var sz = Gui.screenSize()
        menu_win.width = sz.width
        menu_win.height = sz.height

        menu_frame.width = w
        menu_frame.height = y+h+shadowSize>height? height-y-shadowSize : h
        menu_frame.x = x - 1*menu_frame.width/2
        menu_frame.y = y
        item = component.createObject(menu_items_parent)
        started = true

        return item
    }

    function stop() {
        started = false
        obj_destroyer.restart()
    }
}
