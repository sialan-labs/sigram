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
    int unread;

    QHash<int,UserClass> contacts;
    QHash<int,DialogClass> dialogs;
    QHash<int,QString> photos;

    QHash<int,QMap<qint64, qint64> > usersMessages;
    QHash<qint64,qint64> messageDates;
    QHash<qint64,MessageClass> messages;
    QHash<qint64,qint64> messageMedias;
    QHash<qint64,qint64> messageHashes;
    QHash<int,QSet<qint64> > messagesFroms;
    QHash<int,QSet<qint64> > messagesTos;

    QHash<int, QHash<QString,qreal> > uploads;
};

TelegramThread::TelegramThread(int argc, char **argv, QObject *parent) :
    QThread(parent)
{
    p = new TelegramThreadPrivate;
    p->me = 0;
    p->unread = 0;

    qRegisterMetaType<UserClass>("UserClass");
    qRegisterMetaType<ChatClass>("ChatClass");
    qRegisterMetaType<DialogClass>("DialogClass");
    qRegisterMetaType<MessageClass>("MessageClass");
    qRegisterMetaType<WaitGetPhone>("WaitGetPhone");
    qRegisterMetaType<WaitGetAuthCode>("WaitGetAuthCode");
    qRegisterMetaType<WaitGetUserDetails>("WaitGetUserDetails");

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
    connect( p->tg, SIGNAL(fileLoaded(qint64,int,qint64,QString))            , SLOT(_fileLoaded(qint64,int,qint64,QString))                   , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(photoFound(int,qint64))                           , SLOT(_photoFound(int,qint64))                           , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(fileUploading(int,QString,qint64,qint64))         , SLOT(_fileUploading(int,QString,qint64,qint64))         , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(fileDownloading(qint64,qint64,qint64,qint64))     , SLOT(_fileDownloading(qint64,qint64,qint64,qint64))            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(waitAndGet(int))                                  , SLOT(_waitAndGet(int))                                  , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(registeringStarted())                             , SIGNAL(registeringStarted())                            , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(registeringFinished())                            , SIGNAL(registeringFinished())                           , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(registeringInvalidCode())                         , SIGNAL(registeringInvalidCode())                        , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(userIsTyping(int,int))                            , SIGNAL(userIsTyping(int,int))                           , Qt::QueuedConnection );
    connect( p->tg, SIGNAL(myStatusUpdated())                                , SIGNAL(myStatusUpdated())                               , Qt::QueuedConnection );
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

QSet<qint64> TelegramThread::messagesOf(int uid) const
{
    QSet<qint64> res = p->messagesTos.value(uid);
    res.unite(p->messagesFroms.value(uid));

    return res;
}

int TelegramThread::me() const
{
    return p->me;
}

int TelegramThread::unread() const
{
    return p->unread;
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
    QString user;
    if( p->dialogs.contains(id) )
    {
        const DialogClass & dialog = p->dialogs.value(id);
        user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    }
    else
    if( p->contacts.contains(id) )
        user = p->contacts.value(id).username;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user), Q_ARG(int,count) );
}

void TelegramThread::sendMessage(int id, const QString &msg)
{
    QString user;
    if( p->dialogs.contains(id) )
    {
        const DialogClass & dialog = p->dialogs.value(id);
        user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    }
    else
    if( p->contacts.contains(id) )
        user = p->contacts.value(id).username;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user), Q_ARG(QString,msg) );
}

void TelegramThread::forwardMessage(qint64 msg_id, int user_id)
{
    QString user;
    if( p->dialogs.contains(user_id) )
    {
        const DialogClass & dialog = p->dialogs.value(user_id);
        user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    }
    else
    if( p->contacts.contains(user_id) )
        user = p->contacts.value(user_id).username;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(qint64,msg_id), Q_ARG(QString,user) );
}

void TelegramThread::deleteMessage(qint64 msg_id)
{
    if( p->messages.contains(msg_id) )
        p->messages[msg_id].deleted = true;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
    emit messageDeleted(msg_id);
}

