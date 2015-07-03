import TelegramQml 1.0
import Cutegram 1.0
import QtQuick 2.0
import AsemanTools.Controls.Styles 1.0 as AsemanStyles

CutegramTheme {
    themeName: "Maman Dooz"
    author: "Bardia Daneshvar <bardia@aseman.co>"
    homePage: "http://aseman.co"

    SystemPalette {
        id: palette
        colorGroup: SystemPalette.Active
    }

    masterColor: palette.highlight
    visualEffects: false

    menuStyleSheet: ""
    buttonStyle: AsemanStyles.ButtonStyle {}
    switchStyle: AsemanStyles.SwitchStyle {}
    checkBoxStyle: AsemanStyles.CheckBoxStyle {}
    comboBoxStyle: AsemanStyles.ComboBoxStyle {}
    textFieldStyle: AsemanStyles.TextFieldStyle {}
    spinBoxStyle: AsemanStyles.SpinBoxStyle {}
    searchTextFieldStyle: AsemanStyles.TextFieldStyle {
        backgroundColor: control.focus? searchBarFocusedColor : searchBarColor
        placeholderTextColor: searchBarPlaceholderColor
    }

    dialogListBackground: "#333333"
    dialogListDateColor: "#999999"
    dialogPointerColor: "#E4E9EC"
    dialogListScrollColor: "#777777"
    dialogListScrollWidth: 6
    dialogListDateFont.pointSize: 10
    dialogListFont.pointSize: 11
    dialogPointerHeight: 16
    dialogListFontColor: "#eeeeee"
    dialogListShadowColor: "#77000000"
    dialogListShadowWidth: 3
    dialogListMessageColor: "#cccccc"
    dialogListMessageFont.pointSize: 9
    dialogListHighlightDateColor: "#999999"
    dialogListHighlightMessageColor: "#cccccc"
    dialogListHighlightTextColor: "#eeeeee"
    dialogListWidth: 275
    dialogListLightIcon: true
    dialogListHighlightColor: {
        var clr = masterColor
        var bck = Qt.rgba(0,0,0)
        var rgba = Qt.rgba((clr.r+0.5*bck.r)/1.5, (clr.g+0.5*bck.g)/1.5, (clr.b+0.5*bck.b)/1.5)
        return rgba
    }

    searchBarColor: "#000000"
    searchBarFocusedColor: "#555555"
    searchBarTextColor: "#eeeeee"
    searchBarPlaceholderColor: "#888888"
    searchBarFont.pointSize: 9

    sendFrameColor: "#f0f0f0"
    sendFrameFontColor: "#333333"
    sendFrameFontHighlightColor: "#ffffff"
    sendFrameShadowColor: "#000000"
    sendFrameShadowSize: 0.4
    sendFrameFont.pointSize: 10
    sendFrameHeight: 40
    sendFrameLightIcon: false

    sendButtonStyle: AsemanStyles.ButtonStyle {
        fontPixelSize: Math.floor(10*Devices.fontDensity)
    }
	
    messageOutgoingNameColor: masterColor
    messageOutgoingLightIcon: false
    messageOutgoingDateColor: "#555555"
    messageOutgoingFontColor: "#333333"
    messageOutgoingColor: {
        var clr = masterColor
        var bck = Qt.rgba(1,1,1)
        var rgba = Qt.rgba((clr.r+3*bck.r)/4, (clr.g+3*bck.g)/4, (clr.b+3*bck.b)/4)
        return rgba
    }
    messageIncomingNameColor: masterColor
    messageIncomingLightIcon: false
    messageIncomingDateColor: "#555555"
    messageIncomingFontColor: "#333333"
    messageIncomingColor: "#ffffff"
    messageMediaColor: "#000000"
    messageMediaDateColor: "#dddddd"
    messageMediaNameColor: masterColor
    messageMediaLightIcon: true
    messageAudioColor: "#fafafa"
    messageAudioDateColor: "#333333"
    messageAudioNameColor: masterColor
    messageAudioLightIcon: false
    messageRadius: 5
    messageShadow: true
    messageShadowSize: 2
    messageShadowColor: "#66000000"
    messagePointerHeight: 15

    headerColor: "#f0f0f0"
    headerTitleColor: "#111111"
    headerTitleFont.pointSize: 15
    headerDateColor: masterColor
    headerDateFont.pointSize: 9
    headerLightIcon: false
    headerSecretColor: "#aa000000"
    headerSecretTitleColor: "#101010"
    headerSecretTitleFont.pointSize: 15
    headerSecretDateColor: masterColor
    headerSecretDateFont.pointSize: 9
    headerSecretLightIcon: true
    headerHeight: 60

    panelColor: masterColor
    panelLightIcon: true
    panelPointerHeight: 12
    panelShadowColor: "#44111111"
    panelShadowWidth: 3
    panelTooltipBackground: "#cc000000"
    panelTooltipTextColor: "#ffffff"

    sidebarColor: "#ffffff"
    sidebarFontColor: "#333333"
    sidebarFont.pointSize: 10
    sidebarPhoneBackground: "#dddddd"
    sidebarPhoneColor: "#333333"
    sidebarPhoneFont.pointSize: 18
}
