#include "telegramcore.h"
#include "telegramthread.h"
#include "telegramcore_p.h"
#include "strcuts.h"

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
    send_command( QString("msg %1 %2").arg(user,msg) );
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

void tgStarted()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->started();
}

void callSignal()
{
    qDebug() << "Hi";
}

void contactList_clear()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->contactListClear();
}

void contactList_addToBuffer( int user_id, const char *firstname, const char *lastname, long long photo_id, const char *username, const char *phone, int state, int last_time )
{
    if( state > 0 )
        state = 1;
    else
    if( state < 0 )
        state = -1;

    UserClass contact;
    contact.username = username;
    contact.user_id = user_id;
    contact.firstname = firstname;
    contact.lastname = lastname;
    contact.photo_id = photo_id;
    contact.phone = phone;
    contact.state = static_cast<TgStruncts::OnlineState>(state);
    contact.lastTime = QDateTime::fromMSecsSinceEpoch(last_time);

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

void dialogList_addToBuffer_user( int user_id, const char *firstname, const char *lastname, long long photo_id, const char *username, const char *phone, int state, int last_time )
{
    if( state > 0 )
        state = 1;
    else
    if( state < 0 )
        state = -1;

    UserClass user;
    user.username = username;
    user.user_id = user_id;
    user.firstname = firstname;
    user.lastname = lastname;
    user.photo_id = photo_id;
    user.phone = phone;
    user.state = static_cast<TgStruncts::OnlineState>(state);
    user.lastTime = QDateTime::fromMSecsSinceEpoch(last_time);

    DialogClass dialog;
    dialog.is_chat = false;
    dialog.userClass = user;

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogFounded(dialog);
}

void dialogList_addToBuffer_chat( int chat_id, const char *title, int admin, long long photo_id, void *user_list_void, int user_list_size, int users_num, int date )
{
    chat_user *user_list = static_cast<chat_user*>(user_list_void);

    ChatClass chat;
    chat.admin = admin;
    chat.chat_id = chat_id;
    chat.title = title;
    chat.photo_id = photo_id;
    chat.users_num = users_num;
    chat.date = QDateTime::fromMSecsSinceEpoch(date);

    for( int i=0; i<user_list_size; i++ )
    {
        ChatUserClass user;
        user.user_id = user_list[i].user_id;
        user.inviter_id = user_list[i].inviter_id;
        user.date = QDateTime::fromMSecsSinceEpoch(user_list[i].date);

        chat.users << user;
    }

    DialogClass dialog;
    dialog.is_chat = true;
    dialog.chatClass = chat;

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogFounded(dialog);
}

void dialogList_finished()
{
    foreach( TelegramCore *tg, telegram_objects )
        emit tg->dialogListFinished();
}

void incomingMsg( long long msg_id, int from_id, int to_id, int fwd_id, int fwd_date, int out, int unread, int date, int service, const char *message)
{
    MessageClass msg;
    msg.msg_id = msg_id;
    msg.fwd_id = fwd_id;
    msg.fwd_date = QDateTime::fromMSecsSinceEpoch(fwd_date);
    msg.out = out;
    msg.unread = unread;
    msg.date = QDateTime::fromMSecsSinceEpoch(date);
    msg.service = service;
    msg.message = QString(message);
    msg.from_id = from_id;
    msg.to_id = to_id;

    foreach( TelegramCore *tg, telegram_objects )
        emit tg->incomingMsg(msg);
}

void qthreadExec()
{
    static_cast<TelegramThread*>(QThread::currentThread())->callExec();
}

void qthreadExit(int code)
{
    static_cast<TelegramThread*>(QThread::currentThread())->exit(code);
}
