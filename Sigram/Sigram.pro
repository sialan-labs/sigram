TEMPLATE = app

QT += qml quick widgets sql
DESTDIR = build

database.source = database/userdata.db
database.target = $${DESTDIR}
fonts.source = fonts
fonts.target = $${DESTDIR}
emojis.source = emojis
emojis.target = $${DESTDIR}
countries.source = countries
countries.target = $${DESTDIR}
license.source = license.txt
license.target = $${DESTDIR}
gpl.source = GPL.txt
gpl.target = $${DESTDIR}
icons.source = icons
icons.target = $${DESTDIR}
server.source = tg-server.pub
server.target = $${DESTDIR}
translations.source = translations
translations.target = $${DESTDIR}
run_file.source = run
run_file.target = $${DESTDIR}
COPYFOLDERS = database fonts emojis countries license gpl icons server translations run_file
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
