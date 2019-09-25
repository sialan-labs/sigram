import QtQuick 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import QtGraphicalEffects 1.0

Item {
    id: panel

    property Component delegate
    property bool opened: false

    property alias containsMouse: marea.containsMouse
    property alias transformOrigin: mainScene.transformOrigin

    onDelegateChanged: {
        if(mainScene.item)
            mainScene.item.destroy()
        refresh()
    }
    onOpenedChanged: {
        if(opened) {
            refresh()
            BackHandler.pushHandler(panel, function(){opened = false})
        } else {
            BackHandler.removeHandler(panel)
        }
    }

    Item {
        id: mainScene
        anchors.fill: parent
        scale: 0.9 + opacity*0.1
        opacity: opened? 1 : 0
        visible: opacity != 0

        property Item item

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 250}
        }

        NullMouseArea {
            id: marea
            anchors.fill: parent
        }

        DropShadow {
            anchors.fill: itemScene
            horizontalOffset: 1*Devices.density
            verticalOffset: 1*Devices.density
            radius: 8.0
            samples: 32
            color: "#40000000"
            source: itemScene
        }

        Item {
            id: itemScene
            anchors.fill: parent
        }
    }

    function refresh() {
        if(!opened || mainScene.item || !delegate)
            return

        mainScene.item = delegate.createObject(itemScene)
    }
}

