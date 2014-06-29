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

Rectangle {
    id: contact_list
    width: 100
    height: 62
    color: "#ffffff"

    property int current

    Connections {
        target: Telegram
        onContactsChanged: {
            privates.contacts_refreshed = true
            clist.refresh()
        }
        onDialogsChanged: {
            privates.dialogs_refreshed = true
            clist.refresh()
        }
        onStartedChanged: {
            Telegram.updateDialogList()
            Telegram.updateContactList()
        }
        onIncomingMsg: {
            Telegram.updateDialogListUsingTimer()
        }
        onUserStatusChanged: {
            clist.refresh()
        }
        onMsgChanged: {
            Telegram.updateDialogListUsingTimer()
        }
    }

    Connections {
        target: Gui
        onLoveChanged: clist.refresh()
        onFavorited: clist.refresh()
    }

    QtObject {
        id: privates
        property bool contacts_refreshed: false
        property bool dialogs_refreshed: false
    }

    Rectangle {
        id: clist_frame
        anchors.fill: parent

        Indicator {
            id: indicator
            anchors.fill: parent
            source: "files/indicator.png"
            Component.onCompleted: start()
        }

        ListView {
            id: clist
            anchors.fill: parent
            model: ListModel{}
            header: Item{ height: cl_header.height }
            delegate: ContactListItem {
                id: item
                height: 57
                width: clist.width
                uid: user_id
                realId: item.isDialog? dialog_id : user_id
                selected: realId == contact_list.current
                onClicked: {
                    var iid = (item.isDialog? dialog_id : item.uid)
                    if( forwarding != 0 ) {
                        forwardTo = iid
                        return
                    }

                    contact_list.current = iid
                }
            }

            section.property: "type"
            section.delegate: Item {
                height: 38
                width: clist.width

                Image {
                    id: sec_img
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 10
                    anchors.bottomMargin: 4
                    width: 14
                    height: 14
                    sourceSize: Qt.size(width,height)
                    source: section==1? "files/favorite.png" : (section==0? "files/love.png" : "files/contact.png")
                }
            }

            function refresh() {
                if( !privates.contacts_refreshed || !privates.dialogs_refreshed )
                    return

                indicator.stop()
                model.clear()
                var contacts = Telegram.contactListUsers()
                var dialogs = Telegram.dialogListIds()

                for( var t=0; t<3; t++ ) {

                    for( var i=0; i<dialogs.length; i++ ) {
                        var dlg = dialogs[i]
                        var type = 2
                        if( dlg == Gui.love )
                            type = 0
                        else
                        if( Gui.isFavorited(dlg) )
                            type = 1

                        if( type != t )
                            continue

                        if( Telegram.dialogLeaved(dlg) )
                            continue
                        model.append( {"user_id": 0, "dialog_id": dlg, "type": type} )
                        if( Telegram.dialogIsChat(dlg) )
                            Telegram.loadChatInfo(dlg)
                        else
                            Telegram.loadUserInfo(dlg)
                        var cIndex = contacts.indexOf(dlg)
                        if( cIndex != -1 )
                            contacts.splice(cIndex,1)
                    }
                }

                Telegram.loadUserInfo(Telegram.me)
            }

            Component.onCompleted: refresh()
        }

        NormalWheelScroll {
            flick: clist
        }

        PhysicalScrollBar {
            scrollArea: clist; height: clist.height; width: 8
            anchors.right: clist.right; anchors.top: clist.top; color: "#333333"
            anchors.topMargin: cl_header.height
        }
    }

    Item {
        id: header_blur_frame
        anchors.fill: cl_header
        clip: true

        Mirror {
            width: clist_frame.width
            height: clist_frame.height
            anchors.top: parent.top
            source: clist_frame
        }
    }

    ContactListHeader {
        id: cl_header
        height: 53
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        onSelected: {
            cnct_change_timer.uid = uid
            cnct_change_timer.restart()
            menu.stop()
        }
        onClose: {
            menu.stop()
        }

        Timer {
            id: cnct_change_timer
            interval: 400
            repeat: false
            onTriggered: {
                contact_list.current = uid
                chatFrame.chatView.progressIndicator.stop()
            }
            property int uid
        }
    }
}
