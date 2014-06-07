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

#include "telegramcore.h"
#include "telegramthread.h"
#include "telegramcore_p.h"
#include "strcuts.h"
#include "limits"

extern "C" {
#include "telegram_cli/tmain.h"
#include "telegram_cli/structers-only.h"
}

#include <QCoreApplication>
#include <QSet>
#include <QDateTime>
#include <QMimeDatabase>
#include <QWaitCondition>
#include <QMutex>

QSet<TelegramCore*> telegram_objects;

class TelegramCorePrivare
{
public:
    int argc;
    char **argv;

    QMimeDatabase mime_db;
};

char* strcpy2(char*& dest, const char* src) {
    int i = strlen(src);
    dest = new char[i+1];
    int j = 0;
    while (j < i) {
        dest[j] = src[j];
        j++;
    }
    dest[i] = 0;
    return dest;
}

TelegramCore::TelegramCore(int argc, char **argv, QObject *parent) :
    QObject(parent)
{
    p = new TelegramCorePrivare;
    p->argc = argc;
    p->argv = argv;

    telegram_objects.insert(this);
}

void TelegramCore::contactList()
{
    send_command("contact_list");
}

void TelegramCore::dialogList()
{
    send_command("dialog_list");
}

void TelegramCore::getHistory(const QString &user, int count)
{
    send_command( QString("history %1 %2").arg(QString(user).replace(" ","_")).arg(count) );
}

void TelegramCore::sendMessage(const QString &user, const QString &msg)
{
    send_command( QString("msg %1 %2").arg(QString(user).replace(" ","_")).arg(msg) );
}

void TelegramCore::forwardMessage(qint64 msg_id, const QString &user)
{
    send_command( QString("fwd %1 %2").arg(QString(user).replace(" ","_")).arg(msg_id) );
}

void TelegramCore::deleteMessage(qint64 msg_id)
{
    send_command( QString("delete_msg %1").arg(msg_id) );
}

void TelegramCore::restoreMessage(qint64 msg_id)
{
    send_command( QString("restore_msg %1").arg(msg_id) );
}

void TelegramCore::setStatusOnline(bool stt)
{
    if( stt )
        send_command("status_online");
    else
        send_command("status_offline");
}

void TelegramCore::loadUserInfo(const QString &user)
{
    send_command( QString("user_info %1").arg(QString(user).replace(" ","_")) );
}

void TelegramCore::loadChatInfo(const QString &chat)
{
    send_command( QString("chat_info %1").arg(QString(chat).replace(" ","_")) );
}

void TelegramCore::loadPhoto(qint64 msg_id)
{
    send_command( QString("load_photo %1").arg(msg_id) );
}

void TelegramCore::sendFile(const QString &peer, const QString &file)
{
    const QMimeType & t = p->mime_db.mimeTypeForFile(file);
    QString cmd = "send_text";
    if( t.name().contains("image") )
        cmd = "send_photo";
    else
    if( t.name().contains("video") )
        cmd = "send_video";

    send_command( QString("%1 %2 %3").arg(cmd).arg(QString(peer).replace(" ","_")).arg(file) );
}

void TelegramCore::markRead(const QString &peer)
{
    send_command( QString("mark_read %1").arg(QString(peer).replace(" ","_")) );
}

void TelegramCore::createChat(const QString &title, const QString &user)
{
    send_command( QString("create_group_chat %1 %2").arg(QString(user).replace(" ","_")).arg(title) );
}

void TelegramCore::createSecretChat(const QString &user)
{
    send_command( QString("create_secret_chat %1").arg(QString(user).replace(" ","_")) );
}

void TelegramCore::renameChat(const QString &title, const QString &new_title)
{
    send_command( QString("rename_chat %1 %2").arg(QString(title).replace(" ","_")).arg(new_title) );
}

void TelegramCore::chatAddUser(const QString &chat, const QString &user)
{
    send_command( QString("chat_add_user %1 %2").arg(QString(chat).replace(" ","_"))
                  .arg(QString(user).replace(" ","_")));
}

void TelegramCore::chatDelUser(const QString &chat, const QString &user)
{
    send_command( QString("chat_del_user %1 %2").arg(QString(chat).replace(" ","_"))
                  .arg(QString(user).replace(" ","_")));
}

void TelegramCore::search(const QString &user, const QString &keyword)
{
    send_command( QString("search %1 %2").arg(QString(user).replace(" ","_")).arg(keyword) );
}

void TelegramCore::globalSearch(const QString &keyword)
{
    send_command( QString("global_search %1").arg(keyword) );
}

void TelegramCore::waitAndGetCallback(int type, const QVariant &var)
{
    waitAndGet_callback( type, var );
}

void TelegramCore::start()
{
    tmain(p->argc,p->argv);
}

void TelegramCore::send_command(const QString &cmd)
{
    sendCommand(cmd.toUtf8().data());
}

