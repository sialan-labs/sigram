DESTDIR=../build

server.source = tg-server.pub
server.target = $${DESTDIR}
emojis.source = emojis
emojis.target = $${DESTDIR}
DEPLOYMENTFOLDERS = server emojis

TEMPLATE = app
QT += qml quick sql
linux: QT += dbus

LIBS += -lqtelegram -lssl -lcrypto -lz
INCLUDEPATH += /usr/include/libqtelegram

SOURCES += main.cpp \
    sigram.cpp \
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
    telegramcontactsmodel.cpp

RESOURCES += resource.qrc

include(qmake/qtcAddDeployment.pri)
include(sialantools/sialantools.pri)
qtcAddDeployment()

HEADERS += \
    sigram.h \
    telegramqml.h \
    sigram_macros.h \
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
    telegramcontactsmodel.h

OTHER_FILES += \
    objects/types.sco \
    objects/templates/class.template \
    objects/templates/equals.template \
    objects/templates/initialize.template
