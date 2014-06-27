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

Rectangle {
    id: smilies
    width: 100
    height: 62
    color: imageBack? "#55ffffff" : "#404040"
    clip: true

    signal selected( string code )

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    GridView {
        id: slist
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        model: ListModel{}
        cellWidth: 32
        cellHeight: 32
        delegate: Rectangle {
            id: item
            width: slist.cellWidth
            height: slist.cellHeight
            color: marea.pressed? "#66ffffff" : "#00000000"

            Image {
                anchors.fill: parent
                anchors.margins: 6
                sourceSize: Qt.size(width,height)
                source: "file://" + Emojis.pathOf(key)
                smooth: true
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: smilies.selected(key)
            }
        }

        function refresh() {
            model.clear()
            var keys = Emojis.keys()
            for( var i=0; i<keys.length; i++ )
                model.append( {"key":keys[i]} )
        }

        Component.onCompleted: refresh()
    }

    NormalWheelScroll {
        flick: slist
    }

    PhysicalScrollBar {
        scrollArea: slist; width: 8; anchors.right: parent.right; anchors.top: slist.top;
        anchors.bottom: slist.bottom; color: "#ffffff"
    }
}