TelegramCore::~TelegramCore()
{
    telegram_objects.remove(this);
    delete p;
}

QDateTime convertDate(int d)
{
    const QDate & date = QDate(dateYear(d), dateMonth(d), dateDay(d));
    const QTime & time = QTime(dateHour(d), dateMinute(d), dateSecond(d));
    return QDateTime( date, time );
}

int getUnknownIdentifier()
{
    static int start = INT_MIN;
    start++;
    return start;
}

void tgStarted()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->started();
}

#include <QFile>
void debugToFile(const char *m)
{
    static QFile *f = new QFile("/home/bardia/test");
    if( !f->isOpen() )
        f->open(QFile::WriteOnly);

    f->write(QDateTime::currentDateTime().time().toString("hh:mm:ss:zzz").toLatin1());
    f->write(":  ");
    f->write(m);
    f->write("\n");
    f->flush();
}

void debugNumToFile( double m )
{
    debugToFile( QString::number(m).toLatin1() );
}

void qdebug( const char *m )
{
    qDebug() << m;
}

void qdebugNum( int m )
{
    qDebug() << m;
}

void mSleep(int s)
{
    QThread::msleep(s);
}

void contactList_clear()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->contactListClear();
}

void contactList_addToBuffer( struct user *u )
{
    int state = 0;
    if( u->status.online > 0 )
        state = 1;
    else
    if( u->status.online < 0 )
        state = -1;

    UserClass contact;
    contact.username = u->print_name;
    contact.type = u->id.type;
    contact.user_id = u->id.id;
    contact.firstname = u->first_name;
    contact.lastname = u->last_name;
    contact.phone = u->phone;
    contact.state = static_cast<Enums::OnlineState>(state);
    contact.flags = static_cast<Enums::UserFlags>(u->flags);
    contact.lastTime = convertDate(u->status.when);

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->contactFounded( contact );
}

void contactList_finished()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->contactListFinished();
}

void dialogList_clear()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogListClear();
}

void dialogList_addToBuffer( peer_t *uc, int is_chat, int unread_cnt )
{
    DialogClass dialog;
    dialog.is_chat = is_chat;
    dialog.unread = unread_cnt;
    dialog.msgDate = convertDate(uc->last->date);
    dialog.flags = uc->flags;

    UserClass & user = dialog.userClass;
    ChatClass & chat = dialog.chatClass;

    if( is_chat )
    {
        chat.admin = uc->chat.admin_id;
        chat.chat_id = uc->chat.id.id;
        chat.title = uc->chat.title;
        chat.type = uc->chat.id.type;
        chat.users_num = uc->chat.users_num;
        chat.date = convertDate(uc->last->date);
        chat.flags = uc->last->flags;

        for( int i=0; i<uc->chat.user_list_size; i++ )
        {
            ChatUserClass user;
            user.user_id = uc->chat.user_list[i].user_id;
            user.inviter_id = uc->chat.user_list[i].inviter_id;
            user.date = convertDate(uc->chat.user_list[i].date);

            chat.users << user;
        }

        if( qAbs(dialog.msgDate.daysTo(QDateTime::currentDateTime())) > 32 )
            dialog.msgDate = chat.date;
    }
    else
    {
        int state = 0;
        if( uc->user.status.online > 0 )
            state = 1;
        else
        if( uc->user.status.online < 0 )
            state = -1;

        user.username = uc->user.print_name;
        user.user_id = uc->user.id.id;
        user.type = uc->user.id.type;
        user.firstname = uc->user.first_name;
        user.lastname = uc->user.last_name;
        user.phone = uc->user.phone;
        user.state = static_cast<Enums::OnlineState>(state);
        user.flags = static_cast<Enums::UserFlags>(uc->user.flags);
        user.lastTime = convertDate(uc->user.status.when);
    }

    if( !(uc->last->flags & Enums::UserMessageEmpty) && uc->last->media.type != 0 && uc->last->service == 0 )
        dialog.msgLast = uc->last->msg;

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogFounded(dialog);
}

void dialogList_finished()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogListFinished();
}

void msgMarkedAsRead( long long msg_id, int date )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->msgMarkedAsRead(msg_id,convertDate(date));
}

void msgSent( long long msg_id, int date )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->msgSent(msg_id,convertDate(date));
}

