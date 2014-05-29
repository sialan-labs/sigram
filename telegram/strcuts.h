#ifndef STRCUTS_H
#define STRCUTS_H

#include <QtGlobal>
#include <QString>
#include <QStringList>
#include <QDateTime>

class Enums : public QObject
{
    Q_ENUMS(DesktopSession)
    Q_ENUMS(OnlineState)
    Q_ENUMS(UserFlags)
    Q_ENUMS(messageType)
    Q_OBJECT

public:
    Enums(QObject *parent = 0);

    enum DesktopSession {
        Unknown,
        Gnome,
        Unity,
        Kde,
        Windows,
        Mac
    };

    enum OnlineState {
        Offline = -1,
        NotOnlineYet = 0,
        Online = 1
    };

    enum UserFlags {
        UserMessageEmpty = 1,
        UserDeleted = 2,
        UserForbidden = 4,
        UserHasPhoto = 8,
        UserCreated = 16,

        UserUserSelf = 128,
        UserUserForeign = 256,
        UserUserContact = 512,
        UserUserInContact = 1024,
        UserUserOutContact = 2048,

        UserChatInChat = 128,

        UserEncrypted = 4096,
        UserPending = 8192
    };

    enum messageType {
        MediaEmpty = 0x3ded6320,
        MediaPhoto = 0xc8c45a2a,
        MediaVideo = 0xa2d24290,
        MediaGeo = 0x56e0d474,
        MediaContact = 0x5e7d2f39,
        MediaUnsupported = 0x29632a36
    };
};

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
    Enums::OnlineState state;
    Enums::UserFlags flags;
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
    int flags;

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
    int flags;
    QDateTime msgDate;
    QString msgLast;
};

class MessageMedia
{
public:
    qint64 volume;
    qint64 secret;

    qreal latitude;
    qreal longitude;
};

class MessageClass
{
public:
    MessageClass() {
        deleted = false;
    }

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

    int flags;

    bool deleted;

    QString mediaFile;
    Enums::messageType mediaType;
    MessageMedia media;
};

Q_DECLARE_METATYPE( UserClass )
Q_DECLARE_METATYPE( ChatClass )
Q_DECLARE_METATYPE( DialogClass )
Q_DECLARE_METATYPE( MessageClass )

#endif // STRCUTS_H
