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
import QtGraphicalEffects 1.0

Item {
    property alias color : back.color
    property alias shadowOpacity: blur.opacity
    property alias radius: blur.radius
    property alias visibleShadow: blur.visible
    property real shadowSize: 8*physicalPlatformScale

    Item {
        id: shadow
        anchors.fill: parent
        visible: false

        Rectangle {
            anchors.centerIn: parent
            width: back.width
            height: back.height
            color: "#333333"
        }
    }

    FastBlur {
        id: blur
        anchors.fill: shadow
        source: shadow
        radius: 2*physicalPlatformScale
    }

    Rectangle {
        id: back
        anchors.fill: parent
        anchors.margins: shadowSize
    }
}
