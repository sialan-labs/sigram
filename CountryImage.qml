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
import QtGraphicalEffects 1.0

Item {
    width: 100
    height: 62

    property string countryName
    property alias source: img.path

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: 5
        smooth: true
        visible: false
    }

    Image {
        id: img
        anchors.fill: parent
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false
        asynchronous: true
        source: path.length==0? "" : "file://" + path

        property string path: Countries.countryFlag(countryName)
    }

    ThresholdMask {
        id: threshold
        anchors.fill: img
        source: img
        maskSource: mask
        threshold: 0.4
        spread: 0.6
    }
}
