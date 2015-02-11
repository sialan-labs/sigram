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
import Cutegram 1.0

Item {
    id: smilies
    anchors.fill: parent
    anchors.margins: 10*Devices.density
    clip: true

    property bool recent: true

    signal selected( string code )

    onRecentChanged: slist.refresh()

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
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: 9*Devices.fontDensity
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            textColor: recent? Cutegram.highlightColor : "#333333"
            text: qsTr("Recent")
            cursorShape: Qt.PointingHandCursor
            onClicked: recent = true
        }

        Button {
            width: parent.width/2
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: 9*Devices.fontDensity
            normalColor: "#00000000"
            highlightColor: "#0f000000"
            textColor: recent? "#333333" : Cutegram.highlightColor
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
        anchors.margins: 4*Devices.density
        clip: true
        model: ListModel{}
        cellWidth: 32*Devices.density
        cellHeight: 32*Devices.density
        delegate: Rectangle {
            id: item
            width: slist.cellWidth
            height: slist.cellHeight
            color: marea.pressed? "#66ffffff" : "#00000000"

            Image {
                anchors.fill: parent
                anchors.margins: 5*Devices.density
                sourceSize: Qt.size(width,height)
                source: emoti.length==0? "" : Devices.localFilesPrePath + emojis.pathOf(key)
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true

                property string emoti: emojis.pathOf(key)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    smilies.selected(key)

                    var newList = new Array
                    newList[0] = key

                    var cnt = 1
                    var recentList = AsemanApp.readSetting("recentEmoji")
                    for( var i=0; cnt<35; i++ )
                        if( recentList[i] != key ) {
                            newList[cnt] = recentList[i]
                            cnt++
                        }

                    AsemanApp.setSetting("recentEmoji", newList)
                }
            }
        }

        function refresh() {
            model.clear()
            var recentList = AsemanApp.readSetting("recentEmoji")
            if( !recentList ) {
                recentList = emojis.keys().slice(0,20)
                AsemanApp.setSetting("recentEmoji", recentList)
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
        scrollArea: slist; width: 6*Devices.density; anchors.right: parent.right; anchors.top: slist.top;
        anchors.bottom: slist.bottom; color: "#333333"
    }
}
