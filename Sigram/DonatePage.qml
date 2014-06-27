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

Item {
    id: d_dialog
    width: 100
    height: 62
    clip: true

    Image {
        id: img
        anchors.fill: parent
        sourceSize: Qt.size(width,height)
        source: "files/registering_splash.jpg"
        smooth: true
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        id: donate_title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 53
        color: imageBack? "#88cccccc" : "#555555"

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: y
            font.pointSize: 11
            font.weight: Font.Normal
            font.family: globalNormalFontFamily
            color: imageBack? "#333333" : "#cccccc"
            text: qsTr("Donate")
        }
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pointSize: 13
        font.weight: Font.Normal
        font.family: globalNormalFontFamily
        text: qsTr("Your donations help to fund continuing maintenance tasks, development of new features and keep sigram and another sialan projects alive.")
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 42

        Button {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.horizontalCenter
            anchors.top: parent.top
            textColor: "#ffffff"
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            text: qsTr("Donate")
            onClicked: {
                if( Gui.country == "iran" )
                    Gui.openUrl("http://labs.sialan.org/donate-ir")
                else
                    Gui.openUrl("http://labs.sialan.org/donate")

                flipMenu.hide()
            }
        }

        Button {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.horizontalCenter
            anchors.top: parent.top
            textColor: "#ffffff"
            normalColor: "#ff5532"
            highlightColor: "#D04528"
            text: qsTr("Dismiss")
            onClicked: {
                flipMenu.hide()
            }
        }
    }
}
