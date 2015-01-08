/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef TELEGRAMQML_H
#define TELEGRAMQML_H

#include <QObject>
#include "types/inputfilelocation.h"

class Database;
class SecretChat;
class EncryptedFile;
class EncryptedFileObject;
class DecryptedMessage;
class DecryptedMessageObject;
class EncryptedChat;
class EncryptedChatObject;
class EncryptedMessage;
class EncryptedMessageObject;
class DocumentObject;
class VideoObject;
class AudioObject;
class WallPaper;
class WallPaperObject;
class UserData;
class StorageFileType;
class FileLocationObject;
class PhotoObject;
class ContactsLink;
class Update;
class Message;
class User;
class Contact;
class ContactObject;
class Chat;
class ChatFull;
class Dialog;
class Photo;
class UserProfilePhoto;
class DialogObject;
class MessageObject;
class InputPeerObject;
class ChatFullObject;
class ChatObject;
class UserObject;
class UploadObject;
class Telegram;
class TelegramQmlPrivate;
class TelegramQml : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString phoneNumber   READ phoneNumber   WRITE setPhoneNumber   NOTIFY phoneNumberChanged  )
    Q_PROPERTY(QString configPath    READ configPath    WRITE setConfigPath    NOTIFY configPathChanged   )
    Q_PROPERTY(QString publicKeyFile READ publicKeyFile WRITE setPublicKeyFile NOTIFY publicKeyFileChanged)
    Q_PROPERTY(QString downloadPath  READ downloadPath  NOTIFY downloadPathChanged )

    Q_PROPERTY(bool online READ online WRITE setOnline NOTIFY onlineChanged)
    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY unreadCountChanged)

    Q_PROPERTY(Telegram* telegram READ telegram NOTIFY telegramChanged)
    Q_PROPERTY(UserData* userData READ userData NOTIFY userDataChanged)
    Q_PROPERTY(qint64    me       READ me       NOTIFY meChanged)

    Q_PROPERTY(bool authNeeded          READ authNeeded          NOTIFY authNeededChanged         )
    Q_PROPERTY(bool authLoggedIn        READ authLoggedIn        NOTIFY authLoggedInChanged       )
    Q_PROPERTY(bool authPhoneRegistered READ authPhoneRegistered NOTIFY authPhoneRegisteredChanged)
    Q_PROPERTY(bool authPhoneInvited    READ authPhoneInvited    NOTIFY authPhoneInvitedChanged   )
    Q_PROPERTY(bool authPhoneChecked    READ authPhoneChecked    NOTIFY authPhoneCheckedChanged   )
    Q_PROPERTY(bool connected           READ connected           NOTIFY connectedChanged          )

    Q_PROPERTY(QString authSignUpError READ authSignUpError NOTIFY authSignUpErrorChanged)
    Q_PROPERTY(QString authSignInError READ authSignInError NOTIFY authSignInErrorChanged)
    Q_PROPERTY(QString error           READ error           NOTIFY errorChanged          )

    Q_PROPERTY(DialogObject* nullDialog READ nullDialog NOTIFY fakeSignal)
    Q_PROPERTY(MessageObject* nullMessage READ nullMessage NOTIFY fakeSignal)
    Q_PROPERTY(ChatObject* nullChat READ nullChat NOTIFY fakeSignal)
    Q_PROPERTY(UserObject* nullUser READ nullUser NOTIFY fakeSignal)
    Q_PROPERTY(WallPaperObject* nullWallpaper READ nullWallpaper NOTIFY fakeSignal)
    Q_PROPERTY(UploadObject* nullUpload READ nullUpload NOTIFY fakeSignal)
    Q_PROPERTY(ChatFullObject* nullChatFull READ nullChatFull NOTIFY fakeSignal)
    Q_PROPERTY(ContactObject* nullContact READ nullContact NOTIFY fakeSignal)
    Q_PROPERTY(FileLocationObject* nullLocation READ nullLocation NOTIFY fakeSignal)
    Q_PROPERTY(EncryptedChatObject* nullEncryptedChat READ nullEncryptedChat NOTIFY fakeSignal)
    Q_PROPERTY(EncryptedMessageObject* nullEncryptedMessage READ nullEncryptedMessage NOTIFY fakeSignal)

