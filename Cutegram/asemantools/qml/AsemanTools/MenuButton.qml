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
    width: 100*Devices.density
    height: 30*Devices.density
//    radius: 2*Devices.density
    color: press? highlightColor : normalColor

    property alias text: txt.text
    property alias fontSize: txt.font.pixelSize
    property alias textFont: txt.font

    property alias splitter: splitter_rect.visible
    property alias splitterColor: splitter_rect.color

    property alias hoverEnabled: marea.hoverEnabled

    property bool iconCenter: false

    property bool press: marea.pressed
    property bool enter: marea.containsMouse

    property string highlightColor: masterPalette.highlight
    property string normalColor: "#00000000"
    property alias textColor: txt.color
    property alias textAlignment: txt.horizontalAlignment

    signal clicked()


    Text{
        id: txt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20*Devices.density
        y: parent.height/2 - height/2 - 1*Devices.density
        color: "#ffffff"
        font.bold: Devices.isWindows? false : true
        font.family: AsemanApp.globalFont.family
        font.pixelSize: Math.floor(9*Devices.fontDensity)
    }

    MouseArea{
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }

    Rectangle {
        id: splitter_rect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1*Devices.density
        visible: false
        opacity: 0.3
    }
}
