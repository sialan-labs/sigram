TEMPLATE = lib
TARGET = AsemanToolsQml
QT += qml quick
CONFIG += qt plugin
DESTDIR = AsemanTools

TARGET = $$qtLibraryTarget($$TARGET)
uri = AsemanTools

DEFINES += ASEMAN_QML_PLUGIN

include(asemantools.pri)

SOURCES += \
    asemantoolsplugin.cpp

HEADERS += \
    asemantoolsplugin.h

qmlFiles.source = qml/AsemanTools/
qmlFiles.target = $$DESTDIR
COPYFOLDERS += qmlFiles

include(qmake/qmlplugindump.pri)
include(qmake/copyData.pri)
copyData()

installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
qmldir.files = $$OUT_PWD/qmldir $$OUT_PWD/$$DESTDIR/plugins.qmltypes
qmldir.path = $$installPath
qmlFile.files = qml/AsemanTools/
qmlFile.path = $$[QT_INSTALL_QML]
target = $$TARGET
target.path = $$installPath
INSTALLS += qmlFile qmldir target
