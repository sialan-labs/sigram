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
};

UserData::UserData(QObject *parent) :
    QObject(parent)
{
    p = new UserDataPrivate;
    p->path = HOME_PATH  + "/userdata.sqlite";

    if( !TelegramGui::settings()->value("initialize/userdata_db",false).toBool() )
        QFile::copy("database/userdata.sqlite",p->path);

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
            user.state = TgStruncts::Offline;

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
}

UserData::~UserData()
{
    delete p;
}
