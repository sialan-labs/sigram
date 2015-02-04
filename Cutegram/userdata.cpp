/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "userdata.h"
#include "cutegram.h"
#include "cutegram_macros.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QFile>
#include <QDateTime>
#include <QSettings>
#include <QHash>
#include <QFileInfo>

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

    QString phoneNumber;

    QHash<int,bool> mutes;
    QHash<int,bool> favorites;
    QHash<QString,QString> general;
    QMap<quint64, MessageUpdate> msg_updates;
};

UserData::UserData(QObject *parent) :
    QObject(parent)
{
    p = new UserDataPrivate;
}

void UserData::setPhoneNumber(const QString &phoneNumber)
{
    if(p->phoneNumber == phoneNumber)
        return;
    if(!p->phoneNumber.isEmpty())
        disconnect();

    p->phoneNumber = phoneNumber;
    p->path = AsemanApplication::homePath() + "/" + p->phoneNumber + "/userdata.db";

    if( !QFileInfo::exists(p->path) )
        QFile::copy(USERDATA_DB_PATH,p->path);

    QFile(p->path).setPermissions(QFileDevice::WriteOwner|QFileDevice::WriteGroup|QFileDevice::ReadUser|QFileDevice::ReadGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE",USERDATA_DB_CONNECTION+p->phoneNumber);
    p->db.setDatabaseName(p->path);

    if(!p->phoneNumber.isEmpty())
        reconnect();

    emit phoneNumberChanged();
}

QString UserData::phoneNumber() const
{
    return p->phoneNumber;
}

void UserData::disconnect()
{
    p->db.close();
}

void UserData::reconnect()
{
    p->db.open();
    init_buffer();
    update_db();
}

void UserData::addMute(int id)
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("INSERT OR REPLACE INTO mutes (id,mute) VALUES (:id,:mute)");
    mute_query.bindValue(":id",id);
    mute_query.bindValue(":mute",1);
    mute_query.exec();

    p->mutes.insert(id,true);
    emit muteChanged(id);
}

void UserData::removeMute(int id)
{
    QSqlQuery query(p->db);
    query.prepare("DELETE FROM mutes WHERE id=:id");
    query.bindValue(":id", id);
    query.exec();

    p->mutes.remove(id);
    emit muteChanged(id);
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
    emit favoriteChanged(id);
}

void UserData::removeFavorite(int id)
{
    QSqlQuery query(p->db);
    query.prepare("DELETE FROM favorites WHERE id=:id");
    query.bindValue(":id", id);
    query.exec();

    p->favorites.remove(id);
    emit favoriteChanged(id);
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

void UserData::addMessageUpdate(const MessageUpdate &msg)
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("INSERT OR REPLACE INTO updatemessages (id, message, date) VALUES (:id, :msg, :date)");
    mute_query.bindValue(":id"  ,msg.id);
    mute_query.bindValue(":msg" ,msg.message);
    mute_query.bindValue(":date",msg.date);
    mute_query.exec();

    p->msg_updates[msg.id] = msg;
    emit messageUpdateChanged(msg.id);
}

void UserData::removeMessageUpdate(int id)
{
    QSqlQuery query(p->db);
    query.prepare("DELETE FROM updatemessages WHERE id=:id");
    query.bindValue(":id", id);
    query.exec();

    p->msg_updates.remove(id);
    emit messageUpdateChanged(id);
}

QList<quint64> UserData::messageUpdates() const
{
    return p->msg_updates.keys();
}

MessageUpdate UserData::messageUpdateItem(int id)
{
    return p->msg_updates.value(id);
}

void UserData::setValue(const QString &key, const QString &value)
{
    QSqlQuery mute_query(p->db);
    mute_query.prepare("INSERT OR REPLACE INTO general (gkey,gvalue) VALUES (:key,:val)");
    mute_query.bindValue(":key", key);
    mute_query.bindValue(":val", value);
    mute_query.exec();

    p->general[key] = value;
    emit valueChanged(key);
}

QString UserData::value(const QString &key)
{
    return p->general.value(key);
}

void UserData::init_buffer()
{
    p->mutes.clear();
    p->favorites.clear();
    p->msg_updates.clear();
    p->general.clear();

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

    QSqlQuery msg_upd_query(p->db);
    msg_upd_query.prepare("SELECT id, message, date FROM updatemessages");
    msg_upd_query.exec();

    while( msg_upd_query.next() )
    {
        const QSqlRecord & record = msg_upd_query.record();
        MessageUpdate msg;
        msg.id = record.value(0).toULongLong();
        msg.message = record.value(1).toString();
        msg.date = record.value(2).toLongLong();

        p->msg_updates[msg.id] = msg;
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
    const int version = value("version").toInt();
    if( version < 3 )
    {
        QStringList query_list;
        query_list << "BEGIN;";
        query_list << "CREATE  TABLE IF NOT EXISTS UpdateMessages (id BIGINT NOT NULL ,message TEXT NOT NULL, date BIGINT NOT NULL, PRIMARY KEY (id) );";
        query_list << "COMMIT;";

        foreach( const QString & query_str, query_list )
            QSqlQuery( query_str, p->db ).exec();

        setValue("version","3");
    }
}

UserData::~UserData()
{
    delete p;
}