public:
    TelegramQml(QObject *parent = 0);
    ~TelegramQml();

    QString phoneNumber() const;
    void setPhoneNumber( const QString & phone );

    QString downloadPath() const;

    QString configPath() const;
    void setConfigPath( const QString & conf );

    QString publicKeyFile() const;
    void setPublicKeyFile( const QString & file );

    UserData *userData() const;
    Database *database() const;
    Telegram *telegram() const;
    qint64 me() const;

    bool online() const;
    void setOnline( bool stt );

    void setInvisible( bool stt );
    bool invisible() const;

    int unreadCount();

    bool authNeeded() const;
    bool authLoggedIn() const;
    bool authPhoneChecked() const;
    bool authPhoneRegistered() const;
    bool authPhoneInvited() const;
    bool connected() const;

    QString authSignUpError() const;
    QString authSignInError() const;
    QString error() const;

    Q_INVOKABLE DialogObject *dialog(qint64 id) const;
    Q_INVOKABLE MessageObject *message(qint64 id) const;
    Q_INVOKABLE ChatObject *chat(qint64 id) const;
    Q_INVOKABLE UserObject *user(qint64 id) const;
    Q_INVOKABLE qint64 messageDialogId(qint64 id) const;
    Q_INVOKABLE DialogObject *messageDialog(qint64 id) const;
    Q_INVOKABLE WallPaperObject *wallpaper(qint64 id) const;
    Q_INVOKABLE MessageObject *upload(qint64 id) const;
    Q_INVOKABLE ChatFullObject *chatFull(qint64 id) const;
    Q_INVOKABLE ContactObject *contact(qint64 id) const;
    Q_INVOKABLE EncryptedChatObject *encryptedChat(qint64 id) const;

    Q_INVOKABLE FileLocationObject *locationOf(qint64 id, qint64 dcId, qint64 accessHash);
    Q_INVOKABLE FileLocationObject *locationOfDocument(DocumentObject *doc);
    Q_INVOKABLE FileLocationObject *locationOfVideo(VideoObject *vid);
    Q_INVOKABLE FileLocationObject *locationOfAudio(AudioObject *aud);

    Q_INVOKABLE DialogObject *fakeDialogObject( qint64 id, bool isChat );

    DialogObject *nullDialog() const;
    MessageObject *nullMessage() const;
    ChatObject *nullChat() const;
    UserObject *nullUser() const;
    WallPaperObject *nullWallpaper() const;
    UploadObject *nullUpload() const;
    ChatFullObject *nullChatFull() const;
    ContactObject *nullContact() const;
    FileLocationObject *nullLocation() const;
    EncryptedChatObject *nullEncryptedChat() const;
    EncryptedMessageObject *nullEncryptedMessage() const;

    Q_INVOKABLE QString fileLocation( FileLocationObject *location );

    QList<qint64> dialogs() const;
    QList<qint64> messages(qint64 did) const;
    QList<qint64> wallpapers() const;
    QList<qint64> uploads() const;
    QList<qint64> contacts() const;

public slots:
    void authLogout();
    void authSendCall();
    void authSendInvites(const QStringList &phoneNumbers, const QString &inviteText);
    void authSignIn(const QString &code);
    void authSignUp(const QString &code, const QString &firstName, const QString &lastName);

    void sendMessage( qint64 dialogId, const QString & msg );
    void forwardMessage( qint64 msgId, qint64 peerId );
    void deleteMessage( qint64 msgId );

    void messagesCreateChat( const QList<qint32> & users, const QString & topic );

    void messagesCreateEncryptedChat(qint64 userId);
    void messagesAcceptEncryptedChat(qint32 chatId);
    void messagesDiscardEncryptedChat(qint32 chatId);

    void sendFile( qint64 dialogId, const QString & file );
    void getFile(FileLocationObject *location, qint64 type = InputFileLocation::typeInputFileLocation , qint32 fileSize = 0);
    void getFileJustCheck(FileLocationObject *location);
    void cancelSendGet( qint64 fileId );

    void setProfilePhoto( const QString & fileName );

    void timerUpdateDialogs( bool duration = 1000 );

signals:
    void phoneNumberChanged();
    void configPathChanged();
    void publicKeyFileChanged();
    void telegramChanged();
    void userDataChanged();
    void onlineChanged();
    void downloadPathChanged();
    void dialogsChanged(bool cachedData);
    void messagesChanged(bool cachedData);
    void wallpapersChanged();
    void uploadsChanged();
    void chatFullsChanged();
    void contactsChanged();
    void autoUpdateChanged();
    void encryptedChatsChanged();

    void unreadCountChanged();
    void invisibleChanged();

    void authNeededChanged();
    void authLoggedInChanged();
    void authPhoneRegisteredChanged();
    void authPhoneInvitedChanged();
    void authPhoneCheckedChanged();
    void connectedChanged();

    void authSignUpErrorChanged();
    void authSignInErrorChanged();

    void authCodeRequested( bool phoneRegistered, qint32 sendCallTimeout );
    void authCallRequested( bool ok );
    void authInvitesSent( bool ok );

    void errorChanged();
    void meChanged();
    void fakeSignal();

    void incomingMessage( MessageObject *msg );
    void incomingEncryptedMessage( EncryptedMessageObject *msg );

protected:
    void try_init();

