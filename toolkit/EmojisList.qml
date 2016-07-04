import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Rectangle {
    id: elist
    color: "#fefefe"

    signal emojiSelected(string emoji)

    ListModel {
        id: listModel
        Component.onCompleted: {
            listModel.clear()
            CutegramEmojiDatabase.getCategories(function(cats) {
                for(var name in cats) {
                    var cat = cats[name]
                    if(viewer.category.length == 0)
                        viewer.category = name
                    listModel.append({"category": name,
                                      "name": cat.name,
                                      "unicode": cat.unicode})
                }
            })
        }
    }

    Rectangle {
        anchors.fill: clistv
        color: "#f3f3f3"
        radius: parent.radius

        Rectangle {
            width: parent.width
            height: parent.radius
            color: parent.color
        }
    }

    EmojisViewer {
        id: viewer
        width: parent.width
        height: parent.height - clistv.height
        showAllItems: true
        onEmojiSelected: elist.emojiSelected(emoji)
    }

    AsemanListView {
        id: clistv
        width: parent.width
        height: 46*Devices.density
        anchors.bottom: parent.bottom
        model: listModel
        orientation: Qt.Horizontal
        currentIndex: 0
        clip: true
        delegate: Item {
            width: height
            height: clistv.height

            Image {
                anchors.centerIn: parent
                width: 18*Devices.density
                height: width
                sourceSize: Qt.size(width*2, height*2)
                source: CutegramEmojis.getLink(CutegramEmojis.fromCodePoint(model.unicode), "72x72")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clistv.currentIndex = index
                    viewer.category = model.category
                }
            }
        }

        highlightMoveDuration: 250
        highlightMoveVelocity: -1
        highlight: Item {
            width: height
            height: clistv.height

            Rectangle {
                width: parent.width
                height: 2*Devices.density
                anchors.bottom: parent.bottom
                color: CutegramGlobals.highlightColors
            }
        }
    }

    NormalWheelScroll {
        flick: clistv
        animated: false
    }
}

