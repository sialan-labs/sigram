import QtQuick 2.0
import AsemanTools 1.0

WebPageGrabber {
    destination: AsemanApp.homePath + "/snapshots"
    timeOut: 10000

    onFinished: {
        var method = hash.value(source)
        hash.remove(source)
        if(method)
            method(path)

        var next = list.takeFirst()
        if(!next)
            return

        source = next
        start()
    }

    ListObject {
        id: list
    }

    HashObject {
        id: hash
    }

    function addToQueue(urlStr, method) {
        var url = Tools.stringToUrl(urlStr)
        var checkPath = check(url)
        if(checkPath != "") {
            method(checkPath)
            return
        }

        hash.insert(url, method)
        if(running)
            list.append(url)
        else {
            source = url
            start()
        }
    }
}