private slots:
    void authNeeded_slt();
    void authLoggedIn_slt();
    void authLogOut_slt(qint64 id, bool ok);
    void authSendCode_slt(qint64 id, bool phoneRegistered, qint32 sendCallTimeout);
    void authSendCall_slt(qint64 id, bool ok);
    void authSendInvites_slt(qint64 id, bool ok);
    void authCheckPhone_slt(qint64 id, bool phoneRegistered, bool phoneInvited);
    void authSignInError_slt(qint64 id, qint32 errorCode, QString errorText);
    void authSignUpError_slt(qint64 id, qint32 errorCode, QString errorText);

    void accountGetWallPapers_slt(qint64 id, const QList<WallPaper> & wallPapers);
    void photosUploadProfilePhoto_slt(qint64 id, const Photo & photo, const QList<User> & users);
    void photosUpdateProfilePhoto_slt(qint64 id, const UserProfilePhoto & userProfilePhoto);

    void contactsGetContacts_slt(qint64 id, bool modified, const QList<Contact> & contacts, const QList<User> & users);

    void messagesSendMessage_slt(qint64 id, qint32 msgId, qint32 date, qint32 pts, qint32 seq, const QList<ContactsLink> & links);
    void messagesForwardMessage_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);
    void messagesDeleteMessages_slt(qint64 id, const QList<qint32> & deletedMsgIds);

    void messagesSendMedia_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);
    void messagesSendPhoto_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);
    void messagesSendVideo_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);
    void messagesSendAudio_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);
    void messagesSendDocument_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);
    void messagesGetDialogs_slt(qint64 id, qint32 sliceCount, const QList<Dialog> & dialogs, const QList<Message> & messages, const QList<Chat> & chats, const QList<User> & users);
    void messagesGetHistory_slt(qint64 id, qint32 sliceCount, const QList<Message> & messages, const QList<Chat> & chats, const QList<User> & users);

    void messagesGetFullChat_slt(qint64 id, const ChatFull & chatFull, const QList<Chat> & chats, const QList<User> & users);
    void messagesCreateChat_slt(qint64 id, const Message & message, const QList<Chat> & chats, const QList<User> & users, const QList<ContactsLink> & links, qint32 pts, qint32 seq);

    void messagesCreateEncryptedChat_slt(qint64 id, qint32 chatId, qint64 accessHash, qint32 date, qint32 adminId, qint32 participantId);
    void messagesEncryptedChatRequested_slt(qint32 chatId, qint32 date, qint32 creatorId, qint64 creatorAccessHash);
    void messagesEncryptedChatCreated_slt(qint32 chatId);
    void messagesEncryptedChatDiscarded_slt(qint32 chatId);
    void messagesSendEncrypted_slt(qint64 id, qint32 date, const EncryptedFile &encryptedFile);

    void error(qint64 id, qint32 errorCode, QString errorText);

    void updatesTooLong_slt();
    void updateShortMessage_slt(qint32 id, qint32 fromId, QString message, qint32 pts, qint32 date, qint32 seq);
    void updateShortChatMessage_slt(qint32 id, qint32 fromId, qint32 chatId, QString message, qint32 pts, qint32 date, qint32 seq);
    void updateShort_slt(const Update & update, qint32 date);
    void updatesCombined_slt(const QList<Update> & updates, const QList<User> & users, const QList<Chat> & chats, qint32 date, qint32 seqStart, qint32 seq);
    void updates_slt(const QList<Update> & udts, const QList<User> & users, const QList<Chat> & chats, qint32 date, qint32 seq);
    void updateDecryptedMessage_slt(qint32 chatId, const DecryptedMessage &message, qint32 date, qint32 qts, const EncryptedFile &attachment);

    void uploadGetFile_slt(qint64 id, const StorageFileType & type, qint32 mtime, const QByteArray & bytes, qint32 partId, qint32 downloaded, qint32 total);
    void uploadSendFile_slt(qint64 fileId, qint32 partId, qint32 uploaded, qint32 totalSize);
    void uploadCancelFile_slt(qint64 fileId, bool cancelled);

private:
    void insertDialog(const Dialog & dialog , bool encrypted = false, bool fromDb = false);
    void insertMessage(const Message & message , bool encrypted = false, bool fromDb = false, bool tempMsg = false);
    void insertUser( const User & user, bool fromDb = false );
    void insertChat( const Chat & chat, bool fromDb = false );
    void insertUpdate( const Update & update );
    void insertContact( const Contact & contact );
    void insertEncryptedMessage(const EncryptedMessage & emsg);
    void insertEncryptedChat(const EncryptedChat & c);

protected:
    void timerEvent(QTimerEvent *e);
    Message newMessage(qint64 dId);
    SecretChat *getSecretChat(qint64 chatId);

    void startGarbageChecker();

private slots:
    void dbUserFounded(const User &user);
    void dbChatFounded(const Chat &chat);
    void dbDialogFounded(const Dialog &dialog);
    void dbMessageFounded(const Message &message);

    void refreshUnreadCount();
    void refreshSecretChats();

    qint64 generateRandomId() const;

private:
    TelegramQmlPrivate *p;
};

Q_DECLARE_METATYPE(TelegramQml*)

#endif // TELEGRAMQML_H
