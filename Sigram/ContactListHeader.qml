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
    id: contact_header
    width: 100
    height: 62
    color: imageBack? "#aabbbbbb" : "#cccccc"

    signal selected( int uid )
    signal close()

    MouseArea {
        anchors.fill: parent
    }

    Button {
        id: add_btn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 42
        icon: "files/add.png"
        iconHeight: 22
        highlightColor: "#33B7CC"
        normalColor: "#bbbbbb"
        onClicked: {
            var pnt = Gui.mapToScene( add_btn, Qt.point(add_btn.width/2,add_btn.height) )
            var obj = menu.start( add_menu_component, pnt.x, pnt.y, 253, main.height - add_btn.height/2 )
            obj.selected.connect( contact_header.selected )
            obj.close.connect( contact_header.close )
        }
    }

    Button {
        id: add_contact_btn
        anchors.top: parent.top
        anchors.right: add_btn.left
        anchors.bottom: parent.bottom
        width: 42
        icon: "files/add_contact.png"
        iconHeight: 16
        highlightColor: "#33B7CC"
        normalColor: "#bbbbbb"
        onClicked: {
            var pnt = Gui.mapToScene( add_contact_btn, Qt.point(add_contact_btn.width/2,add_contact_btn.height) )
            var obj = menu.start( add_contact_coponent, pnt.x, pnt.y, 253, 280 )
            obj.close.connect( contact_header.close )
        }
    }

    Component {
        id: add_menu_component
        AddMenu {
        }
    }

    Component {
        id: add_contact_coponent
        AddContact {
        }
    }
}
