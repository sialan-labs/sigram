TEMPLATE = app
QT += qml quick widgets
DEFINES += PROJECT_PATH='"\\\"$$PWD\\\""'
SOURCES += main.cpp
OTHER_FILES += $$files(*, true)
