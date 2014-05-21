#include "telegramcore.h"
#include "telegramthread.h"
#include "telegramcore_p.h"
#include "strcuts.h"
#include "limits"

extern "C" {
#include "telegram_cli/tmain.h"
}

#include <QCoreApplication>
#include <QSet>
#include <QDateTime>

struct chat_user {
  int user_id;
  int inviter_id;
  int date;
};

QSet<TelegramCore*> telegram_objects;

class TelegramCorePrivare
{
public:
    int argc;
    char **argv;
};

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

void TelegramCore::loadUserPhoto(const QString &user)
{
    send_command( QString("load_user_photo %1").arg(QString(user).replace(" ","_")) );
    send_command( QString("user_info %1").arg(QString(user).replace(" ","_")) );
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

void qdebug( const char *m )
{
    qDebug() << m;
}

void contactList_clear()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->contactListClear();
}

void contactList_addToBuffer( int user_id, int type, const char *firstname, const char *lastname, long long photo_id, const char *username, const char *phone, int state, int last_time )
{
    if( state > 0 )
        state = 1;
    else
    if( state < 0 )
        state = -1;

    UserClass contact;
    contact.username = username;
    contact.type = type;
    contact.user_id = user_id;
    contact.firstname = firstname;
    contact.lastname = lastname;
    contact.photo_id = photo_id;
    contact.phone = phone;
    contact.state = static_cast<TgStruncts::OnlineState>(state);
    contact.lastTime = convertDate(last_time);

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

void dialogList_addToBuffer_user( int user_id, int type, const char *firstname, const char *lastname, const char *username, const char *phone, int state, int last_time, int unread_cnt, int msg_date, const char * last_msg )
{
    if( state > 0 )
        state = 1;
    else
    if( state < 0 )
        state = -1;

    UserClass user;
    user.username = username;
    user.user_id = user_id;
    user.type = type;
    user.firstname = firstname;
    user.lastname = lastname;
//    user.photo_id = photo_id;
    user.phone = phone;
    user.state = static_cast<TgStruncts::OnlineState>(state);
    user.lastTime = convertDate(last_time);

    DialogClass dialog;
    dialog.is_chat = false;
    dialog.userClass = user;
    dialog.unread = unread_cnt;
    dialog.msgLast = last_msg;
    dialog.msgDate = convertDate(msg_date);

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogFounded(dialog);
}

void dialogList_addToBuffer_chat( int chat_id, int type, const char *title, int admin, long long photo_id, void *user_list_void, int user_list_size, int users_num, int date, int unread_cnt, int msg_date, const char * last_msg )
{
    chat_user *user_list = static_cast<chat_user*>(user_list_void);

    ChatClass chat;
    chat.admin = admin;
    chat.chat_id = chat_id;
    chat.title = title;
    chat.type = type;
    chat.photo_id = photo_id;
    chat.users_num = users_num;
    chat.date = convertDate(date);

    for( int i=0; i<user_list_size; i++ )
    {
        ChatUserClass user;
        user.user_id = user_list[i].user_id;
        user.inviter_id = user_list[i].inviter_id;
        user.date = convertDate(user_list[i].date);

        chat.users << user;
    }

    DialogClass dialog;
    dialog.is_chat = true;
    dialog.chatClass = chat;
    dialog.unread = unread_cnt;
    dialog.msgDate = convertDate(msg_date);

    if( unread_cnt != 0 )
        dialog.msgLast = last_msg;
    if( qAbs(dialog.msgDate.daysTo(QDateTime::currentDateTime())) > 32 )
        dialog.msgDate = chat.date;

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogFounded(dialog);
}

void dialogList_finished()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogListFinished();
}

void userInfosLoaded( int user_id, int type, const char *real_firstname, const char *real_lastname, const char *phone, long long photo_volume, long long photo_localid, int state, int last_time )
{
    UserExtraClass extra;
    extra.user_id = user_id;
    extra.type = type;
    extra.real_firstname = real_firstname;
    extra.real_lastname = real_lastname;
    extra.phone = phone;
    extra.photo_volume = photo_volume;
    extra.photo_localid = photo_localid;
    extra.state = static_cast<TgStruncts::OnlineState>(state);
    extra.lastTime = convertDate(last_time);

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->userInfoUpdated(extra);
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

void incomingMsg( long long msg_id, int from_id, int to_id, int fwd_id, int fwd_date, int out, int unread, int date, int service, const char *message)
{
    MessageClass msg;
    msg.msg_id = msg_id;
    msg.fwd_id = fwd_id;
    msg.fwd_date = convertDate(fwd_date);
    msg.out = out;
    msg.unread = unread;
    msg.date = convertDate(date);
    msg.service = service;
    msg.message = QString(message);
    msg.from_id = from_id;
    msg.to_id = to_id;

    if( msg.out && msg.unread )
        msg.msg_id = getUnknownIdentifier();

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->incomingMsg(msg);
}

void userIsTyping( int chat_id, int user_id )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->userIsTyping(chat_id, user_id);
}

void userStatusChanged( int user_id, int status, int when )
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->userStatusChanged(user_id, status, convertDate(when) );
}

void fileLoaded( long long volume, int localId, const char *path )
{
    qDebug() << volume << localId << path;
}

void qthreadExec()
{
    static_cast<TelegramThread*>(QThread::currentThread())->callExec();
}

void qthreadExit(int code)
{
    static_cast<TelegramThread*>(QThread::currentThread())->exit(code);
}