void TelegramThread::restoreMessage(qint64 msg_id)
{
    if( p->messages.contains(msg_id) )
        p->messages[msg_id].deleted = false;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
    emit messageRestored(msg_id);
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

void TelegramThread::loadOwnInfo()
{
    INVOKE_METHOD(Qt::QueuedConnection);
}

void TelegramThread::loadPhoto(qint64 msg_id)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
}

void TelegramThread::loadMedia(qint64 msg_id)
{
    if( !p->messages.contains(msg_id) )
        return;

    const MessageClass & msg = p->messages.value(msg_id);
    switch( static_cast<int>(msg.mediaType) )
    {
    case Enums::MediaAudio:
        QMetaObject::invokeMethod( p->tg, "loadAudio", Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
        break;

    case Enums::MediaPhoto:
        QMetaObject::invokeMethod( p->tg, "loadPhoto", Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
        break;

    case Enums::MediaVideo:
        QMetaObject::invokeMethod( p->tg, "loadVideo", Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
        break;

    case Enums::MediaDocument:
        QMetaObject::invokeMethod( p->tg, "loadDocument", Qt::QueuedConnection, Q_ARG(qint64,msg_id) );
        break;
    }
}

void TelegramThread::sendFile(int dId, const QString &file)
{
    QString user;
    if( p->dialogs.contains(dId) )
    {
        const DialogClass & dialog = p->dialogs.value(dId);
        user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    }
    else
    if( p->contacts.contains(dId) )
        user = p->contacts.value(dId).username;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user), Q_ARG(QString,file) );
}

void TelegramThread::markRead(int dId)
{
    QString user;
    if( p->dialogs.contains(dId) )
    {
        const DialogClass & dialog = p->dialogs.value(dId);
        user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    }
    else
    if( p->contacts.contains(dId) )
        user = p->contacts.value(dId).username;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user) );
}

void TelegramThread::setStatusOnline(bool stt)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(bool,stt));
}

void TelegramThread::setTypingState(int dId, bool state)
{
    QString user;
    if( p->dialogs.contains(dId) )
    {
        const DialogClass & dialog = p->dialogs.value(dId);
        user = dialog.is_chat? dialog.chatClass.title : dialog.userClass.username;
    }
    else
    if( p->contacts.contains(dId) )
        user = p->contacts.value(dId).username;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user), Q_ARG(bool,state));
}

void TelegramThread::createChat(const QString &title, int user_id)
{
    if( !p->contacts.contains(user_id) )
        return;

    const UserClass & user = p->contacts.value(user_id);
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,title), Q_ARG(QString,user.username));
}

void TelegramThread::createSecretChat(int user_id)
{
    if( !p->contacts.contains(user_id) )
        return;

    const UserClass & user = p->contacts.value(user_id);
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user.username));
}

void TelegramThread::renameChat(int chat_id, const QString &new_title)
{
    if( !p->dialogs.contains(chat_id) )
        return;

    const DialogClass & dialog = p->dialogs.value(chat_id);
    QString peer;
    if( dialog.is_chat )
        peer = dialog.chatClass.title;
    else
        return;

    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,peer), Q_ARG(QString,new_title));
}

void TelegramThread::chatAddUser(int chat_id, int user_id)
{
    if( !p->dialogs.contains(chat_id) )
        return;
    if( !p->contacts.contains(user_id) )
        return;

    const DialogClass & dialog = p->dialogs.value(chat_id);
    QString chat;
    if( dialog.is_chat )
        chat = dialog.chatClass.title;
    else
        return;

    const UserClass & user = p->contacts.value(user_id);
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,chat), Q_ARG(QString,user.username));
}

void TelegramThread::chatDelUser(int chat_id, int user_id)
{
    if( !p->dialogs.contains(chat_id) )
        return;
    if( !p->contacts.contains(user_id) )
        return;

    const DialogClass & dialog = p->dialogs.value(chat_id);
    QString chat;
    if( dialog.is_chat )
        chat = dialog.chatClass.title;
    else
        return;

    const UserClass & user = p->contacts.value(user_id);
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,chat), Q_ARG(QString,user.username));
}