void incomingMsg( struct message *m, struct user *u )
{
    MessageClass msg;
    msg.msg_id = m->id;
    msg.fwd_id = m->fwd_from_id.id;
    msg.fwd_date = convertDate(m->fwd_date);
    msg.out = m->out;
    msg.unread = m->unread;
    msg.date = convertDate(m->date);
    msg.service = m->service;
    msg.from_id = m->from_id.id;
    msg.to_id = m->to_id.id;
    msg.firstName = u->first_name;
    msg.lastName = u->last_name;
    msg.flags = m->flags;
    msg.mediaType = static_cast<Enums::MessageType>(m->media.type);
    msg.action = static_cast<Enums::MessageAction>(m->action.type);

    if( msg.mediaType == Enums::MediaEmpty && !msg.service )
        msg.message = QString(m->msg);

    switch( m->action.type )
    {
    case Enums::MessageActionEmpty:
        break;

    case Enums::MessageActionChatCreate:
    case Enums::MessageActionChatEditTitle:
        msg.actionNewTitle = m->action.new_title;
        break;

    case Enums::MessageActionChatEditPhoto:
    case Enums::MessageActionChatDeletePhoto:
        break;

    case Enums::MessageActionChatAddUser:
    case Enums::MessageActionChatDeleteUser:
        msg.actionUser = m->action.user;
        msg.actionUser = m->action.user;
        break;

    case Enums::MessageActionGeoChatCreate:
    case Enums::MessageActionGeoChatCheckin:
        break;
    }

    switch( m->media.type )
    {
    case Enums::MediaEmpty:
        break;

    case Enums::MediaContact:
        break;

    case Enums::MediaGeo:
        msg.media.latitude = m->media.geo.latitude;
        msg.media.longitude = m->media.geo.longitude;
        break;

    case Enums::MediaPhoto:
        msg.media.volume = m->media.photo.sizes->loc.volume;
        msg.media.secret = m->media.photo.sizes->loc.secret;
        break;

    case Enums::MediaVideo:
        break;

    case Enums::MediaUnsupported:
        break;
    }

    if( msg.out && (msg.flags&Enums::UserPending) )
        msg.msg_id = getUnknownIdentifier();

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->incomingMsg(msg);
}

void userIsTyping( int chat_id, int user_id )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->userIsTyping(chat_id, user_id);
}

void userStatusChanged( peer_t *uc )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->userStatusChanged(uc->id.id, uc->user.status.online, convertDate(uc->user.status.when) );
}

void photoFound( int id, long long volume )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->photoFound(id, volume );
}

void fileLoaded( struct download *d )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->fileLoaded(d->volume, d->local_id, d->name );
}
void fileUploading( struct send_file *f, long long total, long long uploaded )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->fileUploading( f->to_id.id, f->file_name, total, uploaded );
}

void fileDownloading( struct download *d, long long total, long long downloaded )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->fileDownloading( d->volume, total, downloaded );
}

void registeringStarted()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->registeringStarted();
}

void registeringFinished()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->registeringFinished();
}

void registeringInvalidCode()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->registeringInvalidCode();
}

QPair<int,void*> wait_and_get_unit;
QMutex wait_and_get_muttex;
QWaitCondition wait_and_get_wcond;
QPair<int,QVariant> wait_and_get_callback_result;

int waitAndGet( int type, void *pointer )
{
    wait_and_get_callback_result.first = type;

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->waitAndGet( type );

    wait_and_get_muttex.lock();
    wait_and_get_wcond.wait(&wait_and_get_muttex);
    wait_and_get_muttex.unlock();

    QVariant var = wait_and_get_callback_result.second;
    switch( type )
    {
    case WAIT_AND_GET_AUTH_CODE:
    {
        WaitGetAuthCode v = var.value<WaitGetAuthCode>();
        wait_get_auth_code *rv = static_cast<wait_get_auth_code*>(pointer);
        strcpy2( rv->code, v.code.toUtf8() );
        rv->request_phone = v.request_phone;
    }
        break;

    case WAIT_AND_GET_PHONE_NUMBER:
    {
        WaitGetPhone v = var.value<WaitGetPhone>();
        wait_get_phone *rv = static_cast<wait_get_phone*>(pointer);
        strcpy2( rv->phone, v.phone.toUtf8() );
    }
        break;

    case WAIT_AND_GET_USER_DETAILS:
    {
        WaitGetUserDetails v = var.value<WaitGetUserDetails>();
        wait_get_user_details *rv = static_cast<wait_get_user_details*>(pointer);
        strcpy2( rv->firstname ,v.firstname.toUtf8() );
        strcpy2( rv->lastname ,v.lastname.toUtf8() );
    }
        break;
    }

    return 0;
}

void encryptedChatUpdated( struct secret_chat *e )
{
    switch (e->state) {
    case sc_none:
      break;
    case sc_waiting:
      break;
    case sc_request:
      break;
    case sc_ok:
      break;
    case sc_deleted:
      break;
    }
}

void waitAndGet_callback( int type, const QVariant & v )
{
    if( wait_and_get_callback_result.first != type )
        return;

    wait_and_get_callback_result.second = v;
    wait_and_get_wcond.wakeAll();
}

int qthreadExec()
{
    return static_cast<TelegramThread*>(QThread::currentThread())->callExec();
}

void qthreadExit(int code)
{
    static_cast<TelegramThread*>(QThread::currentThread())->exit(code);
}

void qthreadExitRequest(int code)
{
    qDebug() << __FUNCTION__ << code;
//    qthreadExit(code);
//    QCoreApplication::exit(code);
}
