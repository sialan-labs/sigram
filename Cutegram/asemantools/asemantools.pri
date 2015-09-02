QT += qml quick

android {
    manifest.source = android-build
    manifest.target = .
    COPYFOLDERS += manifest
    include(qmake/copyData.pri)
    copyData()

    QT += androidextras
    SOURCES += \
        $$PWD/asemanjavalayer.cpp \
        $$PWD/asemanandroidservice.cpp

    HEADERS += \
        $$PWD/asemanjavalayer.h \
        $$PWD/asemanandroidservice.h
} else {
    ios {

    } else {
        contains(BUILD_MODE,ubuntutouch) {
            DEFINES += Q_OS_UBUNTUTOUCH
        } else {
            QT += widgets

            HEADERS += \
                $$PWD/qtsingleapplication/qtsinglecoreapplication.h \
                $$PWD/qtsingleapplication/qtsingleapplication.h \
                $$PWD/qtsingleapplication/qtlockedfile.h \
                $$PWD/qtsingleapplication/qtlocalpeer.h

            SOURCES += \
                $$PWD/qtsingleapplication/qtsinglecoreapplication.cpp \
                $$PWD/qtsingleapplication/qtsingleapplication.cpp \
                $$PWD/qtsingleapplication/qtlockedfile.cpp \
                $$PWD/qtsingleapplication/qtlocalpeer.cpp

            win32: SOURCES += $$PWD/qtsingleapplication/qtlockedfile_win.cpp
            unix:  SOURCES += $$PWD/qtsingleapplication/qtlockedfile_unix.cpp
        }
    }
}

QML_IMPORT_PATH = \
    $$PWD/qml/

contains(QT,macextras) {
    SOURCES += $$PWD/private/asemanmactaskbarbuttonengine.cpp
    HEADERS += $$PWD/private/asemanmactaskbarbuttonengine.h
}
contains(QT,winextras) {
    SOURCES += $$PWD/private/asemanwintaskbarbuttonengine.cpp
    HEADERS += $$PWD/private/asemanwintaskbarbuttonengine.h
}
contains(QT,sensors) {
    DEFINES += ASEMAN_SENSORS
    SOURCES += $$PWD/asemansensors.cpp
    HEADERS += $$PWD/asemansensors.h
}
contains(QT,widgets) {
    DEFINES += NATIVE_ASEMAN_NOTIFICATION
    SOURCES +=  \
        $$PWD/asemannativenotification.cpp \
        $$PWD/asemannativenotificationitem.cpp
    HEADERS +=  \
        $$PWD/asemannativenotification.h \
        $$PWD/asemannativenotificationitem.h
}
contains(QT,multimedia) {
    DEFINES += ASEMAN_MULTIMEDIA
    SOURCES +=  \
        $$PWD/asemanaudiorecorder.cpp \
        $$PWD/asemanaudioencodersettings.cpp
    HEADERS +=  \
        $$PWD/asemanaudiorecorder.h \
        $$PWD/asemanaudioencodersettings.h
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
    SOURCES += $$PWD/asemanlinuxnativenotification.cpp \
        $$PWD/private/asemanunitytaskbarbuttonengine.cpp \
        $$PWD/asemankdewallet.cpp
    HEADERS += $$PWD/asemanlinuxnativenotification.h \
        $$PWD/private/asemanunitytaskbarbuttonengine.h \
        $$PWD/asemankdewallet.h
}
}
macx {
    LIBS += -framework CoreServices
    INCLUDEPATH += /System/Library/Frameworks/CoreServices.framework/Headers/
    DEFINES += MAC_NATIVE_ASEMAN_NOTIFICATION
    SOURCES += $$PWD/asemanmacnativenotification.cpp
    HEADERS += $$PWD/asemanmacnativenotification.h
}

