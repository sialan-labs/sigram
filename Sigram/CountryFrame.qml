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

Item {
    id: cntr_frame
    width: 100
    height: 62

    signal selected( string country )

    ListView {
        id: clist
        anchors.fill: parent
        model: ListModel{}
        clip: true

        delegate: Rectangle {
            id: item
            height: 42
            width: clist.width
            color: marea.pressed? "#E65245" : "#00000000"

            CountryImage {
                id: cntr_img
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 4
                anchors.leftMargin: 10
                width: height
                countryName: name
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: cntr_img.right
                anchors.leftMargin: 8
                font.pointSize: 10
                font.family: globalNormalFontFamily
                text: name
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: cntr_frame.selected(name)
            }
        }

        function refresh() {
            model.clear()

            var cntrs = Countries.countries()
            for( var i=0; i<cntrs.length; i++ )
                model.append( {"name":cntrs[i]} )
        }

        Component.onCompleted: refresh()
    }

    NormalWheelScroll {
        flick: clist
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#333333"
    }
}
