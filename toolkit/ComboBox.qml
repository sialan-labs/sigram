import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "../globals"

Item {
    id: combo
    height: 32*Devices.density
    z: menuVisible? 10 : 0

    property bool menuVisible: false
    property int currentIndex: 0

    property string roleDisplay: "name"
    property string roleIcon: "icon"
    property variant modelArray: new Array

    property alias layoutDirection: lookRow.layoutDirection

    property alias iconColor: iconTxt.color
    property alias iconSize: iconTxt.font.pixelSize

    property alias textColor: nameTxt.color
    property alias textFont: nameTxt.font

    onMenuVisibleChanged: {
        if(menuVisible) {
            BackHandler.pushHandler(combo, function(){menuVisible = false})
            menu.item = list_component.createObject(menu)
        } else {
            BackHandler.removeHandler(combo)
            Tools.jsDelayCall(300, menu.item.destroy)
        }
    }

    onModelArrayChanged: {
        lmodel.clear()
        for(var i in modelArray) {
            var map = modelArray[i]
            lmodel.append({"map":map})
        }
    }

    ListModel {
        id: lmodel
    }

    MouseArea {
        width: 10000
        height: 10000
        anchors.centerIn: parent
        visible: menuVisible
        onClicked: BackHandler.back()
    }

    DropShadow {
        anchors.fill: menu_back
        source: menu_back
        horizontalOffset: 1*Devices.density
        verticalOffset: 1*Devices.density
        radius: 8*Devices.density
        samples: 32
        color: "#30000000"
        opacity: menuVisible? 1 : 0
        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
    }

    Item {
        id: menu_back
        y: -8*Devices.density
        width: parent.width + 16*Devices.density + extraWidth
        height: parent.height + 16*Devices.density + extraHeight
        anchors.horizontalCenter: parent.horizontalCenter

        property real extraWidth: menuVisible? 8*Devices.density : 0
        property real extraHeight: menuVisible && menu.item? menu.item.height : 0

        Behavior on extraWidth {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
        Behavior on extraHeight {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }

        Rectangle {
            id: menu
            color: "#fefefe"
            anchors.fill: parent
            anchors.margins: 8*Devices.density
            radius: menuVisible? 2*Devices.density : 0
            clip: true

            Behavior on radius {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }

            NullMouseArea {
                anchors.fill: parent
            }

            Row {
                id: lookRow
                anchors.left: parent.left
                anchors.right: parent.right
                y: combo.height/2 - height/2
                anchors.margins: 14*Devices.density
                spacing: 6*Devices.density

                Text {
                    id: iconTxt
                    color: "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Awesome.family
                    font.pixelSize: 10*Devices.fontDensity
                    text: {
                        if(currentIndex == -1 || currentIndex >= modelArray.length)
                            return ""
                        else
                            return modelArray[currentIndex][roleIcon]
                    }
                }

                Text {
                    id: nameTxt
                    color: "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 9*Devices.fontDensity
                    text: {
                        if(currentIndex == -1 || currentIndex >= modelArray.length)
                            return ""
                        else
                            return modelArray[currentIndex][roleDisplay]
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1*Devices.density
                y: combo.height
                color: "#e6e6e6"
                visible: menuVisible
            }

            property variant item
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: menuVisible = !menuVisible
    }

    Component {
        id: list_component
        AsemanListView {
            id: listv
            width: parent.width
            height: count*32*Devices.density + 8*Devices.density
            y: combo.height
            model: lmodel
            clip: true
            delegate: Rectangle {
                width: listv.width
                height: 32*Devices.density
                color: marea.pressed? "#e6e6e6" : "#00000000"

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 14*Devices.density
                    color: "#333333"
                    font.pixelSize: 9*Devices.fontDensity
                    font.bold: combo.currentIndex == index
                    text: model.map[roleDisplay]
                }

                MouseArea {
                    id: marea
                    anchors.fill: parent
                    onClicked: {
                        combo.currentIndex = index
                        menuVisible = false
                    }
                }
            }
        }
    }
}

