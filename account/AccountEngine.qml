import QtQuick 2.4
import TelegramQml 2.0 as Telegram
import AsemanTools 1.0 as Aseman
import "../globals"

Telegram.Engine {
    id: tgEngine
    logLevel: Telegram.Engine.LogLevelClean
    configDirectory: CutegramGlobals.profilePath

    app.appId: 13682
    app.appHash: "de37bcf00f4688de900510f4f87384bb"

    host.hostDcId: 2
    host.hostAddress: "149.154.167.50"
    host.hostPort: 443

    cache.path: CutegramGlobals.profilePath + "/" + phoneNumber + "/cache"
    cache.encryptMethod: encr.encrypt
    cache.decryptMethod: encr.decrypt

    authStore.writeMethod: function(data) { return keychain.writeData(authKey, data) }
    authStore.readMethod: function() { return keychain.readData(authKey) }

    readonly property string authKey: "auth/" + phoneNumber

    Aseman.Encrypter {
        id: encr
    }

    Aseman.Keychain {
        id: keychain
        service: "Cutegram"
        Component.onCompleted: {
            var key = read("encryptKey")
            if(key.length == 0) {
                key = Aseman.Tools.createUuid()
                write("encryptKey", key)
            }
            encr.key = key
        }
    }
}

