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

    enum UserFlags {
        userMessageEmpty = 1,
        userDeleted = 2,
        userForbidden = 4,
        userHasPhoto = 8,
        userCreated = 16,

        userUserSelf = 128,
        userUserForeign = 256,
        userUserContact = 512,
        userUserInContact = 1024,
        userUserOutContact = 2048,

        userChatInChat = 128,

        userEncrypted = 4096,
        userPending = 8192
    };
}

class UserClass
{
public:
    QString username;

    int user_id;
    int type;

    QString firstname;
    QString lastname;

    qint64 photoId;

    QString phone;

    QDateTime lastTime;
    TgStruncts::OnlineState state;
    TgStruncts::UserFlags flags;
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
    int type;

    qint64 photoId;

    QString title;

    int users_num;

    QDateTime date;
    QList<ChatUserClass> users;
};

class DialogClass
{
public:
    DialogClass() {
        is_chat = false;
        unread = true;
    }

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

    QString firstName;
    QString lastName;

    int from_id;
    int to_id;
};

Q_DECLARE_METATYPE( UserClass )
Q_DECLARE_METATYPE( ChatClass )
Q_DECLARE_METATYPE( DialogClass )
Q_DECLARE_METATYPE( MessageClass )

#endif // STRCUTS_H
