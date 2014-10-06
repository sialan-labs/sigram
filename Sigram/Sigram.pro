TEMPLATE = app

QT += qml quick widgets sql
DESTDIR = ../build

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

TRANSLATIONS += \
    translations/lang-de.qm \
    translations/lang-en.qm \
    translations/lang-es.qm \
    translations/lang-fa.qm \
    translations/lang-it.qm \
    translations/lang-pt_BR.qm \
    translations/lang-ru.qm

isEmpty(PREFIX) {
    PREFIX = /usr
}

contains(BUILD_MODE,opt) {
    BIN_PATH = $$PREFIX/
    SHARES_PATH = $$PREFIX/
    APPDESK_PATH = /usr/
    APPDESK_SRC = desktop/opt/
} else {
    BIN_PATH = $$PREFIX/bin
    SHARES_PATH = $$PREFIX/share/sigram/
    APPDESK_PATH = $$PREFIX/
    APPDESK_SRC = desktop/normal/
}

android {
} else {
linux {
    target = $$TARGET
    target.path = $$BIN_PATH
    translations.files = $$TRANSLATIONS
    translations.path = $$SHARES_PATH/translations
    fonts.files = fonts
    fonts.path = $$SHARES_PATH/
    icons.files = icons/icon.png
    icons.path = $$SHARES_PATH/icons/
    database.files = database
    database.path = $$SHARES_PATH/
    countries.files = countries
    countries.path = $$SHARES_PATH/
    emojis.files = emojis
    emojis.path = $$SHARES_PATH/emojis
    server_pub.files = tg-server.pub
    server_pub.path = $$SHARES_PATH/
    run_script.files = run
    run_script.path = $$SHARES_PATH/
    desktopFile.files = $$APPDESK_SRC/Sigram.desktop
    desktopFile.path = $$APPDESK_PATH/share/applications

    INSTALLS = target fonts translations icons database countries emojis server_pub run_script desktopFile
}
}
