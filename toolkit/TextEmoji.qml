import QtQuick 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Base 2.0
import "../globals"
import "../thirdparty"

TextEdit {
    id: txtemoji
    textFormat: TextEdit.RichText
    readOnly: true

    property string emojiText: "Dir daram miresam sare kar 🙈🙈🙈 Okkey"

    ListObject {
        id: imgList
    }

    text: {
        var list = imgList.toList()
        for(var item in list)
            item.destroy()
        imgList.clear()

        var emoji = CutegramEmojis.parse(emojiText)

        var testString = emojiText
        testString = replaceAll(testString, "_", " ")
        testString = replaceAll(testString, CutegramEmojis.regex, "_")

        var regexIdx = -1
        var idx = emoji.indexOf("<img ")
        while(idx != -1) {
            var srcStartIdx = emoji.indexOf("src=\"", idx+4)+5
            var srcEndIdx = emoji.indexOf("\"", srcStartIdx+5)

            var link = emoji.slice(srcStartIdx, srcEndIdx)

            regexIdx = regexIndexOf(testString, "_", regexIdx+1)
            var obj = image_component.createObject(txtemoji, {"source": link, "realIndex": regexIdx})
            imgList.append(obj)

            var endIdx = emoji.indexOf(">", idx+5)+1
            emoji = emoji.slice(0, idx) + "<img width=18 height=18 src=\"file:///home/bardia/transparent/transparent.256.png\">" +
                    emoji.slice(endIdx)
            idx = emoji.indexOf("<img ", idx+5)
        }

        return emoji
    }

    function regexIndexOf(target, regex, startpos) {
        var indexOf = target.substring(startpos || 0).search(regex);
        return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
    }

    function replaceAll(target, search, replacement) {
        var result = target
        var idx = result.search(search)
        while(idx > -1) {
            result = result.replace(search, replacement)
            idx = result.search(search, idx+replacement.length)
        }
        return result
    }

    Component {
        id: image_component
        Image {
            id: img

            property int realIndex

            Connections {
                target: txtemoji
                onWidthChanged: refresh()
                onHeightChanged: refresh()
                onTextChanged: refresh()
            }

            function refresh() {
                var pos = txtemoji.positionToRectangle(realIndex)
                x = pos.x
                y = pos.y
            }
        }
    }
}

