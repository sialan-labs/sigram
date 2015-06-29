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
import TelegramQml 1.0
import Cutegram 1.0

Item {
    id: smilies
    anchors.fill: parent
    anchors.margins: 10*Devices.density
    clip: true

    property bool recent: true
    property variant accountEmojis: emojis

    signal emojiSelected( string code )
    signal stickerSelected( string path )

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    EmoticonsModel {
        id: emodel
        emojis: accountEmojis
        stickerSubPaths: [Devices.localFilesPrePath + AsemanApp.homePath + "/stickers", Devices.resourcePath + "/stickers"]
    }

    ListView {
        id: tab_row
        width: parent.width
        height: 30*Devices.density
        anchors.top: parent.top
        orientation: ListView.Horizontal
        model: emodel.keys
        delegate: Button {
            width: tab_row.width/tab_row.count
            height: tab_row.height
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: Math.floor(9*Devices.fontDensity)
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            cursorShape: Qt.PointingHandCursor
            textColor: emodel.currentKeyIndex==index? "#333333" : Cutegram.currentTheme.masterColor
            text: Cutegram.normalizeText(emodel.keys[index])
            onClicked: emodel.currentKey = emodel.keys[index]
        }
    }

    GridView {
        id: slist
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tab_row.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 4*Devices.density
        clip: true
        model: emodel
        cellWidth: emodel.currentKeyIndex>1? 100*Devices.density : 32*Devices.density
        cellHeight: cellWidth
        delegate: Rectangle {
            id: item
            width: slist.cellWidth
            height: slist.cellHeight
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
        flick: slist
        animated: Cutegram.smoothScroll
    }

    PhysicalScrollBar {
        scrollArea: slist; width: 6*Devices.density; anchors.right: parent.right; anchors.top: slist.top;
        anchors.bottom: slist.bottom; color: "#333333"
    }
}
