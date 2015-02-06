#define FIRST_CHECK if(!p->core) return;

#include "database.h"
#include "databasecore.h"
#include "cutegram_macros.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"

#include <QFile>
#include <QFileInfo>
#include <QThread>

class DatabasePrivate
{
public:
    QString path;

    QThread *thread;
    DatabaseCore *core;

    QString phoneNumber;
};

Database::Database(QObject *parent) :
    QObject(parent)
{
    p = new DatabasePrivate;
    p->thread = 0;
    p->core = 0;
}

void Database::setPhoneNumber(const QString &phoneNumber)
{
    if(p->phoneNumber == phoneNumber)
        return;

    p->phoneNumber = phoneNumber;

    if(p->phoneNumber.isEmpty())
    {
        if(p->core && p->thread)
        {
            p->thread->quit();
            p->thread->wait();
            p->thread->deleteLater();
            p->core->deleteLater();
            p->thread = 0;
            p->core = 0;
        }
    }
    else
    {
        p->path = AsemanApplication::homePath() + "/" + p->phoneNumber + "/database.db";

        if( !QFileInfo::exists(p->path) )
            QFile::copy(DATABASE_DB_PATH,p->path);

        QFile(p->path).setPermissions(QFileDevice::WriteOwner|QFileDevice::WriteGroup|QFileDevice::ReadUser|QFileDevice::ReadGroup);

        p->core = new DatabaseCore(p->path, p->phoneNumber);
        p->thread = new QThread(this);
        p->thread->start();

        p->core->moveToThread(p->thread);

        connect(p->core, SIGNAL(chatFounded(DbChat))         , SLOT(chatFounded_slt(DbChat))         , Qt::QueuedConnection );
        connect(p->core, SIGNAL(userFounded(DbUser))         , SLOT(userFounded_slt(DbUser))         , Qt::QueuedConnection );
        connect(p->core, SIGNAL(dialogFounded(DbDialog,bool)), SLOT(dialogFounded_slt(DbDialog,bool)), Qt::QueuedConnection );
        connect(p->core, SIGNAL(messageFounded(DbMessage))   , SLOT(messageFounded_slt(DbMessage))   , Qt::QueuedConnection );
        connect(p->core, SIGNAL(mediaKeyFounded(qint64,QByteArray,QByteArray)),
                SIGNAL(mediaKeyFounded(qint64,QByteArray,QByteArray)), Qt::QueuedConnection );
    }

    emit phoneNumberChanged();
}

QString Database::phoneNumber() const
{
    return p->phoneNumber;
}

void Database::insertUser(const User &user)
{
    FIRST_CHECK;
    DbUser duser;
    duser.user = user;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbUser,duser));
}

void Database::insertChat(const Chat &chat)
{
    FIRST_CHECK;
    DbChat dchat;
    dchat.chat = chat;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbChat,dchat));
}

void Database::insertDialog(const Dialog &dialog, bool encrypted)
{
    FIRST_CHECK;
    DbDialog ddlg;
    ddlg.dialog = dialog;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbDialog,ddlg), Q_ARG(bool,encrypted));
}

void Database::insertMessage(const Message &message)
{
    FIRST_CHECK;
    DbMessage dmsg;
    dmsg.message = message;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbMessage,dmsg));
}

void Database::insertMediaEncryptedKeys(qint64 mediaId, const QByteArray &key, const QByteArray &iv)
{
    FIRST_CHECK;
    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(qint64,mediaId), Q_ARG(QByteArray,key), Q_ARG(QByteArray,iv));
}

void Database::readFullDialogs()
{
    FIRST_CHECK;
    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection);
}

void Database::readMessages(const Peer &peer, int offset, int limit)
{
    FIRST_CHECK;
    DbPeer dpeer;
    dpeer.peer = peer;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbPeer,dpeer), Q_ARG(int,offset), Q_ARG(int,limit) );
}

void Database::deleteMessage(qint64 msgId)
{
    FIRST_CHECK;
    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(qint64,msgId));
}

void Database::deleteDialog(qint64 dlgId)
{
    FIRST_CHECK;
    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(qint64,dlgId));
}

void Database::deleteHistory(qint64 dlgId)
{
    FIRST_CHECK;
    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(qint64,dlgId));
}

void Database::userFounded_slt(const DbUser &user)
{
    emit userFounded(user.user);
}

void Database::chatFounded_slt(const DbChat &chat)
{
    emit chatFounded(chat.chat);
}

void Database::dialogFounded_slt(const DbDialog &dialog, bool encrypted)
{
    emit dialogFounded(dialog.dialog, encrypted);
}

void Database::messageFounded_slt(const DbMessage &message)
{
    emit messageFounded(message.message);
}

Database::~Database()
{
    delete p;
}
