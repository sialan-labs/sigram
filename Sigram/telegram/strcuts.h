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

#ifndef STRCUTS_H
#define STRCUTS_H

#include <QtGlobal>
#include <QString>
#include <QStringList>
#include <QDateTime>

#include "telegram_cli/structers-only.h"
#include "telegram_cli/constants.h"

class Enums : public QObject
{
    Q_ENUMS(DesktopSession)
    Q_ENUMS(OnlineState)
    Q_ENUMS(UserFlags)
    Q_ENUMS(MessageType)
    Q_ENUMS(WaitAndGet)
    Q_ENUMS(SecretChatState)
    Q_ENUMS(MessageAction)
    Q_OBJECT

public:
    Enums(QObject *parent = 0);

    enum DesktopSession {
        Unknown,
        Gnome,
        GnomeFallBack,
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
        UserMessageEmpty = FLAG_MESSAGE_EMPTY,
        UserDeleted = FLAG_DELETED,
        UserForbidden = FLAG_FORBIDDEN,
        UserHasPhoto = FLAG_HAS_PHOTO,
        UserCreated = FLAG_CREATED,

        UserUserSelf = FLAG_USER_SELF,
        UserUserForeign = FLAG_USER_FOREIGN,
        UserUserContact = FLAG_USER_CONTACT,
        UserUserInContact = FLAG_USER_IN_CONTACT,
        UserUserOutContact = FLAG_USER_OUT_CONTACT,

        UserChatInChat = FLAG_CHAT_IN_CHAT,

        UserEncrypted = FLAG_ENCRYPTED,
        UserPending = FLAG_PENDING
    };

    enum MessageType {
        MediaEmpty = CODE_message_media_empty,
        MediaPhoto = CODE_message_media_photo,
        MediaVideo = CODE_message_media_video,
        MediaGeo = CODE_message_media_geo,
        MediaContact = CODE_message_media_contact,
        MediaUnsupported = CODE_message_media_unsupported
    };

    enum WaitAndGet {
        PhoneNumber = 0,
        AuthCode = 1,
        UserDetails = 2,
        CheckingState = 3,
        NoWaitAndGet = 4
    };

    enum SecretChatState {
      SecretChatNone,
      SecretChatWaiting,
      SecretChatRequest,
      SecretChatOk,
      SecretChatDeleted
    };

    enum MessageAction {
        MessageActionEmpty = CODE_message_action_empty,
        MessageActionChatCreate = CODE_message_action_chat_create,
        MessageActionChatEditTitle = CODE_message_action_chat_edit_title,
        MessageActionChatEditPhoto = CODE_message_action_chat_edit_photo,
        MessageActionChatDeletePhoto = CODE_message_action_chat_delete_photo,
        MessageActionChatAddUser = CODE_message_action_chat_add_user,
        MessageActionChatDeleteUser = CODE_message_action_chat_delete_user,
        MessageActionGeoChatCreate = CODE_message_action_geo_chat_create,
        MessageActionGeoChatCheckin = CODE_message_action_geo_chat_checkin,
    };
};

class WaitGetPhone
{
public:
    QString phone;
};

class WaitGetUserDetails
{
public:
    QString firstname;
    QString lastname;
};

class WaitGetAuthCode
{
public:
    QString code;
    bool request_phone;
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
        action = Enums::MessageActionEmpty;
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
    Enums::MessageType mediaType;
    MessageMedia media;

    Enums::MessageAction action;
    QString actionNewTitle;
    int actionUser;
};

Q_DECLARE_METATYPE( UserClass )
Q_DECLARE_METATYPE( ChatClass )
Q_DECLARE_METATYPE( DialogClass )
Q_DECLARE_METATYPE( MessageClass )
Q_DECLARE_METATYPE( WaitGetPhone )
Q_DECLARE_METATYPE( WaitGetAuthCode )
Q_DECLARE_METATYPE( WaitGetUserDetails )

#endif // STRCUTS_H
