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
    id: aseman_splash
    color: Desktop.titleBarColor

    property alias backButtonScale: header.backScale

    Image {
        id: logo
        anchors.centerIn: parent
        width: 200*Devices.density
        height: 142*Devices.density
        sourceSize: Qt.size(width,height)
        source: Desktop.titleBarIsDark? "files/aseman-special.png" : "files/aseman-special-black.png"
        z: 10
    }

    Text {
        id: desc_txt
        anchors.top: logo.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20*Devices.density
        font.family: AsemanApp.globalFont.family
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: Math.floor(9*Devices.fontDensity)
        color: Desktop.titleBarTextColor
        horizontalAlignment: Text.AlignHCenter
        z: 10
        text: qsTr("Aseman is a non-profit organization, exists to support and lead the free, open source and cross-platform projects and researches.")
    }

    Text {
        id: goal_txt
        anchors.top: desc_txt.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20*Devices.density
        anchors.rightMargin: 20*Devices.density
        anchors.topMargin: 4*Devices.density
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: Math.floor(9*Devices.fontDensity)
        font.family: AsemanApp.globalFont.family
        color: Desktop.titleBarTextColor
        horizontalAlignment: Text.AlignHCenter
        z: 10
        text: qsTr("The Goal of the Aseman is to provide free and secure products to keep people’s freedom and their privacy.")
    }

    Button {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: View.navigationBarHeight + 10*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        height: 40*Devices.density
        width: 120*Devices.density
        normalColor: masterPalette.highlight
        highlightColor: Qt.darker(masterPalette.highlight)
        textColor: masterPalette.highlightedText
        radius: 4*Devices.density
        text: qsTr("Home Page")
        onClicked: Qt.openUrlExternally("http://aseman.co")
    }

    Header {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: View.statusBarHeight
        light: Desktop.titleBarIsDark
    }
}
