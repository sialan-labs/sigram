server.source = tg-server.pub
server.target = $${DESTDIR}
DEPLOYMENTFOLDERS = server

TEMPLATE = app
QT += qml quick sql
linux: QT += dbus

LIBS += -lqtelegram -lssl -lcrypto -lz
INCLUDEPATH += /usr/include/libqtelegram

SOURCES += main.cpp \
    sigram.cpp \
    telegramqml.cpp \
    profilesmodel.cpp

RESOURCES += resource.qrc

include(qmake/qtcAddDeployment.pri)
include(sialantools/sialantools.pri)
qtcAddDeployment()

HEADERS += \
    sigram.h \
    telegramqml.h \
    sigram_macros.h \
    profilesmodel.h
