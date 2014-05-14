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

    connect( p->tg_thread, SIGNAL(contactsChanged()), SIGNAL(contactsChanged()) );
    connect( p->tg_thread, SIGNAL(dialogsChanged()) , SIGNAL(dialogsChanged())  );
    connect( p->tg_thread, SIGNAL(tgStarted())      , SIGNAL(started())         );

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

qint64 Telegram::contactUid(int id) const
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

QString Telegram::dialogUserName(int id) const
{
    return dialog(id).userClass.username;
}

QString Telegram::dialogTitle(int id) const
{
    return dialogIsChat(id)? dialogChatTitle(id) : dialogUserName(id);
}

void Telegram::updateContactList()
{
    p->tg_thread->contactList();
}

void Telegram::updateDialogList()
{
    p->tg_thread->dialogList();
}

void Telegram::getHistory(const QString &user, int count)
{
    p->tg_thread->getHistory(user,count);
}

Telegram::~Telegram()
{
    delete p;
}
