#define INVOKE_METHOD(...) QMetaObject::invokeMethod(p->tg,__FUNCTION__,__VA_ARGS__)
#define DOWNLOADS_PATH QString( QDir::homePath() + "/.telegram/downloads/" )

#include "telegramthread.h"
#include "strcuts.h"
#include "telegramcore.h"

#include <QDir>
#include <QTimer>
#include <QMap>
#include <QFile>

class TelegramThreadPrivate
{
public:
    TelegramCore *tg;

    int me;

    QHash<int,UserClass> contacts;
    QHash<int,DialogClass> dialogs;
    QHash<int,QString> photos;

    QHash<int,QMap<qint64, qint64> > usersMessages;
    QHash<qint64,qint64> messageDates;
    QHash<qint64,MessageClass> messages;
    QHash<qint64,qint64> messageMedias;
};

TelegramThread::TelegramThread(int argc, char **argv, QObject *parent) :
    QThread(parent)
{
    p = new TelegramThreadPrivate;
    p->me = 0;

    qRegisterMetaType<UserClass>("UserClass");
    qRegisterMetaType<ChatClass>("ChatClass");
    qRegisterMetaType<DialogClass>("DialogClass");
    qRegisterMetaType<MessageClass>("MessageClass");

    p->tg = new TelegramCore(argc,argv);
//    p->tg->moveToThread(this);

    connect( p->tg, SIGNAL(contactListClear())                               , SLOT(_contactListClear())                               , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(contactFounded(UserClass))                        , SLOT(_contactFounded(UserClass))                        , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(contactListFinished())                            , SLOT(_contactListFinished())                            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(dialogListClear())                                , SLOT(_dialogListClear())                                , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(dialogFounded(DialogClass))                       , SLOT(_dialogFounded(DialogClass))                       , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(dialogListFinished())                             , SLOT(_dialogListFinished())                             , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(msgMarkedAsRead(qint64,QDateTime))                , SLOT(_msgMarkedAsRead(qint64,QDateTime))                , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(msgSent(qint64,QDateTime))                        , SLOT(_msgSent(qint64,QDateTime))                        , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(incomingMsg(MessageClass))                        , SLOT(_incomingMsg(MessageClass))                        , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(userStatusChanged(int,int,QDateTime))             , SLOT(_userStatusChanged(int,int,QDateTime))             , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(fileLoaded(qint64,int,QString))                   , SLOT(_fileLoaded(qint64,int,QString))                   , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(photoFound(int,qint64))                           , SLOT(_photoFound(int,qint64))                           , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(fileUploading(int,QString,qint64,qint64))         , SLOT(_fileUploading(int,QString,qint64,qint64))         , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(fileDownloading(qint64,qint64,qint64))            , SLOT(_fileDownloading(qint64,qint64,qint64))            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(userIsTyping(int,int))                            , SIGNAL(userIsTyping(int,int))                           , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(started())                                        , SIGNAL(tgStarted())                                     , Qt::QueuedConnection );

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

const QHash<int, QString> &TelegramThread::photos() const
{
    return p->photos;
}

const QHash<int, QMap<qint64, qint64> > &TelegramThread::usersMessages() const
{
    return p->usersMessages;
}

const QHash<qint64, MessageClass> &TelegramThread::messages() const
{
    return p->messages;
}

int TelegramThread::me() const
{
    return p->me;
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

void TelegramThread::loadUserInfo(int userId)
{
    if( !p->contacts.contains(userId) )
        return;

    const UserClass & user = p->contacts.value(userId);
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user.username) );
}

void TelegramThread::loadChatInfo(int chatId)
{
    if( !p->dialogs.contains(chatId) )
        return;

    const DialogClass & dialog = p->dialogs.value(chatId);
    if( !dialog.is_chat )
    {
        loadUserInfo( chatId );
        return;
    }

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,dialog.chatClass.title) );
}

void TelegramThread::loadPhoto(qint64 msg_id)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
}

void TelegramThread::sendFile(int dId, const QString &file)
{
    if( !p->dialogs.contains(dId) )
        return;

    const DialogClass & dialog = p->dialogs.value(dId);
    QString peer;
    if( dialog.is_chat )
        peer = dialog.chatClass.title;
    else
        peer = dialog.userClass.username;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,peer), Q_ARG(QString,file) );
}

void TelegramThread::markRead(int dId)
{
    if( !p->dialogs.contains(dId) )
        return;

    const DialogClass & dialog = p->dialogs.value(dId);
    QString peer;
    if( dialog.is_chat )
        peer = dialog.chatClass.title;
    else
        peer = dialog.userClass.username;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,peer) );
}

