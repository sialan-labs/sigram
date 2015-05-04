#-------------------------------------------------
#
# Project created by QtCreator 2014-06-06T13:48:38
#
#-------------------------------------------------

QT       -= gui

DESTDIR = ../../build/plugins
TARGET = UnitySystemTray
TEMPLATE = lib

contains(QMAKE_HOST.arch, x86_64) {
    LIB_PATH = x86_64-linux-gnu
} else {
    LIB_PATH = i386-linux-gnu
}

INCLUDEPATH += "/usr/include/libappindicator-0.1"
INCLUDEPATH += "/usr/include/gtk-2.0"
INCLUDEPATH += "/usr/include/glib-2.0"
INCLUDEPATH += "/usr/lib/$$LIB_PATH/glib-2.0/include"
INCLUDEPATH += "/usr/include/cairo"
INCLUDEPATH += "/usr/include/pango-1.0"
INCLUDEPATH += "/usr/lib/$$LIB_PATH/gtk-2.0/include"
INCLUDEPATH += "/usr/include/gdk-pixbuf-2.0"
INCLUDEPATH += "/usr/include/atk-1.0"

LIBS += -L/usr/lib/$$LIB_PATH -lgobject-2.0 -lappindicator -lgtk-x11-2.0

DEFINES += UNITYSYSTEMTRAY_LIBRARY
SOURCES += unitysystemtray.cpp \
    libmain.cpp

HEADERS += unitysystemtray.h\
        unitysystemtray_global.h

isEmpty(PREFIX) {
    PREFIX = /usr
}

contains(BUILD_MODE,opt) {
    BIN_PATH = $$PREFIX/plugins
} else {
    BIN_PATH = $$PREFIX/lib/cutegram/plugins
}

target = $$TARGET
target.path = $$BIN_PATH

INSTALLS = target