SOURCES += \
    $$PWD/asemandevices.cpp \
    $$PWD/asemanqtlogger.cpp \
    $$PWD/asemantools.cpp \
    $$PWD/asemandesktoptools.cpp \
    $$PWD/asemanlistobject.cpp \
    $$PWD/asemanhashobject.cpp \
    $$PWD/asemanquickview.cpp \
    $$PWD/asemanapplication.cpp \
    $$PWD/asemancalendarconvertercore.cpp \
    $$PWD/asemancalendarconverter.cpp \
    $$PWD/asemanbackhandler.cpp \
    $$PWD/asemansysteminfo.cpp \
    $$PWD/asemanabstractcolorfulllistmodel.cpp \
    $$PWD/asemanimagecoloranalizor.cpp \
    $$PWD/asemancountriesmodel.cpp \
    $$PWD/asemanmimedata.cpp \
    $$PWD/asemanmimeapps.cpp \
    $$PWD/asemandragobject.cpp \
    $$PWD/asemandownloader.cpp \
    $$PWD/asemannotification.cpp \
    $$PWD/asemanautostartmanager.cpp \
    $$PWD/asemanquickitemimagegrabber.cpp \
    $$PWD/asemanquickobject.cpp \
    $$PWD/asemanfilesystemmodel.cpp \
    $$PWD/asemandebugobjectcounter.cpp \
    $$PWD/asemanfiledownloaderqueue.cpp \
    $$PWD/asemanfiledownloaderqueueitem.cpp \
    $$PWD/asemanwebpagegrabber.cpp \
    $$PWD/asemantitlebarcolorgrabber.cpp \
    $$PWD/asemantaskbarbutton.cpp \
    $$PWD/private/asemanabstracttaskbarbuttonengine.cpp \
    $$PWD/asemanmapdownloader.cpp \
    $$PWD/asemandragarea.cpp \
    $$PWD/asemanabstractlistmodel.cpp \
    $$PWD/asemanqttools.cpp \
    $$PWD/asemancalendarmodel.cpp \
    $$PWD/asemanlistrecord.cpp

HEADERS += \
    $$PWD/asemandevices.h \
    $$PWD/asemanqtlogger.h \
    $$PWD/asemantools.h \
    $$PWD/asemandesktoptools.h \
    $$PWD/asemanlistobject.h \
    $$PWD/asemanhashobject.h \
    $$PWD/asemanquickview.h \
    $$PWD/asemanapplication.h \
    $$PWD/aseman_macros.h \
    $$PWD/asemancalendarconvertercore.h \
    $$PWD/asemancalendarconverter.h \
    $$PWD/asemanbackhandler.h \
    $$PWD/asemansysteminfo.h \
    $$PWD/asemanabstractcolorfulllistmodel.h \
    $$PWD/asemanimagecoloranalizor.h \
    $$PWD/asemancountriesmodel.h \
    $$PWD/asemanmimedata.h \
    $$PWD/asemanmimeapps.h \
    $$PWD/asemandragobject.h \
    $$PWD/asemandownloader.h \
    $$PWD/asemannotification.h \
    $$PWD/asemanautostartmanager.h \
    $$PWD/asemanquickitemimagegrabber.h \
    $$PWD/asemanquickobject.h \
    $$PWD/asemanfilesystemmodel.h \
    $$PWD/asemandebugobjectcounter.h \
    $$PWD/asemanfiledownloaderqueue.h \
    $$PWD/asemanfiledownloaderqueueitem.h \
    $$PWD/asemanwebpagegrabber.h \
    $$PWD/asemantitlebarcolorgrabber.h \
    $$PWD/asemantaskbarbutton.h \
    $$PWD/private/asemanabstracttaskbarbuttonengine.h \
    $$PWD/asemanmapdownloader.h \
    $$PWD/asemandragarea.h \
    $$PWD/asemanabstractlistmodel.h \
    $$PWD/asemanqttools.h \
    $$PWD/asemancalendarmodel.h \
    $$PWD/asemanlistrecord.h

OTHER_FILES += \
    $$PWD/android-build/src/land/aseman/android/AsemanActivity.java \
    $$PWD/android-build/src/land/aseman/android/AsemanApplication.java \
    $$PWD/android-build/src/land/aseman/android/AsemanJavaLayer.java \
    $$PWD/android-build/src/land/aseman/android/AsemanService.java \
    $$PWD/android-build/src/land/aseman/android/AsemanBootBroadcast.java \
    $$PWD/android-build/src/land/aseman/android/AsemanServiceDelegate.java

RESOURCES += \
    $$PWD/asemanresource.qrc