void TelegramThread::setStatusOnline(bool stt)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(bool,stt));
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
    if( contact.flags & Enums::UserUserSelf )
        p->me = contact.user_id;

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

    if( msg.mediaType == Enums::MediaPhoto )
//    if( msg.mediaType != Enums::MediaEmpty )
    {
        p->messageMedias[msg.media.volume] = msg.msg_id;
    }

    p->messages.remove(mid);

    emit msgSent(mid,msg_id);
}

void TelegramThread::_incomingMsg(const MessageClass &_msg)
{
    MessageClass msg = _msg;
    if( p->messages.contains(msg.msg_id) )
    {
        emit incomingMsg(msg.msg_id);
        return;
    }

    if( msg.mediaType == Enums::MediaPhoto )
//    if( msg.mediaType != Enums::MediaEmpty )
    {
        p->messageMedias[msg.media.volume] = msg.msg_id;

        const QStringList & downloads = QDir(DOWNLOADS_PATH).entryList(QDir::Files);
        foreach( const QString & f, downloads )
            if( f.contains(QString::number(msg.media.volume)) )
            {
                msg.mediaFile = DOWNLOADS_PATH + "/" + f;
                break;
            }

        if( msg.mediaFile.isEmpty() )
            loadPhoto( msg.msg_id );
    }

    p->messages[msg.msg_id] = msg;
    p->usersMessages[msg.from_id][msg.date.toMSecsSinceEpoch()] = msg.msg_id;
    p->messageDates[msg.date.toMSecsSinceEpoch()] = msg.msg_id;
    p->messageMedias[msg.media.volume] = msg.msg_id;

    emit incomingNewMsg(msg.msg_id);
    emit incomingMsg(msg.msg_id);
}

void TelegramThread::_userStatusChanged(int user_id, int status, const QDateTime & when)
{
    p->contacts[user_id].state = static_cast<Enums::OnlineState>(status);
    p->contacts[user_id].lastTime = when;

    emit userStatusChanged(user_id,status,when);
}

void TelegramThread::_photoFound(int id, qint64 volume)
{
    QHashIterator<int,UserClass> ci(p->contacts);
    while( ci.hasNext() )
    {
        ci.next();
        if( ci.value().user_id == id )
        {
            p->contacts[ci.key()].photoId = volume;
            break;
        }
    }

    QHashIterator<int,DialogClass> di(p->dialogs);
    while( di.hasNext() )
    {
        di.next();
        if( di.value().is_chat && di.value().chatClass.chat_id == id )
        {
            p->dialogs[di.key()].chatClass.photoId = volume;
            break;
        }
        else
        if( !di.value().is_chat && di.value().userClass.user_id == id )
        {
            p->dialogs[di.key()].userClass.photoId = volume;
            break;
        }
    }
}

void TelegramThread::_fileLoaded(qint64 volume, int localId, const QString &path)
{
    Q_UNUSED(localId)
    QHashIterator<int,UserClass> ci(p->contacts);
    while( ci.hasNext() )
    {
        ci.next();
        if( ci.value().photoId == volume )
        {
            p->photos.insert( ci.key(), path );
            emit userPhotoChanged(ci.key());
            break;
        }
    }

    QHashIterator<int,DialogClass> di(p->dialogs);
    while( di.hasNext() )
    {
        di.next();
        if( di.value().is_chat && di.value().chatClass.photoId == volume )
        {
            p->photos.insert( di.key(), path );
            emit chatPhotoChanged(di.key());
            break;
        }
        else
        if( !di.value().is_chat && di.value().userClass.photoId == volume )
        {
            p->photos.insert( di.key(), path );
            emit userPhotoChanged(di.key());
            break;
        }
    }

    if( p->messageMedias.contains(volume) )
    {
        qint64 msg_id = p->messageMedias.value(volume);
        p->messages[msg_id].mediaFile = path;
        emit msgFileDownloaded(msg_id);
    }
}

void TelegramThread::_fileUploading(int user_id, const QString &file, qint64 total, qint64 uploaded)
{

}

void TelegramThread::_fileDownloading(qint64 volume, qint64 total, qint64 downloaded)
{
    if( p->messageMedias.contains(volume) )
    {
        qint64 msg_id = p->messageMedias.value(volume);
        emit msgFileDownloading( msg_id, downloaded*100.0/total );
    }
}

QString TelegramThread::normalizePhoto(const QString &path)
{
    return path;
    QString npath = path + ".jpg";
    QFile::remove(npath);
    QFile::copy(path,npath);
    return npath;

}

TelegramThread::~TelegramThread()
{
    delete p;
}
