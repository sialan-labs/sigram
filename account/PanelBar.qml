import QtQuick 2.4
import AsemanTools 1.0
import "../globals"
import "../awesome"

Rectangle {
    width: CutegramGlobals.panelWidth
    color: CutegramGlobals.baseColor

    property int currentPage: CutegramEnums.pageTypeHome
    property string selectedColor: "#66e6e6e6"

    Button {
        width: parent.width
        height: width
        normalColor: currentPage==CutegramEnums.pageTypeHome? selectedColor : "#00000000"
        highlightColor: selectedColor
        textColor: "#ffffff"
        textFont.family: Awesome.family
        textFont.pixelSize: 14*Devices.fontDensity
        text: Awesome.fa_paper_plane
        onClicked: currentPage = CutegramEnums.pageTypeHome
    }

    Column {
        width: parent.width
        anchors.bottom: parent.bottom

        Button {
            width: parent.width
            height: width
            normalColor: currentPage==CutegramEnums.pageTypeAdd? selectedColor : "#00000000"
            highlightColor: selectedColor
            textColor: "#ffffff"
            textFont.family: Awesome.family
            textFont.pixelSize: 14*Devices.fontDensity
            text: Awesome.fa_plus
            onClicked: currentPage = CutegramEnums.pageTypeAdd
        }

        Button {
            width: parent.width
            height: width
            normalColor: currentPage==CutegramEnums.pageTypeContacts? selectedColor : "#00000000"
            highlightColor: selectedColor
            textColor: "#ffffff"
            textFont.family: Awesome.family
            textFont.pixelSize: 14*Devices.fontDensity
            text: Awesome.fa_user
            onClicked: currentPage = CutegramEnums.pageTypeContacts
        }

        Button {
            width: parent.width
            height: width
            normalColor: currentPage==CutegramEnums.pageTypeConfigure? selectedColor : "#00000000"
            highlightColor: selectedColor
            textColor: "#ffffff"
            textFont.family: Awesome.family
            textFont.pixelSize: 14*Devices.fontDensity
            text: Awesome.fa_gear
            onClicked: currentPage = CutegramEnums.pageTypeConfigure
//            onClicked: CutegramGlobals.fontHandler.openFontChooser()
        }
    }
}

