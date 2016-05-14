pragma Singleton
import QtQuick 2.4

QtObject {
    readonly property int dialogsCategoryEmpty: 0
    readonly property int dialogsCategoryFavorite: 64
    readonly property int dialogsCategoryLove: 128

    readonly property int dragDataTypeExternal: 0
    readonly property int dragDataTypeMessage: 1
    readonly property int dragDataTypeContact: 2


    readonly property string dragDataMessageMsgId: "cutegram/msgId"
    readonly property string dragDataMessageChannelId: "cutegram/fromChannelId"
    readonly property string dragDataMessageUserId: "cutegram/fromUserId"
    readonly property string dragDataMessageChatId: "cutegram/fromChatId"
    readonly property string dragDataMessageClassType: "cutegram/fromClassType"
    readonly property string dragDataMessageAccessHash: "cutegram/fromAccessHash"


    readonly property int pageTypeHome: 0
    readonly property int pageTypeAdd: 1
    readonly property int pageTypeContacts: 2
    readonly property int pageTypeConfigure: 3


    readonly property int windowStateAuto: 0
    readonly property int windowStateVisible: 1
    readonly property int windowStateHidden: 2


    readonly property int trayIconStyleAuto: 0
    readonly property int trayIconStyleDark: 1
    readonly property int trayIconStyleLight: 2
}

