import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: pmanager
    clip: true

    property Component mainComponent
    property alias mainItem: scene.itemObject

    property int animationDuration: 400
    property int easingType: Easing.OutCubic
    property alias count: list.count

    property int layoutDirection: View.layoutDirection

    onMainComponentChanged: {
        if(mainItem)
            mainItem.destroy()

        mainItem = mainComponent.createObject(scene)
    }

    ListObject {
        id: list

        function lastItem() {
            if(count == 0)
                return scene
            else
                return last()
        }
    }

    Item {
        id: scene
        width: parent.width
        height: parent.height
        x: {
            switch(pmanager.layoutDirection) {
            case Qt.LeftToRight:
                return closed? -width/3 : 0
                break

            case Qt.RightToLeft:
                return closed? width/3 : 0
                break
            }
        }

        clip: true

        Behavior on x {
            NumberAnimation{easing.type: easingType; duration: animationDuration}
        }

        property variant itemObject
        property bool closed
    }

    function append(component) {
        var last = list.lastItem()
        var iscene = item_component.createObject(pmanager)

        last.closed = true
        list.append(iscene)

        iscene.itemObject = component.createObject(iscene.itemScene)
    }

    Component {
        id: item_component
        Item {
            id: item
            width: parent.width
            height: parent.height
            clip: true

            property alias itemScene: item_scene
            property variant itemObject
            property bool opened: false
            property bool closed: false

            MouseArea {
                anchors.fill: parent
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: opened? 0.5 : 0

                Behavior on opacity {
                    NumberAnimation{easing.type: easingType; duration: animationDuration}
                }
            }

            Rectangle {
                id: item_scene
                width: parent.width
                height: parent.height
                x: {
                    if(item.opened && !item.closed)
                        return 0

                    switch(pmanager.layoutDirection) {
                    case Qt.LeftToRight:
                        return item.closed? -item.width/3 : item.width
                        break

                    case Qt.RightToLeft:
                        return item.closed? item.width/3 : -item.width
                        break
                    }
                }

                Behavior on x {
                    NumberAnimation{easing.type: easingType; duration: animationDuration}
                }
            }

            Timer {
                id: destroy_timer
                interval: animationDuration
                onTriggered: {
                    if(item.itemObject)
                        item.itemObject.destroy()
                    item.destroy()
                }
            }

            function back() {
                list.removeAll(item)
                list.lastItem().closed = false
                opened = false
                destroy_timer.restart()
            }

            Component.onCompleted: {
                opened = true
                BackHandler.pushHandler(item, item.back)
            }
        }
    }
}

