/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0
import TelegramQmlLib 1.0
import Cutegram 1.0

Item {
    id: smilies
    anchors.fill: parent
    anchors.margins: 10*Devices.density
    clip: true

    property bool recent: true
    property variant accountEmojis: emojis
    property alias telegramObject: stickers_model.telegram

    property real panelWidth: 125*Devices.density

    signal emojiSelected( string code )
    signal stickerSelected( string path )
    signal stickerDocumentSelected(variant document)

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    StickersModel {
        id: stickers_model
    }

    EmoticonsModel {
        id: emodel
        emojis: accountEmojis
        stickerSubPaths: [Devices.localFilesPrePath + AsemanApp.homePath + "/stickers", Devices.resourcePath + "/stickers"]
    }

    Rectangle {
        height: parent.height
        width: 1*Devices.density
        anchors.left: tab_row.right
        color: "#22000000"
    }

    ListView {
        id: tab_row
        x: 6*Devices.density
        width: panelWidth
        height: parent.height
        orientation: ListView.Vertical
        model: {
            var result = new Array
            for(var i=0 ;i<emodel.keys.length; i++)
                result[result.length] = emodel.keys[i]
            for(var i=0 ;i<stickers_model.installedStickerSets.length; i++)
                result[result.length] = stickers_model.installedStickerSets[i]
            return result
        }

        delegate: Item {
            id: titem
            height: 30*Devices.density
            width: tab_row.width

            property variant itemObject

            Component.onCompleted: {
                if(index < emodel.keys.length)
                    itemObject = tab_emoji_icon.createObject(titem, {"index": index})
                else {
                    var idx = index - emodel.keys.length
                    var sid = stickers_model.installedStickerSets[idx]
                    var doc = stickers_model.stickerSetThumbnailDocument(sid)
                    var set = stickers_model.stickerSetItem(sid)

                    itemObject = tab_sticker_icon.createObject(titem, {"index": index, "document": doc, "stickerSet": set, "currentStickerSet": sid})
                }
            }
        }
    }

    GridView {
        id: slist
        anchors.fill: elist
        clip: true
        model: stickers_model
        visible: count != 0
        cellWidth: 90*Devices.density
        cellHeight: cellWidth
        delegate: Rectangle {
            width: slist.cellWidth
            height: slist.cellHeight
            color: marea.pressed? "#66ffffff" : "#00000000"

            Image {
                anchors.fill: parent
                anchors.margins: 5*Devices.density
                sourceSize: Qt.size(width, height)
                source: sticker_handler.filePath
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            FileHandler {
                id: sticker_handler
                target: model.document
                telegram: telegramObject
                Component.onCompleted: download()
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    smilies.stickerDocumentSelected(model.document)
                }
            }
        }
    }

    GridView {
        id: elist
        anchors.left: tab_row.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 4*Devices.density
        clip: true
        model: emodel
        visible: !slist.visible
        cellWidth: emodel.currentKeyIndex>1? 90*Devices.density : 32*Devices.density
        cellHeight: cellWidth
        delegate: Rectangle {
            id: item
            width: elist.cellWidth
            height: elist.cellHeight
            color: marea.pressed? "#66ffffff" : "#00000000"

            Image {
                width: emodel.currentKeyIndex>1? parent.width - 10*Devices.density : 22*Devices.density
                height: emodel.currentKeyIndex>1? parent.height - 10*Devices.density : width
                anchors.centerIn: parent
                sourceSize: Qt.size(width, height)
                source: model.path
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if( mouse.button == Qt.RightButton ) {
                        if(model.type == EmoticonsModel.EmoticonSticker) {
                            var actions = [qsTr("Delete")]
                            switch(Desktop.showMenu(actions)) {
                            case 0:
                                if( Desktop.yesOrNo(View, qsTr("Delete Sticker"), qsTr("Are you sure about delete this?")) ) {
                                    Cutegram.deleteFile(model.path)
                                    emodel.refresh()
                                }
                                break;
                            }
                        }
                    } else {
                        switch(model.type)
                        {
                        case EmoticonsModel.EmoticonEmoji:
                            smilies.emojiSelected(model.key)
                            emodel.pushToRecent(model.key)
                            break;

                        case EmoticonsModel.EmoticonSticker:
                            smilies.stickerSelected(model.path)
                            break;
                        }
                    }
                }
            }
        }
    }

    NormalWheelScroll {
        flick: elist
        visible: elist.visible
        animated: Cutegram.smoothScroll
    }

    NormalWheelScroll {
        flick: slist
        visible: slist.visible
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: elist; width: 6*Devices.density; anchors.right: parent.right; anchors.top: elist.top;
        anchors.bottom: elist.bottom; color: "#333333"
        visible: elist.visible
    }

    PhysicalScrollBar {
        scrollArea: slist; width: 6*Devices.density; anchors.right: parent.right; anchors.top: slist.top;
        anchors.bottom: slist.bottom; color: "#333333"
        visible: slist.visible
    }

    NormalWheelScroll {
        flick: tab_row
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: tab_row; width: 6*Devices.density; anchors.left: parent.left; anchors.top: tab_row.top;
        anchors.bottom: tab_row.bottom; color: "#333333"
    }

    Component {
        id: tab_emoji_icon
        Button {
            anchors.fill: parent
            rowWidth: panelWidth - 8*Devices.density
            clip: true
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: Math.floor(9*Devices.fontDensity)
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            cursorShape: Qt.PointingHandCursor
            textColor: emodel.currentKeyIndex==index && stickers_model.currentStickerSet == 0? "#333333" : Cutegram.currentTheme.masterColor
            text: Cutegram.normalizeText(emodel.keys[index])
            icon: emodel.keysIcons[index]
            iconHeight: height - 4*Devices.density
            onClicked: {
                emodel.currentKey = emodel.keys[index]
                stickers_model.currentStickerSet = ""
            }

            property int index
        }
    }

    Component {
        id: tab_sticker_icon
        Button {
            id: sitem
            anchors.fill: parent
            rowWidth: panelWidth - 8*Devices.density
            clip: true
            icon: handler.filePath
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: Math.floor(9*Devices.fontDensity)
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            cursorShape: Qt.PointingHandCursor
            iconHeight: height - 4*Devices.density
            textColor: stickers_model.currentStickerSet == currentStickerSet? "#333333" : Cutegram.currentTheme.masterColor
            text: {
                var res = sitem.stickerSet.title
                if(res.length <= 13)
                    return res
                else
                    return res.slice(0, 12) + "..."
            }

            property Document document
            property StickerSet stickerSet
            property int index
            property string currentStickerSet

            onClicked: {
                stickers_model.currentStickerSet = currentStickerSet
            }

            FileHandler {
                id: handler
                target: sitem.document
                telegram: telegramObject
                Component.onCompleted: download()
            }
        }
    }
}
