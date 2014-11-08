/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Rectangle {
    id: line_edit_frame
    color: "#88eeeeee"
    height: 42*physicalPlatformScale
    width: 100*physicalPlatformScale

    property alias placeholder: pholder.text
    property alias text: main_item.text
    property alias echoMode: main_item.echoMode
    property alias lineFocus: main_item.focus

    signal accepted()

    Text {
        id: pholder
        anchors.fill: main_item
        font: main_item.font
        color: "#888888"
        visible: main_item.length == 0
        verticalAlignment: Text.AlignVCenter
    }

    STextInput {
        id: main_item
        anchors.fill: parent
        anchors.margins: 4*physicalPlatformScale
        font.pixelSize: 11*fontsScale
        font.family: SApp.globalFontFamily
        color: "#333333"
        verticalAlignment: Text.AlignVCenter
        onAccepted: line_edit_frame.accepted()
    }

    function paste() {
        main_item.paste()
    }

    function copy() {
        main_item.copy()
    }

    function cut() {
        main_item.cut()
    }
}
