#-------------------------------------------------
#
# Project created by QtCreator 2014-05-12T16:44:41
#
#-------------------------------------------------

QT       += core gui

INCLUDEPATH += /usr/include/openssl/ /usr/include/readline
LIBS += -lssl -lcrypto -lreadline -lhistory -lz

SOURCES += \
    telegram/telegram_cli/binlog.c \
    telegram/telegram_cli/interface.c \
    telegram/telegram_cli/loop.c \
    telegram/telegram_cli/lua-tg.c \
    telegram/telegram_cli/mtproto-client.c \
    telegram/telegram_cli/mtproto-common.c \
    telegram/telegram_cli/net.c \
    telegram/telegram_cli/queries.c \
    telegram/telegram_cli/structures.c \
    telegram/telegram_cli/tools.c \
    telegram/telegram_cli/tmain.c \
    telegram/telegramthread.cpp \
    telegram/telegramcore.cpp \
    telegram/telegram.cpp

OTHER_FILES += \
    telegram/telegram_cli/config.h.in

HEADERS += \
    telegram/telegram_cli/binlog.h \
    telegram/telegram_cli/config.h \
    telegram/telegram_cli/constants.h \
    telegram/telegram_cli/include.h \
    telegram/telegram_cli/interface.h \
    telegram/telegram_cli/LICENSE.h \
    telegram/telegram_cli/loop.h \
    telegram/telegram_cli/lua-tg.h \
    telegram/telegram_cli/mtproto-client.h \
    telegram/telegram_cli/mtproto-common.h \
    telegram/telegram_cli/net.h \
    telegram/telegram_cli/no-preview.h \
    telegram/telegram_cli/queries.h \
    telegram/telegram_cli/structures.h \
    telegram/telegram_cli/telegram.h \
    telegram/telegram_cli/tools.h \
    telegram/telegram_cli/tree.h \
    telegram/telegram_cli/tmain.h \
    telegram/telegramthread.h \
    telegram/strcuts.h \
    telegram/telegramcore.h \
    telegram/telegramcore_p.h \
    telegram/telegram.h
