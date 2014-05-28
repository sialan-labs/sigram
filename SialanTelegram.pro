TEMPLATE = app

QT += qml quick dbus widgets sql

manifest.source = database/userdata.db
manifest.target = .
COPYFOLDERS = manifest
include(qmake/copyData.pri)
copyData()


INCLUDEPATH += "/usr/include/libappindicator-0.1"
INCLUDEPATH += "/usr/include/gtk-2.0"
INCLUDEPATH += "/usr/include/glib-2.0"
INCLUDEPATH += "/usr/lib/x86_64-linux-gnu/glib-2.0/include"
INCLUDEPATH += "/usr/include/cairo"
INCLUDEPATH += "/usr/include/pango-1.0"
INCLUDEPATH += "/usr/lib/x86_64-linux-gnu/gtk-2.0/include"
INCLUDEPATH += "/usr/include/gdk-pixbuf-2.0"
INCLUDEPATH += "/usr/include/atk-1.0"

LIBS += -L/usr/lib/x86_64-linux-gnu -lgobject-2.0
LIBS += -L/usr/lib/x86_64-linux-gnu -lappindicator
LIBS += -L/usr/lib/x86_64-linux-gnu -lgtk-x11-2.0

SOURCES += main.cpp \
    telegramgui.cpp \
    notification.cpp \
    userdata.cpp \
    unitysystemtray.cpp

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
    telegram/telegram_cli/structers-only.h \
    unitysystemtray.h

OTHER_FILES += \
    database/userdata.db \
    database/userdata.mwb \
    database/userdata.sql
