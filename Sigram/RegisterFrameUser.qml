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

Column {
    width: 100
    height: 62
    spacing: 10

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        color: "#55ffffff"

        Text {
            anchors.fill: firstname_line
            verticalAlignment: Text.AlignVCenter
            font: firstname_line.font
            text: qsTr("First Name")
            color: "#aaaaaa"
            visible: !firstname_line.focus && firstname_line.text.length == 0
        }

        TextInput {
            id: firstname_line
            anchors.fill: parent
            anchors.margins: 6
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 11
            font.family: globalNormalFontFamily
            font.weight: Font.Normal
            onAccepted: lastname_line.focus = true
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        color: "#55ffffff"

        Text {
            anchors.fill: lastname_line
            verticalAlignment: Text.AlignVCenter
            font: lastname_line.font
            text: qsTr("Last Name")
            color: "#aaaaaa"
            visible: !lastname_line.focus && lastname_line.text.length == 0
        }

        TextInput {
            id: lastname_line
            anchors.fill: parent
            anchors.margins: 6
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 11
            font.family: globalNormalFontFamily
            font.weight: Font.Normal
            onAccepted: go()
        }
    }

    Button {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 40
        normalColor: "#33CCAD"
        highlightColor: "#3AE9C6"
        textColor: "#ffffff"
        textFont.pointSize: 11
        textFont.family: globalNormalFontFamily
        text: qsTr("Submit")
        onClicked: go()
    }

    function go() {
        if( firstname_line.text.length == 0 )
            return

        Telegram.waitAndGetUserInfoCallBack( firstname_line.text, lastname_line.text )
    }
}
