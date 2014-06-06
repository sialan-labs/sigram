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
    id: sialan_splash
    color: hide? "#00000000" : "#333333"

    property bool hide: false
    property bool anims: false
    property real animSpeed: sialan_splash.anims? 500 : 0

    Behavior on color {
        ColorAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
    }

    Timer {
        id: hide_timer
        interval: 2000
        repeat: false
        onTriggered: {
            sialan_splash.anims = true
            sialan_splash.hide = true
            middle_timer.restart()
        }
    }

    Timer {
        id: middle_timer
        interval: 3*animSpeed/4
        repeat: false
        onTriggered: slogo_txt.text = "SIALAN L   BS"
    }

    Text {
        id: slogo_txt
        x: sialan_splash.hide? parent.width - 175 : parent.width/2 - width/2
        y: sialan_splash.hide? parent.height - 38 : parent.height/2 + sialan_logo.height/2 + 5
        text: "SIALAN LABS"
        font.weight: Font.Bold
        font.family: globalNormalFontFamily
        font.pointSize: sialan_splash.hide? 18 : 30
        color: "#ffffff"

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
        }
        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
        }
        Behavior on font.pointSize {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
        }
    }

    Image {
        id: sialan_logo
        x: sialan_splash.hide? parent.width - 70 : parent.width/2 - width/2
        y: sialan_splash.hide? parent.height - 32 : parent.height/2 - height/2
        width: sialan_splash.hide? 22 : 128
        height: width
        sourceSize: sialan_splash.hide? Qt.size(22,22) : Qt.size(width,height)
        source: "files/sialan.png"
        fillMode: Image.PreserveAspectFit
        smooth: true

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
        }
        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
        }
        Behavior on width {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: animSpeed }
        }
    }

    function start() {
        hide_timer.start()
    }
}
