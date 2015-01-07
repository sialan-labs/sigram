DESTDIR=../build

server.source = tg-server.pub
server.target = $${DESTDIR}
emojis.source = emojis
emojis.target = $${DESTDIR}
translations.source = translations
translations.target = $$DESTDIR/files
DEPLOYMENTFOLDERS = server emojis translations

TEMPLATE = app
QT += qml quick sql
linux: QT += dbus

LIBS += -lqtelegram -lssl -lcrypto -lz
INCLUDEPATH += /usr/include/libqtelegram

SOURCES += main.cpp \
    cutegram.cpp \
    telegramqml.cpp \
    profilesmodel.cpp \
    telegramdialogsmodel.cpp \
    telegrammessagesmodel.cpp \
    emojis.cpp \
    photosizelist.cpp \
    unitysystemtray.cpp \
    userdata.cpp \
    telegramwallpapersmodel.cpp \
    chatparticipantlist.cpp \
    telegramuploadsmodel.cpp \
    telegramchatparticipantsmodel.cpp \
    telegramcontactsmodel.cpp \
    database.cpp \
    databasecore.cpp

RESOURCES += resource.qrc

include(qmake/qtcAddDeployment.pri)
include(asemantools/asemantools.pri)
qtcAddDeployment()

HEADERS += \
    cutegram.h \
    telegramqml.h \
    cutegram_macros.h \
    profilesmodel.h \
    telegramdialogsmodel.h \
    objects/types.h \
    telegrammessagesmodel.h \
    emojis.h \
    photosizelist.h \
    unitysystemtray.h \
    userdata.h \
    telegramwallpapersmodel.h \
    chatparticipantlist.h \
    telegramuploadsmodel.h \
    telegramchatparticipantsmodel.h \
    telegramcontactsmodel.h \
    database.h \
    databasecore.h

OTHER_FILES += \
    objects/types.sco \
    objects/templates/class.template \
    objects/templates/equals.template \
    objects/templates/initialize.template
