import QtQuick 2.0
import AsemanTools 1.0

AsemanObject {
    id: dl_queue

    property alias destination: downloader.destination
    property alias size: downloader.size
    property alias mapProvider: downloader.mapProvider
    property alias zoom: downloader.zoom

    ListObject {
        id: list
    }

    HashObject {
        id: hash
    }

    MapDownloader {
        id: downloader

        onFinished: {
            var url = downloader.linkOf(currentGeo)
            var method = hash.value(url)
            hash.remove(url)
            if(method)
                method(image)

            var next = list.takeFirst()
            if(!next)
                return

            download(next)
        }
    }

    function addToQueue(geo, method) {
        var url = downloader.linkOf(geo)
        if(downloader.check(geo)) {
            method(Devices.localFilesPrePath + downloader.pathOf(geo))
            return
        }

        hash.insert(url, method)
        if(downloader.downloading)
            list.append(geo)
        else {
            downloader.download(geo)
        }
    }

    function linkOf(geo) {
        return downloader.linkOf(geo)
    }

    function webLinkOf(geo) {
        return downloader.webLinkOf(geo)
    }
}

