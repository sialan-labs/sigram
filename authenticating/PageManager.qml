import QtQuick 2.4
import AsemanTools 1.0
import QtGraphicalEffects 1.0

Item {
    id: page_manager

    property variant components: new Array
    onComponentsChanged: clean()

    property int index: -1

    onIndexChanged: {
        if(index >= components.length || index<0)
            return

        if(index > prv.lastIndex) {
            while(index >= list.count) {
                var component = components[list.count]
                var item = item_component.createObject(scene, {"delegate": component, "index": list.count})
                list.append(item)
            }
        } else {
            for(var i=index+1; i<list.count; i++) {
                var obj = list.takeAt(i)
                Tools.jsDelayCall(400, obj.destroy)
                i--
            }
            list.last().object.forceActiveFocus()
        }
        prv.lastIndex = index
    }

    ListObject {
        id: list
    }

    QtObject {
        id: prv
        property int lastIndex: -1
    }

    Item {
        id: scene
        anchors.fill: parent
        clip: true
    }

    function clean() {
        while(list.count)
            list.takeFirst().destroy()
    }

    function getItem(idx) {
        return list.at(idx).object
    }

    Component {
        id: item_component
        Item {
            id: item
            width: page_manager.width
            height: page_manager.height
            opacity: ratio==1? 1 : ratio/2

            Behavior on opacity {
                NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
            }

            property Component delegate
            property int index
            property Item object

            property real ratio: {
                if(prv.lastIndex<index)
                    return 0
                else
                if(prv.lastIndex == index)
                    return 1
                else
                    return 1-(prv.lastIndex-index)/components.length
            }

            transform: Scale {
                origin.x: item.width*1.1
                origin.y: item.height*0.5
                xScale: prv.lastIndex<index? 2 : item.ratio*0.8+0.2
                yScale: xScale

                Behavior on xScale {
                    NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
                }
            }

            Item {
                id: objectScene
                anchors.fill: parent
                opacity: prv.lastIndex>item.index? 0 : 1
                Behavior on opacity {
                    NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
                }
            }

            FastBlur {
                anchors.fill: parent
                source: objectScene
                radius: 32
                opacity: 1-objectScene.opacity
            }

            NullMouseArea {
                anchors.fill: parent
                visible: prv.lastIndex != item.index
            }

            Component.onCompleted: {
                object = delegate.createObject(objectScene)
                object.anchors.fill = objectScene
                if(index != 0)
                    object.forceActiveFocus()
            }
        }
    }
}

