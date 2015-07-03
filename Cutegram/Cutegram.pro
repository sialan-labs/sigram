DESTDIR=../build

linux|openbsd {
    server.source = tg-server.pub
    server.target = $${DESTDIR}
    emojis.source = emojis
    emojis.target = $${DESTDIR}
    stickers.source = stickers
    stickers.target = $${DESTDIR}
    translations.source = translations
    translations.target = $$DESTDIR/files
    fonts.source = fonts
    fonts.target = $$DESTDIR/files
    themes.source = themes
    themes.target = $${DESTDIR}
    DEPLOYMENTFOLDERS = server emojis translations themes fonts stickers
}

TEMPLATE = app
TARGET = cutegram
QT += qml quick sql xml multimedia

INCLUDEPATH += ../Cutegram

contains(DEFINES, WEBENGINE_ASEMAN_WEBGRABBER) {
    QT += webenginewidgets webengine
} else {
contains(DEFINES, DISABLE_ASEMAN_WEBGRABBER) {
} else {
    QT += webkitwidgets webkit
}
}

linux|openbsd: QT += dbus
win32 {
    isEmpty(OPENSSL_LIB_DIR): OPENSSL_LIB_DIR = $${DESTDIR}
    isEmpty(LIBQTELEGRAM_LIB_DIR): LIBQTELEGRAM_LIB_DIR = $${DESTDIR}
    isEmpty(TELEGRAMQML_LIB_DIR): TELEGRAMQML_LIB_DIR = $${DESTDIR}
    isEmpty(OPENSSL_INCLUDE_PATH): OPENSSL_INCLUDE_PATH = $${DESTDIR}/include/openssl
    isEmpty(LIBQTELEGRAM_INCLUDE_PATH): LIBQTELEGRAM_INCLUDE_PATH = $${DESTDIR}/include/libqtelegram-ae
    isEmpty(TELEGRAMQML_INCLUDE_PATH): TELEGRAMQML_INCLUDE_PATH = $${DESTDIR}/include/telegramqml

    QT += winextras
    LIBS +=  -L$${OPENSSL_LIB_DIR} -lssleay32 -lcrypto -lz -L$${LIBQTELEGRAM_LIB_DIR} -lqtelegram-ae -L$${TELEGRAMQML_LIB_DIR} -ltelegramqml
    INCLUDEPATH += $${OPENSSL_INCLUDE_PATH} $${LIBQTELEGRAM_INCLUDE_PATH} $${TELEGRAMQML_INCLUDE_PATH}
} else {
    isEmpty(OPENSSL_INCLUDE_PATH): OPENSSL_INCLUDE_PATH = /usr/include/openssl /usr/local/include/openssl
    isEmpty(LIBQTELEGRAM_INCLUDE_PATH): LIBQTELEGRAM_INCLUDE_PATH = /usr/include/libqtelegram-ae /usr/local/include/libqtelegram-ae
    isEmpty(TELEGRAMQML_INCLUDE_PATH): TELEGRAMQML_INCLUDE_PATH = /usr/include/telegramqml /usr/local/include/telegramqml
    isEmpty(OPENSSL_LIB_DIR) {
        LIBS += -lssl -lcrypto -lz
    } else {
        LIBS += -L$${OPENSSL_LIB_DIR} -lssl -lcrypto -lz
    }
    isEmpty(LIBQTELEGRAM_LIB_DIR) {
        LIBS += -lqtelegram-ae
    } else {
        LIBS += -L$${LIBQTELEGRAM_LIB_DIR} -lqtelegram-ae
    }
    isEmpty(TELEGRAMQML_LIB_DIR) {
        LIBS += -ltelegramqml
    } else {
        LIBS += -L$${TELEGRAMQML_LIB_DIR} -ltelegramqml
    }

    INCLUDEPATH += $${OPENSSL_INCLUDE_PATH} $${LIBQTELEGRAM_INCLUDE_PATH} $${TELEGRAMQML_INCLUDE_PATH}

    macx {
        QT += macextras
        LIBS += -framework CoreServices
        INCLUDEPATH += /System/Library/Frameworks/CoreServices.framework/Headers/
    } else {
    openbsd {
        # OPENBSD
    } else {
        # LINUX
    }
    }
}

SOURCES += main.cpp \
    cutegram.cpp \
    emojis.cpp \
    unitysystemtray.cpp \
    compabilitytools.cpp \
    cutegramdialog.cpp \
    cutegramenums.cpp \
    textemojiwrapper.cpp \
    emoticonsmodel.cpp \
    contributorsmodel.cpp \
    pasteanalizer.cpp

RESOURCES += resource.qrc

include(qmake/qtcAddDeployment.pri)
include(asemantools/asemantools.pri)
qtcAddDeployment()

HEADERS += \
    cutegram.h \
    cutegram_macros.h \
    emojis.h \
    unitysystemtray.h \
    compabilitytools.h \
    cutegramdialog.h \
    cutegramenums.h \
    themeitem.h \
    textemojiwrapper.h \
    emoticonsmodel.h \
    contributorsmodel.h \
    pasteanalizer.h

OTHER_FILES += \
    objects/types.sco \
    objects/templates/class.template \
    objects/templates/equals.template \
    objects/templates/initialize.template


TRANSLATIONS += \
    translations/land-el.qm \
    translations/lang-ast.qm \
    translations/lang-de.qm \
    translations/lang-el.qm \
    translations/lang-en.qm \
    translations/lang-en_GB.qm \
    translations/lang-es.qm \
    translations/lang-et.qm \
    translations/lang-fa_IR.qm \
    translations/lang-fr_FR.qm \
    translations/lang-it_IT.qm \
    translations/lang-ku_IQ.qm \
    translations/lang-nl_NL.qm \
    translations/lang-pt_BR.qm \
    translations/lang-pt_PT.qm \
    translations/lang-ru.qm \
    translations/lang-sr.qm \
    translations/lang-sv.qm \
    translations/lang-zh.qm \
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
fontsFiles.files = fonts
fontsFiles.path = $$SHARES_PATH/files/
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
stickerFiles.files = stickers
stickerFiles.path = $$SHARES_PATH
themesFiles.files = themes
themesFiles.path = $$SHARES_PATH
serverPub.files = tg-server.pub
serverPub.path = $$SHARES_PATH/

INSTALLS = target translations icons desktopFile emojis stickerFiles serverPub pixmaps hicolor themesFiles fontsFiles

win32 {
    RC_FILE = extra/windows/cutegram.rc
}

DISTFILES += \
    translations_sources/land-el.ts \
    translations_sources/lang-ast.ts \
    translations_sources/lang-de.ts \
    translations_sources/lang-el.ts \
    translations_sources/lang-en.ts \
    translations_sources/lang-en_GB.ts \
    translations_sources/lang-es.ts \
    translations_sources/lang-et.ts \
    translations_sources/lang-fa_IR.ts \
    translations_sources/lang-fr_FR.ts \
    translations_sources/lang-it_IT.ts \
    translations_sources/lang-ku_IQ.ts \
    translations_sources/lang-nl_NL.ts \
    translations_sources/lang-pt_BR.ts \
    translations_sources/lang-pt_PT.ts \
    translations_sources/lang-ru.ts \
    translations_sources/lang-sr.ts \
    translations_sources/lang-sv.ts \
    translations_sources/lang-zh.ts \
    translations_sources/lang-zh_CN.ts \
    translations_sources/lang-zh_TW.ts \
    objects/themeitem.sco
