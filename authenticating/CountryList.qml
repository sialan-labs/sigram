import QtQuick 2.4
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import "../awesome"
import "../globals"

Item {
    property string currentCode

    CountriesModel {
        id: cmodel
        filter: search.text
        onCountChanged: refresh()
        Component.onCompleted: listv.currentIndex = indexOf(systemCountry)
    }

    Item {
        id: search_bar
        height: 32*Devices.density
        width: parent.width

        TextInput {
            id: search
            anchors.fill: parent
            anchors.leftMargin: 10*Devices.density
            anchors.rightMargin: anchors.leftMargin
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            selectionColor: CutegramGlobals.baseColor
            selectedTextColor: "#ffffff"
            font.pixelSize: 9*Devices.fontDensity
            color: "#333333"
            Keys.onEscapePressed: BackHandler.back()

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 9*Devices.fontDensity
                color: "#aaaaaa"
                visible: parent.text.length == 0
                text: qsTr("Search")
            }

            CursorShapeArea {
                cursorShape: Qt.IBeamCursor
                anchors.fill: parent
            }
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: y
            font.family: Awesome.family
            font.pixelSize: 10*Devices.fontDensity
            text: Awesome.fa_search
            color: CutegramGlobals.baseColor
        }
    }

    Rectangle {
        id: search_bar_separator
        anchors.top: search_bar.bottom
        height: 1*Devices.density
        width: parent.width
        color: "#c6c6c6"
    }

    Timer {
        id: init_timer
        interval: 1000
        repeat: false
        Component.onCompleted: start()
    }

    AsemanListView {
        id: listv
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.top: search_bar_separator.bottom
        highlightMoveDuration: 0
        model: cmodel
        clip: true
        currentIndex: -1
        highlightRangeMode: init_timer.running? ListView.ApplyRange : ListView.NoHighlightRange
        preferredHighlightBegin: height*0.2
        preferredHighlightEnd: preferredHighlightBegin
        onCurrentIndexChanged: refresh()
        delegate: Item {
            width: listv.width
            height: 32*Devices.density

            Text {
                anchors.verticalCenter: parent.verticalCenter
                x: y
                color: "#333333"
                font.pixelSize: 9*Devices.fontDensity
                text: model.name
            }

            MouseArea {
                anchors.fill: parent
                onClicked: listv.currentIndex = index
            }
        }

        highlight: Rectangle {
            width: listv.width
            height: 32*Devices.density
            color: "#f7f7f7"
        }
    }

    NormalWheelScroll {
        flick: listv
    }

    PhysicalScrollBar {
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.right: listv.right; anchors.top: listv.top; color: "#777777"
    }

    function refresh() {
        var res = cmodel.get(listv.currentIndex, CountriesModel.CallingCodeRole)
        if(res)
            currentCode = res
        else
            currentCode = ""
    }
}

