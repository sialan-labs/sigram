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
import QtGraphicalEffects 1.0

Item {
    id: modern_pbar
    anchors.fill: parent
    opacity: 0

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 400 }
    }

    property alias source: desaturate.source
    property real percent: 0

    Desaturate {
        id: desaturate
        anchors.fill: parent
        desaturation: 1-modern_pbar.percent/100
        cached: true
    }

    ProgressBar {
        y: parent.height/2 + 30*physicalPlatformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*physicalPlatformScale
        height: 5*physicalPlatformScale
        percent: modern_pbar.percent
    }

    function setValue(value){
        percent = value
    }

    Component.onCompleted: opacity = 1
}
