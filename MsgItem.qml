import QtQuick 2.0

Item {
    id: item
    width: 100
    height: msg_row.height + itemMargins*4

    property bool out: Telegram.messageOut(msg_id)
    property int unread: Telegram.messageUnread(msg_id)
    property int unsent: msg_id < 0

    property int msg_id

    property real itemMargins: 10

    signal contactSelected( int uid )

    Connections {
        target: Telegram
        onMsgChanged: {
            if( msg_id != msg_id )
                return

            item.unread = Telegram.messageUnread(msg_id)
        }
    }

    Row {
        id: msg_row
        layoutDirection: item.out? Qt.RightToLeft : Qt.LeftToRight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: msg_column.height
        y: item.itemMargins
        spacing: 30

        ContactImage {
            id: img
            width: 64
            height: width
            smooth: true
            borderColor: "#222222"
            uid: Telegram.messageFromId(msg_id)
            onlineState: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: item.contactSelected(img.uid)
            }
        }

        Item {
            id: frame
            width: msg_column.width + 2*itemMargins
            height: msg_column.height + 2*itemMargins

            MsgPointCanvas {
                id: msg_point
                fillColor: item.out? "#2DA1B3" : "#CCCCCC"
                x: item.out? frame.width - width/2 : -width/2
                y: img.height/2 - height/2
            }

            Rectangle {
                anchors.fill: parent
                color: item.out? "#33B7CC" : "#E6E6E6"
            }

            Column {
                id: msg_column
                width: maxWidth
                x: itemMargins
                y: itemMargins
                spacing: 5

                property real maxWidth: Math.max( msg_details.width, Math.max(txt.width,(media.visible?media.width:user.width) ) )

                Text {
                    id: user
                    font.pointSize: 8
                    font.family: globalTextFontFamily
                    text: Telegram.messageFromName( msg_id )
                    color: item.out? "#ffffff" : "#333333"
                }

                Text {
                    id: txt
                    wrapMode: Text.WordWrap
                    width: msgWidth>item.width*0.6? item.width*0.6 : msgWidth
                    text: Emojis.textToEmojiText( Telegram.messageBody(msg_id) )
                    color: item.out? "#ffffff" : "#333333"
                    font.family: globalTextFontFamily
                    font.pointSize: 9
                    textFormat: Text.StyledText
                    visible: text.length != 0

                    property real msgWidth: Telegram.messageBodyTextWidth(msg_id)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: item.showMenu()
                    }
                }

                MsgMedia {
                    id: media
                    height: 192
                    width: 192
                    msgId: msg_id
                    visible: !txt.visible
                }

                Row {
                    id: msg_details
                    height: 10
                    anchors.right: parent.right
                    layoutDirection: Qt.RightToLeft
                    spacing: 5

                    Item {
                        id: state_indict
                        width: 12
                        height: 8
                        anchors.verticalCenter: parent.verticalCenter
                        visible: item.out

                        Image {
                            id: seen_indict
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: 8
                            height: width
                            visible: item.unread != 1 && item.out
                            source: "files/sent.png"
                            sourceSize: Qt.size(width,height)
                        }

                        Image {
                            id: sent_indict
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            width: 8
                            height: width
                            visible: !item.unsent && item.out
                            source: "files/sent.png"
                            sourceSize: Qt.size(width,height)
                        }

                        Indicator {
                            id: idct
                            anchors.fill: parent
                            indicatorSize: 12
                            visible: !seen_indict.visible && !sent_indict.visible && item.out
                            onVisibleChanged: {
                                if( visible )
                                    start()
                                else
                                    stop()
                            }
                        }
                    }

                    Text {
                        id: msg_date
                        color: item.out? "#ffffff" : "#333333"
                        anchors.verticalCenter: parent.verticalCenter
                        text: Telegram.convertDateToString( Telegram.messageDate(msg_id) )
                    }
                }
            }
        }
    }

    function showMenu() {
        var acts = [ qsTr("Copy") ]

        var res = Gui.showMenu( acts )
        switch( res ) {
        case 0:
            Gui.copyText( txt.text )
            break;
        }
    }
}
