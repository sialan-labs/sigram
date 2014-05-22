#include "telegram.h"
#include "telegramthread.h"
#include "strcuts.h"

#include <QMap>
#include <QTimerEvent>
#include <QFontMetricsF>
#include <QCoreApplication>
#include <QDebug>

class TelegramPrivate
{
public:
    TelegramThread *tg_thread;

    int update_dialog_timer_id;
    bool update_dialog_again;

    QSet<int> loaded_users_info;
    QSet<int> loaded_chats_info;
};

Telegram *sortDialogList_tmp_obj = 0;
bool sortDialogList(int m1, int m2)
{
    return sortDialogList_tmp_obj->dialogMsgDate(m1) > sortDialogList_tmp_obj->dialogMsgDate(m2);
}

Telegram::Telegram(int argc, char **argv, QObject *parent) :
    QObject(parent)
{
    p = new TelegramPrivate;
    p->update_dialog_again = false;
    p->update_dialog_timer_id = 0;

    p->tg_thread = new TelegramThread(argc,argv);

    connect( p->tg_thread, SIGNAL(contactsChanged())                   , SIGNAL(contactsChanged())                    );
    connect( p->tg_thread, SIGNAL(dialogsChanged())                    , SIGNAL(dialogsChanged())                     );
    connect( p->tg_thread, SIGNAL(incomingMsg(qint64))                 , SIGNAL(incomingMsg(qint64))                  );
    connect( p->tg_thread, SIGNAL(incomingNewMsg(qint64))              , SIGNAL(incomingNewMsg(qint64))               );
    connect( p->tg_thread, SIGNAL(userIsTyping(int,int))               , SIGNAL(userIsTyping(int,int))                );
    connect( p->tg_thread, SIGNAL(userStatusChanged(int,int,QDateTime)), SIGNAL(userStatusChanged(int,int,QDateTime)) );
    connect( p->tg_thread, SIGNAL(msgChanged(qint64))                  , SIGNAL(msgChanged(qint64))                   );
    connect( p->tg_thread, SIGNAL(msgSent(qint64,qint64))              , SIGNAL(msgSent(qint64,qint64))               );
    connect( p->tg_thread, SIGNAL(userPhotoChanged(int))               , SIGNAL(userPhotoChanged(int))                );
    connect( p->tg_thread, SIGNAL(chatPhotoChanged(int))               , SIGNAL(chatPhotoChanged(int))                );
    connect( p->tg_thread, SIGNAL(tgStarted())                         , SIGNAL(started())                            );

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

int Telegram::contactState(int id) const
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

QList<int> Telegram::dialogListIds()
{
    QList<int> res = p->tg_thread->dialogs().keys();

    sortDialogList_tmp_obj = this;
    qSort( res.begin(), res.end(), sortDialogList );

    return res;
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
    return dialog(id).chatClass.photoId;
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

int Telegram::dialogUserState(int id) const
{
    return dialog(id).userClass.state;
}

QDateTime Telegram::dialogUserLastTime(int id) const
{
    return dialog(id).userClass.lastTime;
}

QString Telegram::dialogUserTitle(int id) const
{
    return dialogUserFirstName(id) + " " + dialogUserLastName(id);
}

QString Telegram::dialogTitle(int id) const
{
    return dialogIsChat(id)? dialogChatTitle(id) : dialogUserFirstName(id) + " " + dialogUserLastName(id);
}

int Telegram::dialogUnreadCount(int id) const
{
    return dialog(id).unread;
}

QDateTime Telegram::dialogMsgDate(int id) const
{
    return dialog(id).msgDate;
}

QString Telegram::dialogMsgLast(int id) const
{
    return dialog(id).msgLast;
}

QString Telegram::getPhotoPath(int id) const
{
    return p->tg_thread->photos().value(id);
}

QList<qint64> Telegram::messageIds() const
{
    return p->tg_thread->messages().keys();
}

QStringList Telegram::messagesOf(int current) const
{
    QMap<qint64,QString> res;
    bool is_chat = dialogIsChat(current);

    const QHash<qint64,MessageClass> & msgs = p->tg_thread->messages();
    QHashIterator<qint64,MessageClass> i(msgs);
    while( i.hasNext() )
    {
        i.next();
        const MessageClass & msg = i.value();
        if( is_chat && msg.to_id != current && msg.to_id != 0 )
            continue;
        else
        if( !is_chat )
        {
            if( msg.out && msg.to_id != current && msg.to_id != 0 )
                continue;
            else
            if( !msg.out && msg.from_id != current && msg.from_id != 0 )
                continue;
            else
            if( dialogIsChat(msg.to_id) || dialogIsChat(msg.from_id) )
                continue;
        }

        res.insert( msg.date.toMSecsSinceEpoch(), QString::number(msg.msg_id) );
    }

    return res.values();
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

bool Telegram::messageOut(qint64 id) const
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

qreal Telegram::messageBodyTextWidth(qint64 id) const
{
    const QString & txt = messageBody(id);
    QFontMetricsF metric = QFontMetricsF( QFont() );
    return metric.width(txt);
}

int Telegram::messageFromId(qint64 id) const
{
    return message(id).from_id;
}

int Telegram::messageToId(qint64 id) const
{
    return message(id).to_id;
}

QString Telegram::messageFromName(qint64 id) const
{
    const MessageClass & msg = message(id);
    return msg.firstName + " " + msg.lastName;
}

QString Telegram::convertDateToString(const QDateTime &date)
{
    const QDateTime & today = QDateTime::currentDateTime();
    if( date.date().year() != today.date().year() )
        return date.date().toString("yyyy MMM d");
    else
    if( date.date().month() != today.date().month() )
        return date.date().toString("MMM d");
    else
    if( date.date().day() != today.date().day() )
        return date.date().toString("MMM d");
    else
        return tr("Today") + " " + date.time().toString("hh:mm");
}

void Telegram::updateContactList()
{
    p->tg_thread->contactList();
}

void Telegram::updateDialogList()
{
    p->tg_thread->dialogList();
}

void Telegram::updateDialogListUsingTimer()
{
    if( p->update_dialog_timer_id )
    {
        p->update_dialog_again = true;
        return;
    }

    p->update_dialog_again = false;
    p->update_dialog_timer_id = startTimer(1000);
}

void Telegram::getHistory(int id, int count)
{
    p->tg_thread->getHistory(id,count);
}

void Telegram::sendMessage(int id, const QString &msg)
{
    p->tg_thread->sendMessage(id,msg);
}

void Telegram::loadUserInfo(int userId)
{
    if( p->loaded_users_info.contains(userId) )
        return;

    p->tg_thread->loadUserInfo(userId);
    p->loaded_users_info.insert(userId);
}

void Telegram::loadChatInfo(int chatId)
{
    if( p->loaded_chats_info.contains(chatId) )
        return;

    p->tg_thread->loadChatInfo(chatId);
    p->loaded_chats_info.insert(chatId);
}

void Telegram::markRead(int dId)
{
    p->tg_thread->markRead(dId);
}

void Telegram::setStatusOnline(bool stt)
{
    p->tg_thread->setStatusOnline(stt);
}

void Telegram::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->update_dialog_timer_id )
    {
        updateDialogList();
        if( p->update_dialog_again )
        {
            p->update_dialog_again = false;
            return;
        }

        p->update_dialog_again = false;
        killTimer(p->update_dialog_timer_id);
        p->update_dialog_timer_id = 0;
    }
    else
        QObject::timerEvent(e);
}

Telegram::~Telegram()
{
    delete p;
}
