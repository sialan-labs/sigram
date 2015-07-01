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

Rectangle {
    id: button
    smooth: true
    width: row.width + 20*Devices.density
    height: 30*Devices.density
    color: press? highlightColor : (enter?hoverColor:normalColor)

    property alias text: txt.text
    property alias icon: icn.source
    property alias fontSize: txt.font.pixelSize
    property alias textFont: txt.font

    property alias hoverEnabled: marea.hoverEnabled
    property alias containsMouse: marea.containsMouse

    property alias iconHeight: icn.height
    property bool iconCenter: false

    property bool press: marea.pressed
    property bool enter: marea.containsMouse

    property bool triggeredOnHover: false

    property color highlightColor: masterPalette.highlight
    property string normalColor: "#00000000"
    property string hoverColor: normalColor

    property alias textColor: txt.color

    property alias cursorShape: marea.cursorShape
    property real textMargin: 0

    property color tooltipColor: "#cc000000"
    property color tooltipTextColor: "#ffffff"
    property font tooltipFont
    property string tooltipText

    signal clicked()

    Row {
        id: row
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 3*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4*Devices.density

        Image {
            id: icn
            anchors.verticalCenter: parent.verticalCenter
            height: source==""? 0 : parent.height-14*Devices.density
            width: height
            sourceSize.width: width
            sourceSize.height: height
            smooth: true
        }

        Text{
            id: txt
            y: parent.height/2 - height/2 - textMargin
            color: "#ffffff"
            font.bold: Devices.isWindows? false : true
            font.family: AsemanApp.globalFont.family
            font.pixelSize: Math.floor(9*Devices.fontDensity)
        }
    }

    MouseArea{
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
        onEntered: {
            if(triggeredOnHover)
                button.clicked()
            if( !tooltipItem && tooltipText.length != 0 )
                tooltipItem = tooltip_component.createObject(button)
        }
        onExited: if( tooltipItem ) tooltipItem.end()

        property variant tooltipItem
    }

    Component {
        id: tooltip_component

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            anchors.margins: 2*Devices.density
            color: tooltipColor
            width: tooltip_txt.width + 14*Devices.density
            height: tooltip_txt.height + 14*Devices.density
            radius: 3*Devices.density

            Text {
                id: tooltip_txt
                anchors.centerIn: parent
                font: tooltipFont
                color: tooltipTextColor
                text: tooltipText
            }

            function end() {
                destroy()
            }
        }
    }
}
