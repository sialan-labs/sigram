import QtQuick 2.4
import AsemanTools 1.0
import TelegramQml 2.0 as Telegram
import QtGraphicalEffects 1.0
import "../awesome"
import "../toolkit" as ToolKit
import "messageitems" as MessageItems
import "../globals"

Item {
    id: msgList

    property alias engine: mlmodel.engine
    property alias currentPeer: mlmodel.currentPeer
    property alias model: mlmodel

    property alias refreshing: mlmodel.refreshing

    readonly property bool forwarding: fwdArea.messages.length != 0

    signal replyRequest(variant peer, variant message)

    Connections {
        target: CutegramGlobals.mainWindow
        onActiveChanged: if(CutegramGlobals.mainWindow.active && mlmodel.currentPeer) mlmodel.markAsRead()
    }

    Telegram.MessageListModel {
        id: mlmodel
        limit: 50
        dateConvertorMethod: function(date) {
            var hours = date.getHours()
            if(hours < 10)
                hours = "0" + hours

            var minutes = date.getMinutes()
            if(minutes < 10)
                minutes = "0" + minutes

            return hours + ":" + minutes
        }
        onCountChanged: if(count && CutegramGlobals.mainWindow.active) markAsRead()
        onIsEmptyChanged: {
            if(focusAfterLoaded || isEmpty) return
            listv.positionViewAtBeginning()
            Tools.jsDelayCall(1000, function(){
                if(focusAfterLoaded) return
                listv.positionViewAtBeginning()
            })
        }
        onCurrentPeerChanged: selectedsHash.clear()
        onErrorChanged: errorItem.showError(errorCode, errorText)
        onRefreshingChanged: {
            if(focusAfterLoaded && !refreshing) {
                Tools.jsDelayCall(100, function(){
                    var idx = mlmodel.indexOf(Telegram.MessageListModel.RoleMessageItem, focusAfterLoaded)
                    if(idx) listv.positionViewAtIndex(idx, ListView.Center)
                    Tools.jsDelayCall(1000, function(){
                        focusAfterLoaded = null
                    })
                })
            }
        }

        property variant focusAfterLoaded
    }

    QtObject {
        id: loadHandler

        property real scrollY: listv.visibleArea.yPosition*listv.contentHeight
        property bool proximateEnd: (scrollY<listv.height && listv.contentHeight>listv.height*2 && listv.height>0)
        property bool proximateBegin: (scrollY>(listv.contentHeight-listv.height*1.5) && listv.contentHeight>listv.height*2 && listv.height>0)

        onProximateEndChanged: if(proximateEnd) mlmodel.loadBack()
    }

    HashObject {
        id: selectedsHash

        function msgIds() {
            var kys = selectedsHash.keys()
            var res = new Array
            for(var i=0; i<kys.length; i++)
                res[i] = Math.floor(kys[i])
            return res
        }
    }

    ListView {
        id: listv
        anchors.fill: parent
        verticalLayoutDirection: ListView.BottomToTop
        model: mlmodel
        displayMarginBeginning: 100*Devices.density
        displayMarginEnd: 100*Devices.density
        highlightMoveDuration: 300
        highlightMoveVelocity: -1
        move: Transition {
            NumberAnimation { properties: "y"; easing.type: Easing.OutCubic; duration: 300 }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; easing.type: Easing.OutCubic; duration: 300 }
        }
        add: Transition {
            NumberAnimation { properties: "y"; easing.type: Easing.OutCubic; duration: 300 }
            NumberAnimation { properties: "scale"; from: 1.2; to: 1; easing.type: Easing.OutCubic; duration: 300 }
        }
        remove: Transition {
            NumberAnimation { properties: "scale"; from: 1; to: 0.5; easing.type: Easing.OutCubic; duration: 300 }
            NumberAnimation { properties: "opacity"; from: 1; to: 0; easing.type: Easing.OutCubic; duration: 300 }
        }
        maximumFlickVelocity: View.flickVelocity
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }
        delegate: MessageListDelegate {
            width: listv.width
            maximumHeight: listv.height*0.8
            maximumWidth: listv.width*0.7
            messagesModel: mlmodel
            view: listv

            Connections {
                target: selectedsHash
                onCountChanged: if(messageItem) selected = selectedsHash.contains(messageItem.id)
            }

            Rectangle {
                anchors.fill: parent
                z: -1
                color: "#ff0000"
                opacity: mlmodel.focusAfterLoaded == messageItem && enable? 0.2 : 0

                Behavior on opacity {
                    NumberAnimation{easing.type: Easing.OutCubic; duration: 1000}
                }

                property bool enable: false
                Component.onCompleted: enable = true
            }

            onSelectedChanged: {
                if(selected)
                    selectedsHash.insert(messageItem.id, null)
                else
                    selectedsHash.remove(messageItem.id)
            }
            onForwardRequest: {
                selectedsHash.clear()
                selected = true
                optionBar.forwardRequest()
            }
            onReplyRequest: msgList.replyRequest(currentPeer, messageItem)

            Component.onCompleted: selected = selectedsHash.contains(messageItem.id)
        }

        section.property: "date"
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            width: listv.width
            height: available? 36*Devices.density : 0

            property bool available: {
                var d = new Date();
                var curr_day = d.getDate()
                if(curr_day < 10) curr_day = "0" + curr_day
                var curr_month = d.getMonth() + 1
                if(curr_month < 10) curr_month = "0" + curr_month
                var curr_year = d.getFullYear()
                var curr_string = curr_year + "-" + curr_month + "-" + curr_day

                return (curr_string != section)
            }

            Rectangle {
                color: "#55000000"
                width: txt.width + 16*Devices.density
                height: txt.height + 16*Devices.density
                radius: 5*Devices.density
                anchors.centerIn: parent
                visible: available

                Text {
                    id: txt
                    anchors.centerIn: parent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 9*Devices.fontDensity
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "#ffffff"
                    text: section
                }
            }
        }

        header: TypingUsersArea {
            typingUsers: mlmodel.typingUsers
        }
    }

    Rectangle {
        width: parent.width
        height: selectedsHash.count? optionBar.height : 0
        color: Qt.lighter(CutegramGlobals.titleBarColor, 1.05)

        Behavior on height {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 250}
        }

        MessagesOptionBar {
            id: optionBar
            width: parent.width
            anchors.bottom: parent.bottom
            selectedCount: selectedsHash.count
            onClearRequest: selectedsHash.clear()
            onDeleteRequest: {
                mlmodel.deleteMessages(selectedsHash.msgIds())
                selectedsHash.clear()
            }
            onForwardRequest: {
                fwdArea.messages = selectedsHash.msgIds()
                fwdArea.fromPeer = mlmodel.currentPeer
                selectedsHash.clear()
            }
        }
    }

    Button {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10*Devices.density
        radius: width/2
        height: 48*Devices.density
        width: height
        normalColor: "#ccffffff"
        highlightColor: "#eeffffff"
        textColor: "#666666"
        textFont.family: Awesome.family
        textFont.pixelSize: 12*Devices.fontDensity
        visible: !loadHandler.proximateBegin && listv.contentHeight>listv.height
        text: Awesome.fa_arrow_down
        onClicked: listv.positionViewAtBeginning()
    }

    NormalWheelScroll {
        flick: listv
    }

    PhysicalScrollBar {
        anchors.right: listv.right
        height: listv.height
        width: 6*Devices.density
        color: CutegramGlobals.baseColor
        scrollArea: listv
    }

    ToolKit.ErrorItem {
        id: errorItem
    }

    MessageForwardArea {
        id: fwdArea
        anchors.fill: parent
        engine: mlmodel.engine
        currentPeer: mlmodel.currentPeer
    }

    function forward() {
        var messages = fwdArea.messages
        messages.sort()
        mlmodel.forwardMessages(fwdArea.fromPeer, messages)
        fwdArea.discard()
    }

    function forwardMessages(inputPeer, msgIds) {
        mlmodel.forwardMessages(inputPeer, msgIds)
    }

    function sendDocument(path) {
        var mime = Tools.fileMime(path)
        var type = Telegram.Enums.SendFileTypeDocument
        if(mime.indexOf("video")>=0)
            type = Telegram.Enums.SendFileTypeVideo
        else
        if(mime.indexOf("audio")>=0)
            type = Telegram.Enums.SendFileTypeDocument
        else
        if(mime.indexOf("webp")>=0)
            type = Telegram.Enums.SendFileTypeSticker

        return mlmodel.sendFile(type, path)
    }

    function sendPhoto(path) {
        return mlmodel.sendFile(Telegram.Enums.SendFileTypePhoto, path)
    }

    function loadFrom(message) {
        mlmodel.focusAfterLoaded = message
        mlmodel.loadFrom(message.id)
    }

    function forwardDialog(msgIds) {
        selectedsHash.clear()

        for(var i=0; i<msgIds.length; i++)
            selectedsHash.insert(msgIds[i], null)

        optionBar.forwardRequest()
    }
}

