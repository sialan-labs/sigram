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
    id: confg
    width: 100
    height: 62

    property int userId: Telegram.me

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 32
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        ContactImage {
            id: cimg
            width: 148
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            uid: confg.userId
            onlineState: true
            borderColor: "#cccccc"
        }

        Text {
            id: fname
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            color: "#ffffff"
            text: Telegram.contactFirstName(confg.userId)
        }

        Text {
            id: lname
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            color: "#ffffff"
            text: Telegram.contactLastName(confg.userId)
        }

        Text {
            id: phone
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            color: "#ffffff"
            text: Telegram.contactPhone(confg.userId)
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        height: 40

        Button {
            id: background_btn
            anchors.right: delete_btn.left
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            normalColor: "#33CCAD"
            highlightColor: "#3AE9C6"
            text: qsTr("Change Background")
            fontSize: 9*fontsScale
            onClicked: {
                var path = Gui.getOpenFile()
                if( path.length == 0 )
                    return

                Gui.background = path
            }
        }

        Button {
            id: delete_btn
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            width: visible? height : 0
            color: "#E65245"
            iconHeight: 12
            icon: "files/delete.png"
            visible: Gui.background.length != 0
            onClicked: Gui.background = ""
        }
    }
}
