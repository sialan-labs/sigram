import QtQuick 2.0
import QtQuick.Window 2.0
import AsemanTools 1.0
import TelegramQml 1.0

Window {
    id: recorder_item
    width: 350*Devices.density
    height: 200*Devices.density
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    x: View.x + View.width/2 - width/2
    y: View.y + View.height/2 - height/2

    property alias currentPath: converter.destination

    signal selected(string path)

    Rectangle {
        anchors.fill: parent
        color: "#fafafa"
    }

    AudioEncoderSettings {
        id: encoder_settings
        codec: "audio/vorbis"
        quality: AudioEncoderSettings.HighQuality
    }

    MP3ConverterEngine {
        id: converter
        source: currentPath
        onFinished: Cutegram.deleteFile(converter.source)
    }

    AudioRecorder {
        id: recorder
        encoderSettings: encoder_settings
        output: Devices.localFilesPrePath + converter.source

        property bool recording: state == AudioRecorder.RecordingState

        onRecordingChanged: {
            if(recording)
                timer.startTimer()
            else
                timer.stop()
        }

        function refreshPath() {
            var guid = Tools.createUuid()
            guid = guid.slice(1, guid.length-1)
            var audiosPath = AsemanApp.homePath + "/audios"

            Tools.mkDir(audiosPath)

            converter.source = audiosPath + "/" + guid + ".ogg"
            converter.destination = audiosPath + "/" + guid + ".mp3"
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        onTriggered: counter++

        property int counter

        function startTimer() {
            counter = 0
            restart()
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 8*Devices.density

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#333333"
            font.pixelSize: 60*Devices.fontDensity
            font.family: AsemanApp.globalFont.family
            visible: record_btn.visible
            text: {
                var second = timer.counter%60
                var minute = Math.floor(timer.counter/60)
                return (minute<10? "0"+minute : minute) + ":" + (second<10? "0"+second : second)
            }
        }

        MediaPlayerItem {
            anchors.horizontalCenter: parent.horizontalCenter
            width: recorder_item.width - 20*Devices.density
            visible: !record_btn.visible
            filePath: currentPath.length!=0? Devices.localFilesPrePath + currentPath : ""
        }

        Row {
            spacing: 2*Devices.density
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                width: 100*Devices.density
                radius: 4*Devices.density
                normalColor: "#0d80ec"
                highlightColor: Qt.darker(normalColor)
                textColor: "#ffffff"
                text: qsTr("Send")
                cursorShape: Qt.PointingHandCursor
                visible: !record_btn.visible
                onClicked: {
                    recorder_item.selected(currentPath)
                    currentPath = ""
                }
            }

            Button {
                width: 100*Devices.density
                radius: 4*Devices.density
                highlightColor: Qt.darker(normalColor)
                normalColor: "#C81414"
                textColor: "#ffffff"
                text: qsTr("Cancel")
                cursorShape: Qt.PointingHandCursor
                visible: !record_btn.visible
                onClicked: {
                    Cutegram.deleteFile(currentPath)
                    currentPath = ""
                }
            }

            Button {
                id: record_btn
                width: 100*Devices.density
                radius: 4*Devices.density
                highlightColor: Qt.darker(normalColor)
                normalColor: "#C81414"
                textColor: "#ffffff"
                text: {
                    if(error)
                        return qsTr("Error")
                    else
                    if(converter.running)
                        return ""
                    else
                    if(recorder.recording)
                        return qsTr("Stop")
                    else
                        return qsTr("Record")
                }
                cursorShape: Qt.PointingHandCursor
                visible: currentPath.length == 0 || recorder.recording || error || converter.running
                onClicked: {
                    if(error) {
                        virtualRecordFlag = false
                        currentPath = ""
                        return
                    }

                    virtualRecordFlag = !virtualRecordFlag
                    if(recorder.recording) {
                        recorder.stop()
                        converter.start()
                    } else {
                        recorder.refreshPath()
                        recorder.record()
                    }
                }

                property bool virtualRecordFlag: false
                property bool error: virtualRecordFlag != recorder.recording

                Indicator {
                    anchors.centerIn: parent
                    light: true
                    modern: true
                    indicatorSize: 20*Devices.density
                    property bool active: converter.running

                    onActiveChanged: {
                        if( active )
                            start()
                        else
                            stop()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        x = View.x + View.width/2 - width/2
        y = View.y + View.height/2 - height/2
    }
}

