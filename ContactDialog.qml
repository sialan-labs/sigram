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
import org.sialan.telegram 1.0

Rectangle {
    id: contact_dialog
    width: 100
    height: 62

    property bool multiSelectMode: false

    signal selected( int uid )

    SetObject {
        id: selecteds_set
    }

    ListView {
        id: clist
        anchors.fill: parent
        model: ListModel{}
        clip: true

        delegate: Rectangle {
            id: item
            height: 57
            width: clist.width
            color: marea.pressed || item.selected? "#E65245" : "#00000000"

            property bool selected: selecteds_set.contains(user_id)

            ContactImage {
                id: contact_image
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 4
                uid: user_id
                width: height
                borderColor: "#ffffff"
                onlineState: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: contact_image.right
                anchors.leftMargin: 8
                font.pointSize: 10
                font.family: globalNormalFontFamily
                text: Telegram.contactTitle(user_id)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    if( contact_dialog.multiSelectMode ) {
                        if( selecteds_set.contains(user_id) )
                            selecteds_set.remove(user_id)
                        else
                            selecteds_set.insert(user_id)

                        item.selected = selecteds_set.contains(user_id)
                        return
                    }
                    if( forwarding != 0 ) {
                        forwardTo = user_id
                        return
                    }

                    contact_dialog.selected(user_id)
                }
            }
        }

        function refresh() {
            model.clear()
            var contacts = Telegram.contactListUsers()
            var dialogs = Telegram.dialogListIds()

            for( var i=0; i<dialogs.length; i++ ) {
                var cIndex = contacts.indexOf(dialogs[i])
                if( cIndex != -1 )
                    contacts.splice(cIndex,1)
            }
            for( var i=0; i<contacts.length; i++ ) {
                model.append( {"user_id":contacts[i]} )
                Telegram.loadUserInfo(contacts[i])
            }
        }

        function refreshAll() {
            model.clear()
            var contacts = Telegram.contactListUsers()
            for( var i=0; i<contacts.length; i++ ) {
                var cnct = contacts[i]
                if( cnct == Telegram.me )
                    continue

                model.append( {"user_id":cnct} )
                Telegram.loadUserInfo(cnct)
            }
        }
    }

    NormalWheelScroll {
        flick: clist
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 8
        anchors.right: clist.right; anchors.top: clist.top; color: "#333333"
    }

    function showFullContacts() {
        clist.refreshAll()
    }

    function showNeededContacts() {
        clist.refresh()
    }

    function selectedContacts() {
        return selecteds_set.exportIntData()
    }
}
