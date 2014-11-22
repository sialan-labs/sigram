/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2

Rectangle {
    id: button
    smooth: true
    width: row.width + 20*physicalPlatformScale
    height: 30*physicalPlatformScale
    color: press? highlightColor : normalColor

    property alias text: txt.text
    property alias icon: icn.source
    property alias fontSize: txt.font.pixelSize
    property alias textFont: txt.font

    property alias hoverEnabled: marea.hoverEnabled

    property alias iconHeight: icn.height
    property bool iconCenter: false

    property bool press: marea.pressed
    property bool enter: marea.containsMouse

    property string highlightColor: masterPalette.highlight
    property string normalColor: "#00000000"
    property alias textColor: txt.color

    property alias cursorShape: marea.cursorShape
    property real textMargin: 1*physicalPlatformScale

    property color tooltipColor: "#cc000000"
    property color tooltipTextColor: "#ffffff"
    property font tooltipFont
    property string tooltipText

    signal clicked()

    Row {
        id: row
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 4*physicalPlatformScale
        anchors.margins: 3*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4*physicalPlatformScale

        Image {
            id: icn
            anchors.verticalCenter: parent.verticalCenter
            height: source==""? 0 : parent.height-14*physicalPlatformScale
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
            font.family: SApp.globalFontFamily
            font.pixelSize: 9*fontsScale
        }
    }

    MouseArea{
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
        onEntered: if( !tooltipItem && tooltipText.length != 0 ) tooltipItem = tooltip_component.createObject(button)
        onExited: if( tooltipItem ) tooltipItem.end()

        property variant tooltipItem
    }

    Component {
        id: tooltip_component

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            anchors.margins: 2*physicalPlatformScale
            color: tooltipColor
            width: tooltip_txt.width + 14*physicalPlatformScale
            height: tooltip_txt.height + 14*physicalPlatformScale
            radius: 3*physicalPlatformScale

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
