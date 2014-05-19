#ifndef STRCUTS_H
#define STRCUTS_H

#include <QtGlobal>
#include <QString>
#include <QStringList>
#include <QDateTime>

namespace TgStruncts
{
    enum OnlineState {
        Offline = -1,
        NotOnlineYet = 0,
        Online = 1
    };
}

class UserClass
{
public:
    QString username;

    int user_id;
    qint64 photo_id;

    QString firstname;
    QString lastname;

    QString phone;

    QDateTime lastTime;
    TgStruncts::OnlineState state;
};

class ChatUserClass
{
public:
    int user_id;
    int inviter_id;
    QDateTime date;
};

class ChatClass
{
public:
    int admin;

    int chat_id;
    qint64 photo_id;

    QString title;

    int users_num;

    QDateTime date;
    QList<ChatUserClass> users;
};

class DialogClass
{
public:
    ChatClass chatClass;
    UserClass userClass;

    bool is_chat;
    int unread;
    QDateTime msgDate;
    QString msgLast;
};

class MessageClass
{
public:
    qint64 msg_id;
    int fwd_id;
    QDateTime fwd_date;
    int out;
    int unread;
    QDateTime date;
    int service;
    QString message;

    QString fromName;

    int from_id;
    int to_id;
};

Q_DECLARE_METATYPE( UserClass )
Q_DECLARE_METATYPE( ChatClass )
Q_DECLARE_METATYPE( DialogClass )
Q_DECLARE_METATYPE( MessageClass )

#endif // STRCUTS_H
