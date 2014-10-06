/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef TELEGRAM_MACROS_H
#define TELEGRAM_MACROS_H

#include <QCoreApplication>
#include <QDir>
#include "telegramgui.h"

#define USERDATAS_DB_CONNECTION "userdata_db_connection"

#define HOME_PATH QString( QDir::homePath() + "/.config/sialan/telegram/" )

#define EMOJIS_PATH QString( TelegramGui::resourcesPath() + "/emojis/" )
#define LOCALES_PATH QString( TelegramGui::resourcesPath() + "/translations/" )

#define DONATE_KEY "eb229602-6719-41a5-be54-f56d1cecff77"

#define VERSION "0.7.1"

#endif // TELEGRAM_MACROS_H
