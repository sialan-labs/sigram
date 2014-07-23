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
    width: 100
    height: 62

    gradient: Gradient {
        GradientStop { position: 0.00; color: "#33b7cc" }
        GradientStop { position: 0.35; color: "#33b7cc" }
        GradientStop { position: 0.65; color: "#33ccad" }
        GradientStop { position: 1.00; color: "#33ccad" }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Image {
            id: icon
            sourceSize: Qt.size(width,height)
            width: 128
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "files/about_icon.png"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sigram")
            font.pointSize: 30
            font.weight: Font.Light
            font.family: globalNormalFontFamily
            color: "#ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("A different telegram client from Sialan.Labs")
            font.pointSize: 16
            font.weight: Font.Light
            font.family: globalNormalFontFamily
            color: "#ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sigram project are released under the terms of the GPLv3 license.")
            font.pointSize: 9
            font.weight: Font.Light
            font.family: globalNormalFontFamily
            color: "#ffffff"
        }

        Image {
            id: sialan_logo
            sourceSize: Qt.size(width,height)
            width: 128
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "files/sialan_logo.png"
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10*physicalPlatformScale
        height: 42*physicalPlatformScale
        width: 200*physicalPlatformScale
        fontSize: 10*fontsScale
        textColor: "#ffffff"
        normalColor: "#ff5532"
        highlightColor: "#D04528"
        text: qsTr("Donate")
        onClicked: {
            if( Gui.country == "iran" )
                Gui.openUrl("http://labs.sialan.org/donate-ir")
            else
                Gui.openUrl("http://labs.sialan.org/donate")
        }
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        font.family: globalNormalFontFamily
        font.pointSize: 10
        color: "#ffffff"
        text: "version " + Gui.version()
    }
}
