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

import QtQuick 2.0

Item {
    id: header
    width: 100
    height: Devices.standardTitleBarHeight

    property alias text: title_txt.text
    property alias titleFont: title_txt.font
    property bool light: false
    property bool backButton: !Devices.isAndroid && !View.fullscreen

    signal beginBack()

    Row {
        id: back_row
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10*physicalPlatformScale
        width: 75*physicalPlatformScale
        visible: backButton

        Image {
            anchors.verticalCenter: parent.verticalCenter
            height: 20*physicalPlatformScale
            source: (!back_row.press && header.light)||(back_row.press && !header.light)? (height>48? "files/back_light_64.png" : "files/back_light_32.png") : (height>48? "files/back_64.png" : "files/back_32.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.8
        }

        Text {
            id: back_txt
            font.pixelSize: 14*fontsScale
            font.family: SApp.globalFontFamily
            y: parent.height/2 - height/2 + 2*physicalPlatformScale
            color: (!back_row.press && header.light)||(back_row.press && !header.light)? "#ffffff" : "#111111"
        }

        property bool press: false
    }

    MouseArea {
        anchors.fill: back_row
        onPressed: back_row.press = true
        onReleased: back_row.press = false
        visible: back_row.visible
        onClicked: {
            header.beginBack()
            SApp.back()
        }
    }

    Text {
        id: title_txt
        font.pixelSize: 16*fontsScale
        font.family: SApp.globalFontFamily
        y: parent.height/2 - height/2 + 2*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        color: header.light? "#ffffff" : "#333333"
    }

    Connections{
        target: SApp
        onLanguageUpdated: initTranslations()
    }

    Component.onCompleted: {
        initTranslations()
    }

    function initTranslations(){
        back_txt.text = qsTr("Back")
    }
}
