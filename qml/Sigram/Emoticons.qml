/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0

Item {
    id: smilies
    anchors.fill: parent
    anchors.margins: 10*physicalPlatformScale
    clip: true

    property bool recent: true

    signal selected( string code )

    onRecentChanged: slist.refresh()

    SystemPalette { id: palette; colorGroup: SystemPalette.Active }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Row {
        id: tab_row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Button {
            width: parent.width/2
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 9*fontsScale
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            textColor: recent? palette.highlight : "#333333"
            text: qsTr("Recent")
            cursorShape: Qt.PointingHandCursor
            onClicked: recent = true
        }

        Button {
            width: parent.width/2
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 9*fontsScale
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            textColor: recent? "#333333" : palette.highlight
            text: qsTr("All Emoji")
            cursorShape: Qt.PointingHandCursor
            onClicked: recent = false
        }
    }

    GridView {
        id: slist
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tab_row.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 4*physicalPlatformScale
        clip: true
        model: ListModel{}
        cellWidth: 32*physicalPlatformScale
        cellHeight: 32*physicalPlatformScale
        delegate: Rectangle {
            id: item
            width: slist.cellWidth
            height: slist.cellHeight
            color: marea.pressed? "#66ffffff" : "#00000000"

            Image {
                anchors.fill: parent
                anchors.margins: 5*physicalPlatformScale
                sourceSize: Qt.size(width,height)
                source: "file://" + emojis.pathOf(key)
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    smilies.selected(key)

                    var newList = new Array
                    newList[0] = key

                    var cnt = 1
                    var recentList = SApp.readSetting("recentEmoji")
                    for( var i=0; cnt<35; i++ )
                        if( recentList[i] != key ) {
                            newList[cnt] = recentList[i]
                            cnt++
                        }

                    SApp.setSetting("recentEmoji", newList)
                }
            }
        }

        function refresh() {
            model.clear()
            var recentList = SApp.readSetting("recentEmoji")
            if( !recentList ) {
                recentList = emojis.keys().slice(0,20)
                SApp.setSetting("recentEmoji", recentList)
            }

            var keys = recent? recentList : emojis.keys()
            for( var i=0; i<keys.length; i++ )
                model.append( {"key":keys[i]} )
        }

        Component.onCompleted: refresh()
    }

    NormalWheelScroll {
        flick: slist
    }

    PhysicalScrollBar {
        scrollArea: slist; width: 6*physicalPlatformScale; anchors.right: parent.right; anchors.top: slist.top;
        anchors.bottom: slist.bottom; color: "#ffffff"
    }
}
