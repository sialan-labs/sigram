TEMPLATE = app

QT += qml quick dbus widgets sql

manifest.source = database/userdata.db
manifest.target = .
COPYFOLDERS = manifest
include(qmake/copyData.pri)
copyData()

SOURCES += main.cpp \
    telegramgui.cpp \
    notification.cpp \
    userdata.cpp

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
    telegram/telegram_cli/structers-only.h

OTHER_FILES += \
    database/userdata.db \
    database/userdata.mwb \
    database/userdata.sql
