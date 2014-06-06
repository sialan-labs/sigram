#ifndef TELEGRAM_MACROS_H
#define TELEGRAM_MACROS_H

#include <QCoreApplication>
#include <QDir>

#define USERDATAS_DB_CONNECTION "userdata_db_connection"

#define HOME_PATH QString( QDir::homePath() + "/.config/sialan/telegram/" )
#define EMOJIS_PATH QString( QCoreApplication::applicationDirPath() + "/emojis/" )

#define VERSION 0.5

#endif // TELEGRAM_MACROS_H
