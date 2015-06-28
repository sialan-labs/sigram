import QtQuick 2.0
import AsemanTools 1.0
import TelegramQml 1.0
import QtQuick.Controls 1.1

AsemanMain {
    id: main
    width: AsemanApp.readSetting("General/width", 1024)
    height: AsemanApp.readSetting("General/height", 600)
    color: "#333333"
    mainFrame: main_frame
    focus: true
    masterPalette.colorGroup: SystemPalette.Active

    property variant authDialog
    property variant tabFrame

    property alias profiles: profile_model
    property alias webPageGrabber: web_grabber
    property alias mapDownloader: map_downloader

    property bool aboutMode: false

    property color backColor0: "#eeeeee"
    property color backColor1: "#cccccc"
    property color backColor2: "#fafafa"
    property color textColor0: "#111111"
    property color textColor1: "#333333"
    property color textColor2: "#888888"

    property alias titleBarColor: tbar_cgrabber.color
    property color masterColor: {
        if(!Devices.isWindows8)
            return masterPalette.highlight

        var color = titleBarColor
        var satur = Tools.colorSaturation(color)
        if(satur < 0.2)
            return masterPalette.highlight
        else
            return color
    }
    onMasterColorChanged: if(Devices.isWindows8) Cutegram.highlightColor = masterColor

    onWidthChanged: size_save_timer.restart()
    onHeightChanged: size_save_timer.restart()

    onAboutModeChanged: {
        if(aboutMode)
            BackHandler.pushHandler(about, about.back)
        else
            BackHandler.removeHandler(about)
    }

    Keys.onEscapePressed: {
        AsemanApp.back()
    }

    Keys.onPressed: {
        if(event.modifiers & Qt.ControlModifier) {
            switch(event.key) {
            case Qt.Key_Q:
                Cutegram.quit()
                break

            case Qt.Key_Tab:
                tabFrame.nextDialog()
                break

            case Qt.Key_Backtab:
                tabFrame.previousDialog()
                break
            }
        }
        else
        if(event.modifiers & Qt.AltModifier) {
            switch(event.key) {
            case Qt.Key_Up:
                tabFrame.previousDialog()
                break

            case Qt.Key_Down:
                tabFrame.nextDialog()
                break
            }
        }
    }

    TitleBarColorGrabber {
        id: tbar_cgrabber
        autoRefresh: Devices.isWindows8
        Component.onCompleted: if(Devices.isWindows8) window = View
    }

    MapDownloaderQueue {
        id: map_downloader
        destination: Devices.localFilesPrePath + AsemanApp.homePath + "/maps"
        size: Qt.size(320*Devices.density, 220*Devices.density)
        mapProvider: MapDownloader.MapProviderGoogle
        zoom: 15
    }

    WebPageGrabberQueue {
        id: web_grabber
    }

    Connections {
        target: Cutegram
        onBackRequest: AsemanApp.back()
        onAboutAsemanRequest: qlist.currentIndex = 0
    }

    Connections {
        target: AsemanApp
        onBackRequest: {
            var res = BackHandler.back()
            if( !res ) {
                if(Devices.isDesktop)
                    tabFrame.showNull()
                else
                    Cutegram.close()
            }
        }
    }

    Connections {
        target: View
        onActiveChanged: {
            if(Cutegram.closingState)
                return

            AsemanApp.setSetting("General/lastWindowState", View.active)
        }
    }

    Timer {
        id: size_save_timer
        interval: 1000
        onTriggered: {
            AsemanApp.setSetting("General/width", width)
            AsemanApp.setSetting("General/height", height)
        }
    }

    ProfilesModel {
        id: profile_model
        configPath: AsemanApp.homePath
    }

    Timer {
        id: init_timer
        interval: 1500
        Component.onCompleted: start()
        onTriggered: {
            if( profiles.count == 0 )
                qlist.currentIndex = 3
            else
                qlist.currentIndex = 2
        }
    }

    AboutCutegram {
        id: about
        anchors.fill: parent

        function back() {
            aboutMode = false
        }
    }

    Item {
        id: main_frame
        width: parent.width
        height: parent.height
        y: aboutMode? height : 0

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        QueueList {
            id: qlist
            anchors.fill: parent
            components: [aseman_about_component, splash_component, accounts_frame, auth_dlg_component]
            currentIndex: 1
            onCurrentIndexChanged: {
                prevIndex = tmpIndex
                tmpIndex = currentIndex
            }

            property int tmpIndex: 0
            property int prevIndex: 0
        }
    }

    MouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        visible: Devices.isMacX && Desktop.currentMenuObject
        onClicked: if(Desktop.currentMenuObject) Desktop.currentMenuObject.hide()
    }

    Component {
        id: auth_dlg_component
        AuthenticateDialog {
            anchors.fill: parent
            onAccepted: {
                var item = profiles.add(number)
                item.name = "AA"
                qlist.currentIndex = 2
            }
        }
    }

    Component {
        id: accounts_frame
        AccountsTabFrame {
            id: tframe
            anchors.fill: parent
            property bool onceInstance: true
            Component.onCompleted: tabFrame = tframe
        }
    }

    Component {
        id: splash_component
        CutegramSplash {
            id: splash
            anchors.fill: parent
        }
    }

    Component {
        id: aseman_about_component
        AsemanAbout {
            id: aseman_about
            anchors.fill: parent
            Component.onCompleted: BackHandler.pushHandler(aseman_about, aseman_about.back)

            function back() {
                qlist.currentIndex = qlist.prevIndex
            }
        }
    }

    Component {
        id: menubar_component
        MenuBar {
            Menu {
                title: "About"
                MenuItem { text: "About"; onTriggered: Cutegram.about() }
                MenuItem { text: "Preferences"; onTriggered: Cutegram.configure() }
            }
        }
    }

    Component {
        id: font_loader_component
        FontLoader{}
    }

    function addAccount() {
        qlist.currentIndex = 3
        BackHandler.pushHandler(main, main.backToAccounts )
    }

    function backToAccounts() {
        qlist.currentIndex = 2
        BackHandler.removeHandler(main)
    }

    Component.onCompleted: {
        if(Devices.isMacX)
            menubar_component.createObject(main)
        if(Devices.isWindows) {
            var fontsPath = AsemanApp.appPath + "/files/fonts/"
            var fonts = Tools.filesOf(fontsPath)
            for(var i=0; i<fonts.length; i++)
                font_loader_component.createObject(main, {"source": Devices.localFilesPrePath + fontsPath + fonts[i]})
        }

        Desktop.menuStyle = Cutegram.currentTheme.menuStyleSheet
    }
}
