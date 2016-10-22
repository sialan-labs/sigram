import QtQuick 2.3
import AsemanTools 1.0
import QtQuick.Dialogs 1.1

AsemanApplication {
    id: app
    applicationName: "Cutegram"
    applicationDisplayName: "Cutegram"
    applicationVersion: "2.9.5"
    applicationId: "a584f4cd-5f3b-4030-8486-cb9441563da8"
    organizationName: "Aseman"
    organizationDomain: "land.aseman"

    property variant appMain

    Component.onCompleted: {
        if(app.isRunning) {
            console.debug("Another instance is running. Trying to make that visible...")
            Tools.jsDelayCall(1, function(){
                app.sendMessage("show")
                app.exit(0)
            })
        } else {
            var component = Qt.createComponent("app/AppMain.qml", Component.Asynchronous);
            var callback = function(){
                if(component.status == Component.Ready)
                    appMain = component.createObject(app)
                else if(component.status == Component.Error) {
                    console.error(component.errorString())
                    errorDialog.informativeText = component.errorString()
                    errorDialog.setVisible(true)
                }
            }
            component.statusChanged.connect(callback)
            callback()
        }
    }

    MessageDialog {
        id: errorDialog
        title: "Fatal Error"
        text: "Cutegram could not be started. Additional information:"
        onAccepted: app.exit(1)
    }
}
