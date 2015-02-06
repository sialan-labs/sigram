/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: color_list
    clip: true

    property color currentColor: "dodgerblue"

    GridView {
        id: color_grid
        anchors.fill: parent
        cellWidth: width/(cellCount<3? 3 : cellCount)
        cellHeight: cellWidth - 15*Devices.density

        property int cellCount: Math.floor(width/(100*Devices.density))

        model: ListModel {}
        delegate: Item {
            id: item
            width: color_grid.cellWidth
            height: width

            Rectangle{
                id: rectangle
                anchors.fill: parent
                anchors.margins: 15*Devices.density
                radius: width/2
                border.color: "#ffffff"
                border.width: 3*Devices.density
                color: itemColor
            }

            MouseArea{
                id: mousearea
                anchors.fill: parent
                onClicked: {
                    color_list.currentColor = itemColor
                }
            }
        }

        Component.onCompleted: {
            model.clear()

            model.append({"itemColor": "darkgray"})
            model.append({"itemColor": "dodgerblue"})
            model.append({"itemColor": "darkgreen"})
            model.append({"itemColor": "gold"})

            model.append({"itemColor": "maroon"})
            model.append({"itemColor": "purple"})
            model.append({"itemColor": "orangered"})
            model.append({"itemColor": "magenta"})

            model.append({"itemColor": "darkslateblue"})
            model.append({"itemColor": "violet"})
            model.append({"itemColor": "saddlebrown"})
            model.append({"itemColor": "black"})

            model.append({"itemColor": "chocolate"})
            model.append({"itemColor": "firebrick"})
            model.append({"itemColor": "teal"})
            model.append({"itemColor": "darkviolet"})

            model.append({"itemColor": "olive"})
            model.append({"itemColor": "mediumvioletred"})
            model.append({"itemColor": "darkorange"})
            model.append({"itemColor": "darkslategray"})
        }
    }

    ScrollBar {
        scrollArea: color_grid; height: color_grid.height; width: 6*Devices.density
        anchors.right: color_grid.right; anchors.top: color_grid.top; color: "#000000"
    }
}
