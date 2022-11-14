import QtQuick 2.4
import "../thirdparty"

QtObject {
    property string base: Qt.resolvedUrl("twemoji/")
    property string ext: ".png"
    property string size: "72x72"
    property string className: "emoji"

    function parse(text) {
        Twemoji.twemoji.base = base
        Twemoji.twemoji.ext = ext
        Twemoji.twemoji.size = size
        Twemoji.twemoji.className = className

        var res = Twemoji.twemoji.parse(text)
        while(res.indexOf("\n") >= 0)
            res = res.replace("\n", "<br />")
        return res
    }

    function test(text) {
        return Twemoji.twemoji.test(text)
    }

    function fromCodePoint(str) {
        return Twemoji.twemoji.convert.fromCodePoint(str)
    }

    function toCodePoint(str) {
        return Twemoji.twemoji.convert.toCodePoint(str)
    }
}

