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
    id: u_dialog
    width: 100
    height: 62

    property alias text: txt.text
    property string version: "0"

    Rectangle {
        id: update_title
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
            text: qsTr("New update is available :)")
        }
    }

    Flickable {
        id: utxt_flickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: update_title.bottom
        anchors.bottom: parent.bottom
        contentWidth: txt.width
        contentHeight: txt.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        function ensureVisible(r)
        {
            var hg = height
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+hg <= r.y+r.height+15*physicalPlatformScale)
                contentY = r.y+r.height-hg + 15*physicalPlatformScale;
        }

        TextEdit {
            id: txt
            width: utxt_flickable.width
            height: contentHeight<utxt_flickable.height? utxt_flickable.height : contentHeight
            selectionColor: "#0d80ec"
            selectedTextColor: "#333333"
            wrapMode: Text.WordWrap
            font.family: globalTextFontFamily
            selectByMouse: true
            readOnly: true

            onCursorRectangleChanged: utxt_flickable.ensureVisible(cursorRectangle)
        }
    }

    PhysicalScrollBar {
        scrollArea: utxt_flickable; width: 8; anchors.right: parent.right; anchors.top: utxt_flickable.top;
        anchors.bottom: utxt_flickable.bottom; color: "#ffffff"
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
            text: qsTr("Check")
            onClicked: {
                Gui.openUrl("http://labs.sialan.org/projects/sigram")
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
                VersionChecker.dismiss(u_dialog.version)
                flipMenu.hide()
            }
        }
    }
}
