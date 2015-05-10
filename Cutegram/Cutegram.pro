DESTDIR=../build

linux {
    server.source = tg-server.pub
    server.target = $${DESTDIR}
    emojis.source = emojis
    emojis.target = $${DESTDIR}
    translations.source = translations
    translations.target = $$DESTDIR/files
    themes.source = themes
    themes.target = $${DESTDIR}
    DEPLOYMENTFOLDERS = server emojis translations themes
}

TEMPLATE = app
TARGET = cutegram
QT += qml quick sql xml multimedia

contains(DEFINES, WEBENGINE_ASEMAN_WEBGRABBER) {
    QT += webenginewidgets webengine
} else {
contains(DEFINES, DISABLE_ASEMAN_WEBGRABBER) {
} else {
    QT += webkitwidgets webkit
}
}

linux: QT += dbus
win32 {
    LIBS += -L$$OUT_PWD/$$DESTDIR -lssleay32 -lcrypto -lz -lqtelegram-ae
    INCLUDEPATH += $$OUT_PWD/$$DESTDIR/include $$OUT_PWD/$$DESTDIR/include/libqtelegram-ae
} else {
macx {
    QT += macextras
    LIBS += -lssl -lcrypto -lz -lqtelegram-ae
    INCLUDEPATH += /usr/include/libqtelegram-ae $$OUT_PWD/$$DESTDIR/include/libqtelegram-ae
} else {
    LIBS += -lssl -lcrypto -lz -lqtelegram-ae
    INCLUDEPATH += /usr/include/libqtelegram-ae $$OUT_PWD/$$DESTDIR/include/libqtelegram-ae
}
}

SOURCES += main.cpp \
    cutegram.cpp \
    telegramqml.cpp \
    profilesmodel.cpp \
    telegramdialogsmodel.cpp \
    telegrammessagesmodel.cpp \
    emojis.cpp \
    photosizelist.cpp \
    unitysystemtray.cpp \
    userdata.cpp \
    telegramwallpapersmodel.cpp \
    chatparticipantlist.cpp \
    telegramuploadsmodel.cpp \
    telegramchatparticipantsmodel.cpp \
    telegramcontactsmodel.cpp \
    database.cpp \
    databasecore.cpp \
    compabilitytools.cpp \
    cutegramdialog.cpp \
    telegramsearchmodel.cpp \
    dialogfilesmodel.cpp \
    cutegramenums.cpp \
    tagfiltermodel.cpp \
    usernamefiltermodel.cpp \
    mp3converterengine.cpp \
    textemojiwrapper.cpp

RESOURCES += resource.qrc

include(qmake/qtcAddDeployment.pri)
include(asemantools/asemantools.pri)
qtcAddDeployment()

HEADERS += \
    cutegram.h \
    telegramqml.h \
    cutegram_macros.h \
    profilesmodel.h \
    telegramdialogsmodel.h \
    objects/types.h \
    telegrammessagesmodel.h \
    emojis.h \
    photosizelist.h \
    unitysystemtray.h \
    userdata.h \
    telegramwallpapersmodel.h \
    chatparticipantlist.h \
    telegramuploadsmodel.h \
    telegramchatparticipantsmodel.h \
    telegramcontactsmodel.h \
    database.h \
    databasecore.h \
    compabilitytools.h \
    cutegramdialog.h \
    telegramsearchmodel.h \
    dialogfilesmodel.h \
    cutegramenums.h \
    themeitem.h \
    tagfiltermodel.h \
    usernamefiltermodel.h \
    mp3converterengine.h \
    textemojiwrapper.h

OTHER_FILES += \
    objects/types.sco \
    objects/templates/class.template \
    objects/templates/equals.template \
    objects/templates/initialize.template


TRANSLATIONS += \
    translations/land-el.qm \
    translations/lang-ast.qm \
    translations/lang-de.qm \
    translations/lang-en.qm \
    translations/lang-en_GB.qm \
    translations/lang-es.qm \
    translations/lang-et.qm \
    translations/lang-fa.qm \
    translations/lang-fr_FR.qm \
    translations/lang-it_IT.qm \
    translations/lang-nl_NL.qm \
    translations/lang-pt_BR.qm \
    translations/lang-pt_PT.qm \
    translations/lang-sr.qm \
    translations/lang-zh.qm \
    translations/lang-zh_CN.qm \
    translations/lang-zh_TW.qm

isEmpty(PREFIX) {
    PREFIX = /usr
}

contains(BUILD_MODE,opt) {
    BIN_PATH = $$PREFIX/
    SHARES_PATH = $$PREFIX/
    APPDESK_PATH = /usr/
} else {
    BIN_PATH = $$PREFIX/bin
    SHARES_PATH = $$PREFIX/share/cutegram/
    APPDESK_PATH = $$PREFIX/
}

target = $$TARGET
target.path = $$BIN_PATH
translations.files = $$TRANSLATIONS
translations.path = $$SHARES_PATH/files/translations
icons.files = icons
icons.path = $$SHARES_PATH
hicolor.files = icons
hicolor.path = $$APPDESK_PATH/share
pixmaps.files = icons/cutegram.png
pixmaps.path = $$APPDESK_PATH/share/pixmaps/
desktopFile.files = desktop/Cutegram.desktop
desktopFile.path = $$APPDESK_PATH/share/applications
emojis.files = emojis
emojis.path = $$SHARES_PATH
themesFiles.files = themes
themesFiles.path = $$SHARES_PATH
serverPub.files = tg-server.pub
serverPub.path = $$SHARES_PATH/

INSTALLS = target translations icons desktopFile emojis serverPub pixmaps hicolor themesFiles

win32 {
    RC_FILE = extra/windows/cutegram.rc
}

DISTFILES += \
    translations_sources/land-el.ts \
    translations_sources/lang-ast.ts \
    translations_sources/lang-de.ts \
    translations_sources/lang-en.ts \
    translations_sources/lang-en_GB.ts \
    translations_sources/lang-es.ts \
    translations_sources/lang-et.ts \
    translations_sources/lang-fa.ts \
    translations_sources/lang-fr_FR.ts \
    translations_sources/lang-it_IT.ts \
    translations_sources/lang-nl_NL.ts \
    translations_sources/lang-pt_BR.ts \
    translations_sources/lang-pt_PT.ts \
    translations_sources/lang-sr.ts \
    translations_sources/lang-zh.ts \
    translations_sources/lang-zh_CN.ts \
    translations_sources/lang-zh_TW.ts \
    objects/themeitem.sco
