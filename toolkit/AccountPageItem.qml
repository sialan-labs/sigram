import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0

Rectangle {
    id: accPageItem
    width: parent.width
    height: parent.height
    opacity: opened? 1 : 0
    visible: opacity != 0
    y: {
        if(type < currentType)
            return -100*Devices.density
        else
        if(type == currentType)
            return 0
        else
            return 100*Devices.density
    }

    signal init()

    Behavior on opacity {
        NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
    }
    Behavior on y {
        NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
    }

    readonly property bool opened: type == currentType

    property int type: 0
    property int currentType: 0

    property Component delegate
    property Item item

    onOpenedChanged: {
        if(opened && !item && delegate) item = delegate.createObject(accPageItem)
    }
}

