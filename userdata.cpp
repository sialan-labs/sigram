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

#include "userdata.h"
#include "sigram.h"
#include "sigram_macros.h"
#include "sialantools/sialanapplication.h"
#include "sialantools/sialandevices.h"

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QFile>
#include <QDateTime>
#include <QSettings>
#include <QHash>

class SecretChatDBClass
{
public:
    int id;
    int userId;
    QString title;
};

class UserDataPrivate
{
public:
    QSqlDatabase db;
    QString path;

    QHash<int,bool> mutes;
    QHash<int,bool> favorites;
    QHash<QString,QString> general;
};

UserData::UserData(const QString & phoneNumber, QObject *parent) :
    QObject(parent)
{
    p = new UserDataPrivate;
    p->path = SialanApplication::homePath() + "/" + phoneNumber + "/userdata.db";

    if( !SialanApplication::settings()->value("initialize/userdata_db",false).toBool() )
        QFile::copy(USERDATA_DB_PATH,p->path);

    SialanApplication::settings()->setValue("initialize/userdata_db",true);
    QFile(p->path).setPermissions(QFileDevice::WriteOwner|QFileDevice::WriteGroup|QFileDevice::ReadUser|QFileDevice::ReadGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE",USERDATA_DB_CONNECTION);
    p->db.setDatabaseName(p->path);

    reconnect();
}

void UserData::disconnect()
{
    p->db.close();
}

void UserData::reconnect()
{
    p->db.open();
    update_db();
    init_buffer();
}

void UserData::addMute(int id)
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("INSERT OR REPLACE INTO mutes (id,mute) VALUES (:id,:mute)");
    mute_query.bindValue(":id",id);
    mute_query.bindValue(":mute",1);
    mute_query.exec();

    p->mutes.insert(id,true);
}

void UserData::removeMute(int id)
{
    QSqlQuery query(p->db);
    query.prepare("DELETE FROM mutes WHERE id=:id");
    query.bindValue(":id", id);
    query.exec();

    p->mutes.remove(id);
}

QList<int> UserData::mutes() const
{
    QList<int> res;
    QHashIterator<int,bool> i(p->mutes);
    while( i.hasNext() )
    {
        i.next();
        if( i.value() )
            res << i.key();
    }

    return res;
}

bool UserData::isMuted(int id)
{
    return p->mutes.value(id);
}

void UserData::addFavorite(int id)
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("INSERT OR REPLACE INTO favorites (id,favorite) VALUES (:id,:fave)");
    mute_query.bindValue(":id",id);
    mute_query.bindValue(":fave",1);
    mute_query.exec();

    p->favorites.insert(id,true);
}

void UserData::removeFavorite(int id)
{
    QSqlQuery query(p->db);
    query.prepare("DELETE FROM favorites WHERE id=:id");
    query.bindValue(":id", id);
    query.exec();

    p->favorites.remove(id);
}

QList<int> UserData::favorites() const
{
    QList<int> res;
    QHashIterator<int,bool> i(p->favorites);
    while( i.hasNext() )
    {
        i.next();
        if( i.value() )
            res << i.key();
    }

    return res;
}

bool UserData::isFavorited(int id)
{
    return p->favorites.value(id);
}

void UserData::setValue(const QString &key, const QString &value)
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("INSERT OR REPLACE INTO general (gkey,gvalue) VALUES (:key,:val)");
    mute_query.bindValue(":key", key);
    mute_query.bindValue(":val", value);
    mute_query.exec();

    p->general[key] = value;
}

QString UserData::value(const QString &key)
{
    return p->general.value(key);
}

void UserData::init_buffer()
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("SELECT id, mute FROM mutes");
    mute_query.exec();

    while( mute_query.next() )
    {
        const QSqlRecord & record = mute_query.record();
        p->mutes.insert( record.value(0).toInt(), record.value(1).toInt() );
    }

    QSqlQuery faves_query(p->db);
    faves_query.prepare("SELECT id, favorite FROM favorites");
    faves_query.exec();

    while( faves_query.next() )
    {
        const QSqlRecord & record = faves_query.record();
        p->favorites.insert( record.value(0).toInt(), record.value(1).toInt() );
    }

    QSqlQuery general_query(p->db);
    general_query.prepare("SELECT gkey, gvalue FROM general");
    general_query.exec();

    while( general_query.next() )
    {
        const QSqlRecord & record = general_query.record();
        p->general.insert( record.value(0).toString(), record.value(1).toString() );
    }
}

void UserData::update_db()
{
}

UserData::~UserData()
{
    delete p;
}
