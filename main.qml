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

import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Window {
    id: main
    visible: Gui.visible
    width: Gui.width
    height: Gui.height

    property real physicalPlatformScale: 1
    property real fontsScale: 1
    property string globalNormalFontFamily: "Open Sans"
    property string globalTextFontFamily: "Droid Arabic Naskh"

    property bool imageBack: Gui.background.length != 0

    property alias current: chat_frame.current
    property bool about: false
    property bool aboutSialan: false

    property alias menu: mnu_item
    property alias mainFrame: main_frame
    property alias chatFrame: chat_frame
    property alias flipMenu: flip_menu

    property alias focus: main_frame.focus

    property int forwarding: 0
    property int forwardTo: 0

    property variant auth_object

    Connections {
        target: Telegram
        onStartedChanged: status_changer.restart()
        onAuthenticatingChanged: {
            if(Telegram.authenticating)
                startAuthenticating()
            else
            if( auth_object ) {
                auth_object.destroy()
                Gui.firstTime = false
            }
        }
    }
    Connections {
        target: VersionChecker
        onUpdateAvailable: {
            var obj = flipMenu.show(update_component)
            obj.version = version
            obj.text = info
        }
    }

    Component {
        id: font_loader
        FontLoader {}
    }


    onWidthChanged: Gui.width = width
    onHeightChanged: Gui.height = height
    onVisibleChanged: {
        Gui.visible = visible
        status_changer.restart()
    }

    onActiveChanged: status_changer.restart()

    Component.onCompleted: {
        var fonts = Gui.fonts()
        for( var i=0; i<fonts.length; i++ ) {
            var obj = font_loader.createObject(main)
            obj.source = "file://" + fonts[i]
        }

        if( Telegram.authenticating || Gui.firstTime )
            startAuthenticating()
        if( Gui.donate && !Gui.donateViewShowed ) {
            Gui.donateViewShowed = true
            showDonate()
        }
    }

    Component {
        id: auth_component
        StartPage {
            anchors.fill: parent
        }
    }

    AboutSialan {
        anchors.fill: parent
        start: aboutSialan
    }

    About {
        y: aboutSialan? main.height : 0
        width: parent.width
        height: parent.height
        color: "#0d80ec"

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    Rectangle {
        id: main_frame
        y: about || aboutSialan? main.height : 0
        width: parent.width
        height: parent.height
        color: "#4098BF"

        Keys.onEscapePressed: {
            if( aboutSialan )
                aboutSialan = false
            else
            if( about )
                about = false
            else
            if( flipMenu.start )
                flipMenu.hide()
        }

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        ChatFrame {
            id: chat_frame
            width: parent.width
            height: parent.height
        }

        FlipMenu {
            id: flip_menu
            anchors.fill: chat_frame
        }
    }

    MenuWindow {
        id: mnu_item
        anchors.fill: parent
    }

    Timer {
        id: status_changer
        interval: 1
        repeat: false
        onTriggered: refreshStatus()
    }

    Component {
        id: update_component
        UpdateDialog {
            width: 375
        }
    }

    Component {
        id: license_component
        LicensePage {
            width: 500
        }
    }

    Component {
        id: donate_component
        DonatePage {
            width: 500
        }
    }

    function showLicense() {
        flipMenu.show(license_component)
    }

    function showDonate() {
        flipMenu.show(donate_component)
    }

    function refreshStatus() {
        if( !Telegram.started )
            return

        Telegram.setStatusOnline( visible )
        if( visible )
            Telegram.markRead(current)
    }

    function sendNotify( msg_id ) {
        if( Telegram.messageUnread(msg_id) !== 1 )
            return

        Gui.sendNotify(msg_id)
    }

    function showMyConfigure() {
        chatFrame.chatView.showConfigure(Telegram.me)
    }

    function startAuthenticating() {
        if( auth_object )
            return

        Gui.firstTime = true
        auth_object = auth_component.createObject(main)
    }
}
