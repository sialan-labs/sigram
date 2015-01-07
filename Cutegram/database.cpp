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
};

Database::Database(const QString &phoneNumber, QObject *parent) :
    QObject(parent)
{
    p = new DatabasePrivate;
    p->path = AsemanApplication::homePath() + "/" + phoneNumber + "/database.db";

    if( !QFileInfo::exists(p->path) )
        QFile::copy(DATABASE_DB_PATH,p->path);

    QFile(p->path).setPermissions(QFileDevice::WriteOwner|QFileDevice::WriteGroup|QFileDevice::ReadUser|QFileDevice::ReadGroup);

    p->core = new DatabaseCore(p->path, phoneNumber);
    p->thread = new QThread(this);
    p->thread->start();

    p->core->moveToThread(p->thread);

    connect(p->core, SIGNAL(chatFounded(DbChat))      , SLOT(chatFounded_slt(DbChat))      , Qt::QueuedConnection );
    connect(p->core, SIGNAL(userFounded(DbUser))      , SLOT(userFounded_slt(DbUser))      , Qt::QueuedConnection );
    connect(p->core, SIGNAL(dialogFounded(DbDialog))  , SLOT(dialogFounded_slt(DbDialog))  , Qt::QueuedConnection );
    connect(p->core, SIGNAL(messageFounded(DbMessage)), SLOT(messageFounded_slt(DbMessage)), Qt::QueuedConnection );
}

void Database::insertUser(const User &user)
{
    DbUser duser;
    duser.user = user;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbUser,duser));
}

void Database::insertChat(const Chat &chat)
{
    DbChat dchat;
    dchat.chat = chat;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbChat,dchat));
}

void Database::insertDialog(const Dialog &dialog)
{
    DbDialog ddlg;
    ddlg.dialog = dialog;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbDialog,ddlg));
}

void Database::insertMessage(const Message &message)
{
    DbMessage dmsg;
    dmsg.message = message;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbMessage,dmsg));
}

void Database::readFullDialogs()
{
    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection);
}

void Database::readMessages(const Peer &peer, int offset, int limit)
{
    DbPeer dpeer;
    dpeer.peer = peer;

    QMetaObject::invokeMethod(p->core, __FUNCTION__, Qt::QueuedConnection, Q_ARG(DbPeer,dpeer), Q_ARG(int,offset), Q_ARG(int,limit) );
}

void Database::userFounded_slt(const DbUser &user)
{
    emit userFounded(user.user);
}

void Database::chatFounded_slt(const DbChat &chat)
{
    emit chatFounded(chat.chat);
}

void Database::dialogFounded_slt(const DbDialog &dialog)
{
    emit dialogFounded(dialog.dialog);
}

void Database::messageFounded_slt(const DbMessage &message)
{
    emit messageFounded(message.message);
}

Database::~Database()
{
    delete p;
}
