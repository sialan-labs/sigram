#-------------------------------------------------
#
# Project created by QtCreator 2014-06-06T13:48:38
#
#-------------------------------------------------

QT       -= gui

DESTDIR = ../../build/plugins
TARGET = UnitySystemTray
TEMPLATE = lib

INCLUDEPATH += "/usr/include/libappindicator-0.1"
INCLUDEPATH += "/usr/include/gtk-2.0"
INCLUDEPATH += "/usr/include/glib-2.0"
INCLUDEPATH += "/usr/lib/x86_64-linux-gnu/glib-2.0/include"
INCLUDEPATH += "/usr/lib/i386-linux-gnu/glib-2.0/include"
INCLUDEPATH += "/usr/include/cairo"
INCLUDEPATH += "/usr/include/pango-1.0"
INCLUDEPATH += "/usr/lib/x86_64-linux-gnu/gtk-2.0/include"
INCLUDEPATH += "/usr/lib/i386-linux-gnu/gtk-2.0/include"
INCLUDEPATH += "/usr/include/gdk-pixbuf-2.0"
INCLUDEPATH += "/usr/include/atk-1.0"

LIBS += -L/usr/lib/x86_64-linux-gnu -lgobject-2.0
LIBS += -L/usr/lib/x86_64-linux-gnu -lappindicator
LIBS += -L/usr/lib/x86_64-linux-gnu -lgtk-x11-2.0

DEFINES += UNITYSYSTEMTRAY_LIBRARY
SOURCES += unitysystemtray.cpp \
    libmain.cpp

HEADERS += unitysystemtray.h\
        unitysystemtray_global.h
