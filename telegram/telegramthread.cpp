#define INVOKE_METHOD(...) QMetaObject::invokeMethod(p->tg,__FUNCTION__,__VA_ARGS__)

#include "telegramthread.h"
#include "strcuts.h"
#include "telegramcore.h"

#include <QTimer>
#include <QMap>

class TelegramThreadPrivate
{
public:
    TelegramCore *tg;
    QHash<int,UserClass> contacts;
    QHash<int,DialogClass> dialogs;

    QHash<int,QMap<qint64, qint64> > usersMessages;
    QHash<qint64,qint64> messageDates;
    QHash<qint64,MessageClass> messages;
};

TelegramThread::TelegramThread(int argc, char **argv, QObject *parent) :
    QThread(parent)
{
    p = new TelegramThreadPrivate;

    qRegisterMetaType<UserClass>("UserClass");
    qRegisterMetaType<ChatClass>("ChatClass");
    qRegisterMetaType<DialogClass>("DialogClass");
    qRegisterMetaType<MessageClass>("MessageClass");

    p->tg = new TelegramCore(argc,argv);
//    p->tg->moveToThread(this);

    connect( p->tg, SIGNAL(contactListClear())                   , SLOT(_contactListClear())                   , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(contactFounded(UserClass))            , SLOT(_contactFounded(UserClass))            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(contactListFinished())                , SLOT(_contactListFinished())                , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(dialogListClear())                    , SLOT(_dialogListClear())                    , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(dialogFounded(DialogClass))           , SLOT(_dialogFounded(DialogClass))           , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(dialogListFinished())                 , SLOT(_dialogListFinished())                 , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(msgMarkedAsRead(qint64,QDateTime))    , SLOT(_msgMarkedAsRead(qint64,QDateTime))    , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(msgSent(qint64,QDateTime))            , SLOT(_msgSent(qint64,QDateTime))            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(incomingMsg(MessageClass))            , SLOT(_incomingMsg(MessageClass))            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(userStatusChanged(int,int,QDateTime)) , SLOT(_userStatusChanged(int,int,QDateTime)) , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(userIsTyping(int,int))                , SIGNAL(userIsTyping(int,int))               , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(started())                            , SIGNAL(tgStarted())                         , Qt::QueuedConnection );

    start();
}

int TelegramThread::callExec()
{
    return exec();
}

const QHash<int, UserClass> &TelegramThread::contacts() const
{
    return p->contacts;
}

const QHash<int, DialogClass> &TelegramThread::dialogs() const
{
    return p->dialogs;
}

const QHash<int, QMap<qint64, qint64> > &TelegramThread::usersMessages() const
{
    return p->usersMessages;
}

const QHash<qint64, MessageClass> &TelegramThread::messages() const
{
    return p->messages;
}

void TelegramThread::contactList()
{
    INVOKE_METHOD(Qt::QueuedConnection);
}

void TelegramThread::dialogList()
{
    INVOKE_METHOD(Qt::QueuedConnection);
}

void TelegramThread::getHistory(int id, int count)
{
    const DialogClass & dialog = p->dialogs.value(id);
    const QString & user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user), Q_ARG(int,count) );
}

void TelegramThread::sendMessage(int id, const QString &msg)
{
    const DialogClass & dialog = p->dialogs.value(id);
    const QString & user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user), Q_ARG(QString,msg) );
}

void TelegramThread::run()
{
    p->tg->start();
}

void TelegramThread::_contactListClear()
{
    p->contacts.clear();
}

void TelegramThread::_contactFounded(const UserClass &contact)
{
    p->contacts.insert( contact.user_id, contact );
}

void TelegramThread::_contactListFinished()
{
    emit contactsChanged();
}

void TelegramThread::_dialogListClear()
{
    p->dialogs.clear();
}

void TelegramThread::_dialogFounded(const DialogClass &dialog)
{
    if( dialog.is_chat )
        p->dialogs.insert( dialog.chatClass.chat_id, dialog );
    else
        p->dialogs.insert( dialog.userClass.user_id, dialog );
}

void TelegramThread::_dialogListFinished()
{
    emit dialogsChanged();
}

void TelegramThread::_msgMarkedAsRead(qint64 msg_id, const QDateTime &date)
{
    _msgSent(msg_id,date);
    p->messages[msg_id].unread = 0;
    emit msgChanged(msg_id);
}

void TelegramThread::_msgSent(qint64 msg_id, const QDateTime & date)
{
    qint64 msec = date.toMSecsSinceEpoch();
    if( !p->messageDates.contains(msec) )
    {
        emit msgSent(0, msg_id);
        return;
    }

    qint64 mid = p->messageDates.value(msec);
    if( mid == msg_id )
        return;

    MessageClass msg = p->messages.value(mid);
    msg.msg_id = msg_id;

    p->messages[msg.msg_id] = msg;
    p->usersMessages[msg.from_id][msg.date.toMSecsSinceEpoch()] = msg.msg_id;
    p->messageDates[msg.date.toMSecsSinceEpoch()] = msg.msg_id;

    p->messages.remove(mid);

    emit msgSent(mid,msg_id);
}

void TelegramThread::_incomingMsg(const MessageClass &msg)
{
    p->messages[msg.msg_id] = msg;
    p->usersMessages[msg.from_id][msg.date.toMSecsSinceEpoch()] = msg.msg_id;
    p->messageDates[msg.date.toMSecsSinceEpoch()] = msg.msg_id;

    emit incomingMsg(msg.msg_id);
}

void TelegramThread::_userStatusChanged(int user_id, int status, const QDateTime & when)
{
    p->contacts[user_id].state = static_cast<TgStruncts::OnlineState>(status);
    p->contacts[user_id].lastTime = when;

    emit userStatusChanged(user_id,status,when);
}

TelegramThread::~TelegramThread()
{
    delete p;
}
