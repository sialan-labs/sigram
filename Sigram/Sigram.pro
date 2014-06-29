TEMPLATE = app

QT += qml quick widgets sql

database.source = database/userdata.db
database.target = .
fonts.source = fonts
fonts.target = .
emojis.source = emojis
emojis.target = .
countries.source = countries
countries.target = .
license.source = license.txt
license.target = .
gpl.source = GPL.txt
gpl.target = .
icons.source = icons
icons.target = .
server.source = tg-server.pub
server.target = .
translations.source = translations
translations.target = .
COPYFOLDERS = database fonts emojis countries license gpl icons server translations
include(../qmake/copyData.pri)
copyData()

SOURCES += main.cpp \
    telegramgui.cpp \
    userdata.cpp \
    unitysystemtray.cpp \
    emojis.cpp \
    setobject.cpp \
    downloader.cpp \
    versionchecker.cpp \
    countries.cpp\
    qtsingleapplication/qtsinglecoreapplication.cpp \
    qtsingleapplication/qtsingleapplication.cpp \
    qtsingleapplication/qtlockedfile.cpp \
    qtsingleapplication/qtlocalpeer.cpp \
    qmlstaticobjecthandler.cpp \
    hashobject.cpp

win32: SOURCES += qtsingleapplication/qtlockedfile_win.cpp
unix:  SOURCES += qtsingleapplication/qtlockedfile_unix.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
include(telegram/telegram.pri)

HEADERS += \
    telegramgui.h \
    userdata.h \
    telegram_macros.h \
    unitysystemtray.h \
    emojis.h \
    setobject.h \
    downloader.h \
    versionchecker.h \
    countries.h \
    qtsingleapplication/qtsinglecoreapplication.h \
    qtsingleapplication/qtsingleapplication.h \
    qtsingleapplication/qtlockedfile.h \
    qtsingleapplication/qtlocalpeer.h \
    qmlstaticobjecthandler.h \
    hashobject.h

linux {
    QT += dbus
    SOURCES += \
        notification.cpp
    HEADERS += \
        notification.h
}

OTHER_FILES += \
    database/userdata.db \
    database/userdata.mwb \
    database/userdata.sql
