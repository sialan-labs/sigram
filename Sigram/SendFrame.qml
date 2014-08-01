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
    id: send_frame
    width: 100
    height: 80
    color: imageBack? "#66ffffff" : "#333333"
    clip: true

    property int current
    property bool smilies: false

    property alias textInput: input.textInput

    onCurrentChanged: {
        if( typing_state_timer.running ) {
            Telegram.setTypingState(privates.last,state)
            typing_state_timer.stop()
        }
        if( typing_send_typing.running )
            typing_send_typing.stop()

        var draft = msg_drafts.value(current)
        msg_drafts.insert(privates.last, input.text)
        input.text = draft? draft : ""
        p_bar.visible = false
        privates.last = current
    }

    QtObject {
        id: privates
        property int last: 0
    }

    HashObject {
        id: msg_drafts
    }

    Timer {
        id: typing_state_timer
        interval: 5000
        repeat: false
        onTriggered: send_frame.setNotTyping()
    }

    Timer {
        id: typing_send_typing
        interval: 2000
        onTriggered: {
            Telegram.setTypingState(typing_send_typing.current,true)
            typing_state_timer.restart()
            if( onceAgain )
                typing_send_typing.restart()

            onceAgain = false
        }

        property int current
        property bool onceAgain: false
    }

    Connections {
        target: Telegram
        onFileUploaded: {
            if( send_frame.current != user_id )
                return

            p_bar.visible = false
        }
        onFileUploading: {
            if( send_frame.current != user_id )
                return

            p_bar.visible = true
            p_bar.percent = percent

        }
    }

    TextArea {
        id: input
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: tools_column.left
        anchors.margins: 4
        font.pointSize: 9
        color: imageBack? "#000000" : "#ffffff"
        onAccepted: send_frame.send()
        onTextChanged: {
            if(text.length!=0)
                send_frame.setOnTyping()
            else
                send_frame.setNotTyping()
        }
    }

    Column {
        id: tools_column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: send_btn.left
        width: height/2

        Button {
            id: attach_btn
            width: tools_column.width
            height: width
            normalColor: "#252626"
            highlightColor: "#191A1A"
            icon: "files/attach.png"
            iconHeight: 18
            onClicked: {
                if( send_frame.current == 0 )
                    return
                var res = Telegram.sendFileDialog(send_frame.current)
                if( res ) {
                    p_bar.visible = true
                }
            }
        }

        Button {
            id: smilies_btn
            width: tools_column.width
            height: width
            normalColor: "#252626"
            highlightColor: "#191A1A"
            icon: "files/smilies.png"
            iconHeight: 18
            onClicked: send_frame.smilies = !send_frame.smilies
        }
    }

    Button {
        id: send_btn
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: height
        normalColor: "#33CCAD"
        highlightColor: "#3AE9C6"
        icon: "files/send_icon.png"
        iconHeight: 26
        onClicked: send_frame.send()
    }

    ProgressBar {
        id: p_bar
        anchors.left: parent.left
        anchors.right: tools_column.left
        anchors.bottom: parent.bottom
        height: 15
        progressColor: imageBack? "#ffffff" : "#3c3d3d"
        color: imageBack? "#66ffffff" : "#252626"
        visible: false
        onVisibleChanged: {
            if( visible )
                s_indicator.start()
            else
                s_indicator.stop()
        }
    }

    Indicator {
        id: s_indicator
        anchors.right: input.right
        anchors.top: input.top
        anchors.bottom: input.bottom
        width: 32
    }

    function send() {
        if( send_frame.current == 0 )
            return
        if( input.text.trim().length == 0 )
            return

        Telegram.sendMessage(send_frame.current,input.text.trim())
        Telegram.setStatusOnline(true)
        input.text = ""
        setNotTyping()
    }

    function setOnTyping() {
        if( typing_send_typing.running ) {
            typing_send_typing.onceAgain = true
            return
        }

        Telegram.setTypingState(send_frame.current,true)
        typing_send_typing.current = send_frame.current
        typing_send_typing.onceAgain = false
        typing_send_typing.restart()
    }

    function setNotTyping() {
        Telegram.setTypingState(send_frame.current,false)
        typing_state_timer.stop()
        typing_send_typing.stop()
    }
}
