TEMPLATE = app

QT += qml quick dbus widgets sql

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
COPYFOLDERS = database fonts emojis countries license gpl icons server
include(qmake/copyData.pri)
copyData()

SOURCES += main.cpp \
    telegramgui.cpp \
    notification.cpp \
    userdata.cpp \
    unitysystemtray.cpp \
    emojis.cpp \
    setobject.cpp \
    downloader.cpp \
    versionchecker.cpp \
    countries.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
include(telegram/telegram.pri)

HEADERS += \
    telegramgui.h \
    notification.h \
    userdata.h \
    telegram_macros.h \
    unitysystemtray.h \
    emojis.h \
    setobject.h \
    downloader.h \
    versionchecker.h \
    countries.h

OTHER_FILES += \
    database/userdata.db \
    database/userdata.mwb \
    database/userdata.sql
