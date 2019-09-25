
CONFIG += c++11
TARGET = cutegram
QT += qml quick gui widgets core asemancore asemangui asemanqml sql
LIBS += -lqt5keychain
TEMPLATE = app
SOURCES += main.cpp
RESOURCES += \
    resource.qrc \
    emojis/emojis.qrc
SHORTCUT = cutegram

OTHER_FILES += $$files(*, true)
VERSION = 3.0

shortcut.input = share/Cutegram.desktop.in
shortcut.output = share/Cutegram.desktop
shortcut.path = $$PREFIX/share/applications/
shortcut.files = $$shortcut.output
icons.path = $$PREFIX/share/icons
icons.files = share/hicolor
pixmaps.path = $$PREFIX/share/pixmaps
pixmaps.files = share/cutegram.png
qmlFiles.path = $$PREFIX/share/cutegram/$$VERSION/
qmlFiles.files = \
    about \
    add \
    app \
    account \
    authenticating \
    awesome \
    configure \
    contacts \
    emojis \
    globals \
    images \
    inputs \
    medias \
    messages \
    sidebar \
    sounds \
    thirdparty \
    toolkit \
    tools \
    main.qml \
    GPL.txt \
    LICENSE

QMAKE_SUBSTITUTES += shortcut
contains(CONFIG, binaryMode) {
    target.path = $$PREFIX/bin
    INSTALLS += target
} else {
    INSTALLS += qmlFiles
}
INSTALLS += shortcut icons pixmaps

DISTFILES += \
    AddWidgets/AddGroup.qml

HEADERS += \
    core/asemancontributorsmodel.h \
    core/asemankeychain.h

SOURCES += \
    core/asemancontributorsmodel.cpp \
    core/asemankeychain.cpp
