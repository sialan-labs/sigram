import TelegramQml 1.0
import QtQuick 2.0
import Cutegram 1.0
import AsemanTools.Controls.Styles 1.0 as AsemanStyles

CutegramTheme {
    themeName: "Telegram"
    author: "Vladimir Pankratov <scriptkid@mail.ru>"
    homePage: ""

    SystemPalette {
        id: palette
        colorGroup: SystemPalette.Active
    }

    masterColor: Cutegram.highlightColor
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
        borderColor: control.focus? "#80cff9" : searchBarColor
        borderRadius: 0
        shadowColor: "#ffffff"		
    }

    dialogListBackground: "#ffffff"
    dialogListDateColor: "#777777"
    dialogPointerColor: "#E4E9EC"
    dialogListScrollColor: "#000000"
    dialogListScrollWidth: 6
    dialogListDateFont.pointSize: 9
    dialogListFont.pointSize: 11
    dialogPointerHeight: 16
    dialogListFontColor: "#222222"
    dialogListShadowColor: "#aa000000"
    dialogListShadowWidth: 1
    dialogListMessageColor: "#888888"
    dialogListMessageFont.pointSize: 10
    dialogListHighlightDateColor: "#ffffff"
    dialogListHighlightMessageColor: "#ffffff"
    dialogListHighlightTextColor: "#ffffff"
    dialogListWidth: 275
    dialogListLightIcon: false
    dialogListHighlightColor: "#6a91b1"

    searchBarColor: "#f2f2f2"
    searchBarFocusedColor: "#ffffff"
    searchBarTextColor: "#333333"
    searchBarPlaceholderColor: "#888888"
    searchBarFont.pointSize: 9

    sendFrameColor: "#ffffff"
    sendFrameFontColor: "#333333"
    sendFrameFontHighlightColor: "#ffffff"
    sendFrameShadowColor: "#ffffff"
    sendFrameShadowSize: 0
    sendFrameFont.pointSize: 10
    sendFrameHeight: 40
    sendFrameLightIcon: false

    sendButtonStyle: AsemanStyles.ButtonStyle {
        buttonColor: "#ffffff"
        buttonTextColor: "#0080c0"
        shadowColor: "#ffffff"
        fontPixelSize: Math.floor(13*Devices.fontDensity)	    
    }		
	
    messageOutgoingNameColor: masterColor
    messageOutgoingLightIcon: false
    messageOutgoingDateColor: "#6cc264"
    messageOutgoingFontColor: "#333333"
    messageOutgoingColor: "#effdde"
	
    messageIncomingNameColor: masterColor
    messageIncomingLightIcon: false
    messageIncomingDateColor: "#a0acb6"
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
    messageRadius: 0
    messageShadow: true
    messageShadowSize: 2
    messageShadowColor: "#66000000"
    messagePointerHeight: 15

    headerColor: "#ffffff"
    headerTitleColor: "#111111"
    headerTitleFont.pointSize: 15
    headerDateColor: masterColor
    headerDateFont.pointSize: 9
    headerLightIcon: false
    headerSecretColor: "#101010"
    headerSecretTitleColor: "#eeeeee"
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
