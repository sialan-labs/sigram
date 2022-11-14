import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../globals"

Item {
    id: viewer

    property string category
    property bool showAllItems: false

    onCategoryChanged: {
        if(showAllItems) {
            for(var i=0; i<lmodel.count; i++) {
                var item = lmodel.get(i)
                if(item.category == category) {
                    gview.currentIndex = i
                    return
                }
            }
        } else {
            refresh()
        }
    }
    onShowAllItemsChanged: refresh()

    function refresh() {
        lmodel.clear()

        var callback = function(cats) {
            for(var i in cats) {
                var cat = cats[i]
                lmodel.append({"category": cat.category,
                               "name": cat.name,
                               "unicode": cat.unicode})
            }
        }

        if(showAllItems)
            CutegramEmojiDatabase.getAllItems(callback)
        else
        if(category.length != 0)
            CutegramEmojiDatabase.getItems(category, callback)
    }

    signal emojiSelected(string emoji)

    ListModel {
        id: lmodel
    }

    AsemanGridView {
        id: gview
        anchors.fill: parent
        model: lmodel
        cellWidth: width/Math.floor(width/proximateCellSize)
        cellHeight: cellWidth
        clip: true
        highlightMoveDuration: 400
        preferredHighlightBegin: 0
        preferredHighlightEnd: cellHeight
        highlightRangeMode: GridView.ApplyRange

        property real proximateCellSize: 32*Devices.density

        delegate: Item {
            width: gview.cellWidth
            height: gview.cellHeight

            Image {
                anchors.centerIn: parent
                width: 22*Devices.density
                height: width
                asynchronous: true
                sourceSize: Qt.size(width*2, height*2)
                source: CutegramEmojis.getLink(CutegramEmojis.fromCodePoint(model.unicode), "72x72")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: emojiSelected(CutegramEmojis.fromCodePoint(model.unicode))
            }
        }
    }

    NormalWheelScroll {
        flick: gview
    }

    PhysicalScrollBar {
        anchors.right: gview.right
        height: gview.height
        width: 6*Devices.density
        color: CutegramGlobals.baseColor
        scrollArea: gview
    }
}

