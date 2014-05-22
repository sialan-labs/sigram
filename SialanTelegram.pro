TEMPLATE = app

QT += qml quick dbus widgets

SOURCES += main.cpp \
    telegramgui.cpp \
    notification.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
include(telegram/telegram.pri)

HEADERS += \
    telegramgui.h \
    notification.h
