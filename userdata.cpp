#include "userdata.h"
#include "telegramgui.h"
#include "telegram/strcuts.h"
#include "telegram_macros.h"

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QFile>
#include <QDateTime>
#include <QSettings>
#include <QHash>

class UserDataPrivate
{
public:
    QSqlDatabase db;
    QString path;

    QHash<int,DialogClass> dialogs;
    QHash<int,UserClass> contacts;
    QHash<int,QString> photos;

    QHash<int,bool> mutes;
};

UserData::UserData(QObject *parent) :
    QObject(parent)
{
    p = new UserDataPrivate;
    p->path = HOME_PATH  + "/userdata.db";

    if( !TelegramGui::settings()->value("initialize/userdata_db",false).toBool() )
        QFile::copy("database/userdata.db",p->path);

    TelegramGui::settings()->setValue("initialize/userdata_db",true);
    QFile(p->path).setPermissions(QFileDevice::WriteOwner|QFileDevice::WriteGroup|QFileDevice::ReadUser|QFileDevice::ReadGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE",USERDATAS_DB_CONNECTION);
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

void UserData::init_buffer()
{
    QSqlQuery user_query(p->db);
    user_query.prepare("SELECT id, isChat, unread, ldate, lastMsg, photo, title, firstname, lastname, phone FROM dialogs");
    user_query.exec();

    while( user_query.next() )
    {
        const QSqlRecord & record = user_query.record();
        for( int i=0; i<record.count(); i++ )
        {
            qint64 id = record.value(0).toLongLong();
            int is_chat = record.value(1).toInt();
            int unread = record.value(2).toInt();
            qint64 ldate = record.value(3).toInt();
            QString lastMsg = record.value(4).toString();
            QString photo = record.value(5).toString();
            QString title = record.value(6).toString();
            QString fname = record.value(7).toString();
            QString lname = record.value(8).toString();
            QString phone = record.value(9).toString();

            UserClass user;
            user.username = title;
            user.firstname = fname;
            user.lastname = lname;
            user.phone = phone;
            user.state = Enums::Offline;

            p->contacts.insert( id, user );

            if( is_chat == 0 )
            {
                DialogClass dialog;
                dialog.is_chat = false;
                dialog.msgLast = lastMsg;
                dialog.unread = unread;
                dialog.msgDate = QDateTime::fromMSecsSinceEpoch(ldate);
                dialog.userClass = user;

                p->dialogs.insert( id, dialog );
            }
            else
            if( is_chat == 1 )
            {
                DialogClass dialog;
                dialog.is_chat = true;
                dialog.msgLast = lastMsg;
                dialog.unread = unread;
                dialog.msgDate = QDateTime::fromMSecsSinceEpoch(ldate);
                dialog.chatClass.chat_id = id;
                dialog.chatClass.title = title;

                p->dialogs.insert( id, dialog );
            }

            p->photos.insert( id, photo );
        }
    }

    QSqlQuery mute_query(p->db);
    mute_query.prepare("SELECT id, mute FROM mutes");
    mute_query.exec();

    while( mute_query.next() )
    {
        const QSqlRecord & record = mute_query.record();
        p->mutes.insert( record.value(0).toInt(), record.value(1).toInt() );
    }
}

UserData::~UserData()
{
    delete p;
}
