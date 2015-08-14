TEMPLATE = lib
TARGET = AsemanToolsQml
QT += qml quick
CONFIG += qt plugin
DESTDIR = build/qml/AsemanTools

TARGET = $$qtLibraryTarget($$TARGET)
uri = AsemanTools

DEFINES += ASEMAN_QML_PLUGIN

android {
    manifest.source = android-build
    manifest.target = .
    COPYFOLDERS += manifest

    QT += androidextras
    SOURCES += \
        asemanjavalayer.cpp \
        asemanandroidservice.cpp

    HEADERS += \
        asemanjavalayer.h \
        asemanandroidservice.h
} else {
    ios {

    } else {
        contains(BUILD_MODE,ubuntutouch) {
            DEFINES += Q_OS_UBUNTUTOUCH
        } else {
            QT += widgets

            HEADERS += \
                qtsingleapplication/qtsinglecoreapplication.h \
                qtsingleapplication/qtsingleapplication.h \
                qtsingleapplication/qtlockedfile.h \
                qtsingleapplication/qtlocalpeer.h

            SOURCES += \
                qtsingleapplication/qtsinglecoreapplication.cpp \
                qtsingleapplication/qtsingleapplication.cpp \
                qtsingleapplication/qtlockedfile.cpp \
                qtsingleapplication/qtlocalpeer.cpp

            win32: SOURCES += qtsingleapplication/qtlockedfile_win.cpp
            unix:  SOURCES += qtsingleapplication/qtlockedfile_unix.cpp
        }
    }
}

QML_IMPORT_PATH = \
    qml/

contains(QT,macextras) {
    SOURCES += private/asemanmactaskbarbuttonengine.cpp
    HEADERS += private/asemanmactaskbarbuttonengine.h
}
contains(QT,winextras) {
    SOURCES += private/asemanwintaskbarbuttonengine.cpp
    HEADERS += private/asemanwintaskbarbuttonengine.h
}
contains(QT,sensors) {
    DEFINES += ASEMAN_SENSORS
    SOURCES += asemansensors.cpp
    HEADERS += asemansensors.h
}
contains(QT,widgets) {
    DEFINES += NATIVE_ASEMAN_NOTIFICATION
    SOURCES +=  \
        asemannativenotification.cpp \
        asemannativenotificationitem.cpp
    HEADERS +=  \
        asemannativenotification.h \
        asemannativenotificationitem.h
}
contains(QT,multimedia) {
    DEFINES += ASEMAN_MULTIMEDIA
    SOURCES +=  \
        asemanaudiorecorder.cpp \
        asemanaudioencodersettings.cpp
    HEADERS +=  \
        asemanaudiorecorder.h \
        asemanaudioencodersettings.h
}
contains(QT,webkitwidgets) {
    DEFINES += ASEMAN_WEBKIT
}
contains(QT,webenginewidgets) {
    DEFINES += ASEMAN_WEBENGINE
}
linux|openbsd {
contains(QT,dbus) {
    DEFINES += LINUX_NATIVE_ASEMAN_NOTIFICATION
    SOURCES += asemanlinuxnativenotification.cpp \
        private/asemanunitytaskbarbuttonengine.cpp
    HEADERS += asemanlinuxnativenotification.h \
        private/asemanunitytaskbarbuttonengine.h
}
}
macx {
    DEFINES += MAC_NATIVE_ASEMAN_NOTIFICATION
    SOURCES += asemanmacnativenotification.cpp
    HEADERS += asemanmacnativenotification.h
}

SOURCES += \
    asemandevices.cpp \
    asemanqtlogger.cpp \
    asemantools.cpp \
    asemandesktoptools.cpp \
    asemanlistobject.cpp \
    asemanhashobject.cpp \
    asemanquickview.cpp \
    asemanapplication.cpp \
    asemancalendarconvertercore.cpp \
    asemancalendarconverter.cpp \
    asemanbackhandler.cpp \
    asemansysteminfo.cpp \
    asemanabstractcolorfulllistmodel.cpp \
    asemanimagecoloranalizor.cpp \
    asemancountriesmodel.cpp \
    asemanmimedata.cpp \
    asemanmimeapps.cpp \
    asemandragobject.cpp \
    asemandownloader.cpp \
    asemannotification.cpp \
    asemanautostartmanager.cpp \
    asemanquickitemimagegrabber.cpp \
    asemanquickobject.cpp \
    asemanfilesystemmodel.cpp \
    asemandebugobjectcounter.cpp \
    asemanfiledownloaderqueue.cpp \
    asemanfiledownloaderqueueitem.cpp \
    asemanwebpagegrabber.cpp \
    asemantitlebarcolorgrabber.cpp \
    asemantaskbarbutton.cpp \
    private/asemanabstracttaskbarbuttonengine.cpp \
    asemanmapdownloader.cpp \
    asemantoolsplugin.cpp \
    asemandragarea.cpp

HEADERS += \
    asemandevices.h \
    asemanqtlogger.h \
    asemantools.h \
    asemandesktoptools.h \
    asemanlistobject.h \
    asemanhashobject.h \
    asemanquickview.h \
    asemanapplication.h \
    aseman_macros.h \
    asemancalendarconvertercore.h \
    asemancalendarconverter.h \
    asemanbackhandler.h \
    asemansysteminfo.h \
    asemanabstractcolorfulllistmodel.h \
    asemanimagecoloranalizor.h \
    asemancountriesmodel.h \
    asemanmimedata.h \
    asemanmimeapps.h \
    asemandragobject.h \
    asemandownloader.h \
    asemannotification.h \
    asemanautostartmanager.h \
    asemanquickitemimagegrabber.h \
    asemanquickobject.h \
    asemanfilesystemmodel.h \
    asemandebugobjectcounter.h \
    asemanfiledownloaderqueue.h \
    asemanfiledownloaderqueueitem.h \
    asemanwebpagegrabber.h \
    asemantitlebarcolorgrabber.h \
    asemantaskbarbutton.h \
    private/asemanabstracttaskbarbuttonengine.h \
    asemanmapdownloader.h \
    asemantoolsplugin.h \
    asemandragarea.h

OTHER_FILES += \
    android-build/src/land/aseman/android/AsemanActivity.java \
    android-build/src/land/aseman/android/AsemanApplication.java \
    android-build/src/land/aseman/android/AsemanJavaLayer.java \
    android-build/src/land/aseman/android/AsemanService.java \
    android-build/src/land/aseman/android/AsemanBootBroadcast.java \
    android-build/src/land/aseman/android/AsemanServiceDelegate.java

qmlFiles.source = qml/AsemanTools/
qmlFiles.target = $$DESTDIR/../..
COPYFOLDERS += qmlFiles

include(qmake/qmlplugindump.pri)
include(qmake/copyData.pri)
copyData()

isEmpty(PREFIX) {
    PREFIX = /usr
}

qmlFile.files = $$OUT_PWD/$$DESTDIR/
qmlFile.path = $$PREFIX/qml
qmlDir.files = $$OUT_PWD/qmldir
qmlDir.path = $$PREFIX/qml/AsemanTools

INSTALLS += qmlFile qmlDir
