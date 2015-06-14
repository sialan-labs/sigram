/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef CUTEGRAM_MACROS_H
#define CUTEGRAM_MACROS_H

#include <QDebug>

#define PROFILES_DB_CONNECTION "profiles_connection"
#define PROFILES_DB_PATH ":/database/profiles.sqlite"

#define USERDATA_DB_CONNECTION "userdata_connection"
#define USERDATA_DB_PATH ":/database/userdata.sqlite"

#define DATABASE_DB_CONNECTION "database_connection"
#define DATABASE_DB_PATH ":/database/database.sqlite"

#define CHECK_QUERY_ERROR(QUERY_OBJECT) \
    if(QUERY_OBJECT.lastError().isValid()) \
        qDebug() << __FUNCTION__ << QUERY_OBJECT.lastError().text();

#endif // CUTEGRAM_MACROS_H
