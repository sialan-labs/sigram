import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
// import CutegramTypes 1.0

Item {
    id: ac_list
    width: 100
    height: 62

    property alias telegram: cmodel.telegram
    property alias selecteds: list.list

    property bool messageDraging: false

    signal selected(variant cid)

    ContactsModel {
        id: cmodel
        onInitializingChanged: {
            if( initializing )
                indicator.start()
            else
                indicator.stop()
        }
    }

    ListObject {
        id: list
    }

    DropArea {
        anchors.fill: parent
    }

    ListView {
        id: clist
        anchors.fill: parent
        clip: true
        model: cmodel
        spacing: 4*Devices.density
        delegate: Item {
            id: clist_item
            width: clist.width
            height: 50*Devices.density

            property Contact citem: item
            property User user: telegram.user(citem.userId)

            property bool itemSelected: list.contains(citem.userId)

            DragObject {
                id: drag
                mimeData: mime
                source: marea
                image: "files/message.png"
                hotSpot: Qt.point(22,22)
                dropAction: Qt.CopyAction
            }

            MimeData {
                id: mime
                dataMap: {"land.aseman.cutegram/contactId": citem.userId}
                text: txt.text
            }

            Rectangle {
                anchors.fill: parent
                color: itemSelected || marea.pressed? Cutegram.currentTheme.masterColor : "#00000000"
                opacity: 0.5
            }

            ContactImage {
                id: profile_img
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 4*Devices.density
                width: height
                user: clist_item.user
                isChat: false
                telegram: ac_list.telegram
            }

            Text {
                id: txt
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: profile_img.right
                anchors.right: parent.right
                anchors.margins: 4*Devices.density
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                font.family: AsemanApp.globalFont.family
                font.pixelSize: Math.floor(10*Devices.fontDensity)
                text: user.firstName + " " + user.lastName
                color: "#333333"
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    var uid = citem.userId
                    if( list.contains(uid) )
                        list.removeOne(uid)
                    else
                        list.append(uid)

                    itemSelected = !itemSelected
                    ac_list.selected(uid)
                }
                onPressed: {
                    startPoint = Qt.point(mouseX, mouseY)
                }
                onPositionChanged: {
                    var destX = mouseX-startPoint.x
                    if(destX < 7)
                        return
                    if(messageDraging)
                        return

                    messageDraging = true
                    drag.start()
                    messageDraging = false
                }

                property point startPoint
            }
        }
    }

    NormalWheelScroll {
        flick: clist
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 6*Devices.density
        anchors.right: clist.right; anchors.top: clist.top; color: textColor0
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: false
        modern: true
        indicatorSize: 20*Devices.density
    }
}
