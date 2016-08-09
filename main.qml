import QtQuick 2.3
import AsemanTools 1.0
import "app" as App

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
            var component = Qt.createComponent("app/AppMain.qml");
            appMain - component.createObject(app)
        }
    }
}

