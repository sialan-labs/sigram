TEMPLATE = app
QT += qml quick widgets
DEFINES += PROJECT_PATH='"\\\"$$PWD\\\""'
SOURCES += main.cpp
OTHER_FILES += $$files(*, true)

DISTFILES += \
    sidebar/SearchListMessageItem.qml \
    sidebar/SearchListLookupItem.qml \
    toolkit/ContactsPage.qml \
    toolkit/AddNewPage.qml \
    authenticating/AuthPassword.qml \
    toolkit/DialogDetailsHeader.qml \
    toolkit/UserList.qml
