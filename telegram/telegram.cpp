#include "telegram.h"
#include "telegramthread.h"
#include "strcuts.h"

#include <QMap>

class TelegramPrivate
{
public:
    TelegramThread *tg_thread;
};

Telegram::Telegram(int argc, char **argv, QObject *parent) :
    QObject(parent)
{
    p = new TelegramPrivate;
    p->tg_thread = new TelegramThread(argc,argv);

    connect( p->tg_thread, SIGNAL(contactsChanged())  , SIGNAL(contactsChanged())   );
    connect( p->tg_thread, SIGNAL(dialogsChanged())   , SIGNAL(dialogsChanged())    );
    connect( p->tg_thread, SIGNAL(incomingMsg(qint64)), SIGNAL(incomingMsg(qint64)) );
    connect( p->tg_thread, SIGNAL(tgStarted())        , SIGNAL(started())           );

    p->tg_thread->start();
}

QList<int> Telegram::contactListUsers() const
{
    return p->tg_thread->contacts().keys();
}

UserClass Telegram::contact(int id) const
{
    return p->tg_thread->contacts().value(id);
}

QString Telegram::contactFirstName(int id) const
{
    return contact(id).firstname;
}

QString Telegram::contactLastName(int id) const
{
    return contact(id).lastname;
}

QString Telegram::contactPhone(int id) const
{
    return contact(id).phone;
}

int Telegram::contactUid(int id) const
{
    return contact(id).user_id;
}

qint64 Telegram::contactPhotoId(int id) const
{
    return contact(id).photo_id;
}

TgStruncts::OnlineState Telegram::contactState(int id) const
{
    return contact(id).state;
}

QDateTime Telegram::contactLastTime(int id) const
{
    return contact(id).lastTime;
}

QString Telegram::contactTitle(int id)
{
    return contactFirstName(id) + " " + contactLastName(id);
}

QList<int> Telegram::dialogListIds() const
{
    return p->tg_thread->dialogs().keys();
}

DialogClass Telegram::dialog(int id) const
{
    return p->tg_thread->dialogs().value(id);
}

bool Telegram::dialogIsChat(int id) const
{
    return dialog(id).is_chat;
}

QString Telegram::dialogChatTitle(int id) const
{
    return dialog(id).chatClass.title;
}

int Telegram::dialogChatAdmin(int id) const
{
    return dialog(id).chatClass.admin;
}

qint64 Telegram::dialogChatPhotoId(int id) const
{
    return dialog(id).chatClass.photo_id;
}

int Telegram::dialogChatUsersNumber(int id) const
{
    return dialog(id).chatClass.users_num;
}

QDateTime Telegram::dialogChatDate(int id) const
{
    return dialog(id).chatClass.date;
}

QString Telegram::dialogUserName(int id) const
{
    return dialog(id).userClass.username;
}

QString Telegram::dialogUserFirstName(int id) const
{
    return dialog(id).userClass.firstname;
}

QString Telegram::dialogUserLastName(int id) const
{
    return dialog(id).userClass.lastname;
}

QString Telegram::dialogUserPhone(int id) const
{
    return dialog(id).userClass.phone;
}

int Telegram::dialogUserUid(int id) const
{
    return dialog(id).userClass.user_id;
}

qint64 Telegram::dialogUserPhotoId(int id) const
{
    return dialog(id).userClass.photo_id;
}

TgStruncts::OnlineState Telegram::dialogUserState(int id) const
{
    return dialog(id).userClass.state;
}

QDateTime Telegram::dialogUserLastTime(int id) const
{
    return dialog(id).userClass.lastTime;
}

QString Telegram::dialogUserTitle(int id)
{
    return dialogUserFirstName(id) + " " + dialogUserLastName(id);
}

QString Telegram::dialogTitle(int id) const
{
    return dialogIsChat(id)? dialogChatTitle(id) : dialogUserName(id);
}

QList<qint64> Telegram::messageIds() const
{
    return p->tg_thread->messages().keys();
}

QStringList Telegram::messageIdsStringList() const
{
    const QList<qint64> & msgs = messageIds();
    QStringList result;
    foreach( qint64 id, msgs )
        result << QString::number(id);

    return result;
}

MessageClass Telegram::message(qint64 id) const
{
    return p->tg_thread->messages().value(id);
}

int Telegram::messageForwardId(qint64 id) const
{
    return message(id).fwd_id;
}

QDateTime Telegram::messageForwardDate(qint64 id) const
{
    return message(id).fwd_date;
}

int Telegram::messageOut(qint64 id) const
{
    return message(id).out;
}

int Telegram::messageUnread(qint64 id) const
{
    return message(id).unread;
}

QDateTime Telegram::messageDate(qint64 id) const
{
    return message(id).date;
}

int Telegram::messageService(qint64 id) const
{
    return message(id).service;
}

QString Telegram::messageBody(qint64 id) const
{
    return message(id).message;
}

int Telegram::messageFromId(qint64 id) const
{
    return message(id).from_id;
}

int Telegram::messageToId(qint64 id) const
{
    return message(id).to_id;
}

void Telegram::updateContactList()
{
    p->tg_thread->contactList();
}

void Telegram::updateDialogList()
{
    p->tg_thread->dialogList();
}

void Telegram::getHistory(int id, int count)
{
    p->tg_thread->getHistory(id,count);
}

Telegram::~Telegram()
{
    delete p;
}
