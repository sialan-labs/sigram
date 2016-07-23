contains(CONFIG, binaryMode) {
    CONFIG += c++11
    TARGET = cutegram
    QT += qml quick gui widgets core
    target.path = $$PREFIX/bin
    INSTALLS += target
    TEMPLATE = app
    SOURCES += main.cpp
    RESOURCES += \
        resource.qrc \
        emojis/emojis.qrc
} else {
    TEMPLATE = aux
}

OTHER_FILES += $$files(*, true)
VERSION = 3.0

shortcut.path = $$PREFIX/share/applications/
shortcut.files = share/Cutegram.desktop
icons.path = $$PREFIX/share/icons
icons.files = share/hicolor
pixmaps.path = $$PREFIX/share/pixmaps
pixmaps.files = share/cutegram.png
qmlFiles.path = $$PREFIX/share/cutegram/$$VERSION/
qmlFiles.files = \
    about \
    account \
    authenticating \
    awesome \
    configure \
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

INSTALLS += qmlFiles shortcut icons pixmaps
