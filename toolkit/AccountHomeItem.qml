import QtQuick 2.4
import AsemanTools 1.0

Rectangle {
    id: accHomeItem
    width: parent.width
    height: parent.height
    opacity: opened? 1 : 0
    visible: opacity != 0
    x: {
        if(type < currentType)
            return -50*Devices.density
        else
        if(type == currentType)
            return 0
        else
            return 50*Devices.density
    }

    signal init()

    Behavior on opacity {
        NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
    }
    Behavior on x {
        NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
    }

    readonly property bool opened: type == currentType

    property int type: 0
    property int currentType: 0

    property Component delegate
    property Item item

    onVisibleChanged: {
        if(visible && !item && delegate) item = delegate.createObject(accHomeItem)
        if(!visible && item) item.destroy()
    }
}