void TelegramThread::addContact(const QString &number, const QString &fname, const QString &lname, bool force)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,number), Q_ARG(QString,fname), Q_ARG(QString,lname), Q_ARG(bool,force));
}

void TelegramThread::search(int user_id, const QString &keyword)
{
    if( !p->contacts.contains(user_id) )
        return;

    const UserClass & user = p->contacts.value(user_id);
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,user.username), Q_ARG(QString,keyword));
}

void TelegramThread::globalSearch(const QString &keyword)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(QString,keyword));
}

void TelegramThread::waitAndGetCallback(int type, const QVariant &var)
{
    INVOKE_METHOD(Qt::QueuedConnection, Q_ARG(int,type), Q_ARG(QVariant,var));
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

    p->contacts[contact.user_id] = contact;
    if( p->dialogs.contains(contact.user_id) )
    {
        p->dialogs[contact.user_id].userClass = contact;
        emit dialogsChanged();
    }
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
    int unread = 0;
    QHashIterator<int,DialogClass> i(p->dialogs);
    while( i.hasNext() )
    {
        i.next();
        unread += i.value().unread;
    }

    if( unread != p->unread )
    {
        p->unread = unread;
        emit unreadChanged();
    }

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

    p->messagesFroms[msg.from_id].remove(mid);
    p->messagesTos[msg.to_id].remove(mid);
    p->messagesFroms[msg.from_id].insert(msg_id);
    p->messagesTos[msg.to_id].insert(msg_id);

    if( msg.mediaType == Enums::MediaPhoto )
//    if( msg.mediaType != Enums::MediaEmpty )
    {
        p->messageMedias[msg.media.volume] = msg.msg_id;
    }
    else
    if( msg.mediaType != Enums::MediaEmpty )
    {
        p->messageHashes[msg.accessHash] = msg.msg_id;
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
    else
    if( msg.mediaType != Enums::MediaEmpty )
    {
        p->messageHashes[msg.accessHash] = msg.msg_id;
    }

    p->messages[msg.msg_id] = msg;
    p->usersMessages[msg.from_id][msg.date.toMSecsSinceEpoch()] = msg.msg_id;
    p->messageDates[msg.date.toMSecsSinceEpoch()] = msg.msg_id;
    p->messagesFroms[msg.from_id].insert(msg.msg_id);
    p->messagesTos[msg.to_id].insert(msg.msg_id);

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

void TelegramThread::_fileLoaded(qint64 volume, int localId, qint64 hash, const QString &path)
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
    if( p->messageHashes.contains(hash) )
    {
        qint64 msg_id = p->messageHashes.value(hash);
        p->messages[msg_id].mediaFile = path;
        emit msgFileDownloaded(msg_id);
    }
    else
        emit fileDownloaded(path);
}

void TelegramThread::_fileUploading(int user_id, const QString &file, qint64 total, qint64 uploaded)
{
    qreal percent = uploaded*100.0/total;
    p->uploads[user_id][file] = percent;

    qreal user_percent = 0;
    const QHash<QString,qreal> & percent_hash = p->uploads[user_id];
    QHashIterator<QString,qreal> i(percent_hash);
    while( i.hasNext() )
    {
        i.next();
        user_percent += i.value()/percent_hash.count();
    }

    emit fileUploading( user_id, file, percent );
    emit fileUserUploading( user_id, user_percent );

    if( total <= uploaded )
    {
        emit fileUploaded( user_id, file );
        p->uploads[user_id].remove(file);

        if( p->uploads[user_id].isEmpty() )
            emit fileUserUploaded( user_id );
    }
}

void TelegramThread::_fileDownloading(qint64 volume, qint64 total, qint64 hash, qint64 downloaded)
{
    if( p->messageMedias.contains(volume) )
    {
        qint64 msg_id = p->messageMedias.value(volume);
        emit msgFileDownloading( msg_id, downloaded*100.0/total );
    }
    else
    if( p->messageHashes.contains(hash) )
    {
        qint64 msg_id = p->messageHashes.value(hash);
        emit msgFileDownloading(msg_id, downloaded*100.0/total);
    }
}

void TelegramThread::_waitAndGet(int type)
{
    emit waitAndGet(type);
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
