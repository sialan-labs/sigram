#ifndef TELEGRAM_H
#define TELEGRAM_H

#include <QObject>
#include <QStringList>
#include <QDateTime>

#include "telegram/strcuts.h"

class TelegramPrivate;
class Telegram : public QObject
{
    Q_PROPERTY(bool started READ started NOTIFY startedChanged)
    Q_PROPERTY(int me READ me NOTIFY meChanged)
    Q_PROPERTY(int waitAndGet READ lastWaitAndGet NOTIFY waitAndGetChanged )
    Q_PROPERTY(bool authenticating READ authenticating NOTIFY authenticatingChanged)
    Q_OBJECT
public:
    Telegram(int argc, char **argv, QObject *parent = 0);
    ~Telegram();

    Q_INVOKABLE QList<int> contactListUsers() const;
    UserClass contact(int id ) const;
    Q_INVOKABLE bool contactContains(int id) const;
    Q_INVOKABLE QString contactFirstName(int id) const;
    Q_INVOKABLE QString contactLastName(int id) const;
    Q_INVOKABLE QString contactPhone(int id) const;
    Q_INVOKABLE int contactUid(int id) const;
    Q_INVOKABLE int contactState(int id) const;
    Q_INVOKABLE QDateTime contactLastTime(int id) const;
    Q_INVOKABLE QString contactTitle(int id) const;
    Q_INVOKABLE QString contactLastSeenText(int id) const;

    Q_INVOKABLE QList<int> dialogListIds();
    DialogClass dialog( int id ) const;
    Q_INVOKABLE bool dialogIsChat( int id ) const;
    Q_INVOKABLE QString dialogChatTitle( int id ) const;
    Q_INVOKABLE int dialogChatAdmin( int id ) const;
    Q_INVOKABLE qint64 dialogChatPhotoId( int id ) const;
    Q_INVOKABLE int dialogChatUsersNumber( int id ) const;
    Q_INVOKABLE QList<int> dialogChatUsers( int id ) const;
    Q_INVOKABLE int dialogChatUsersInviter(int chat_id, int id ) const;
    Q_INVOKABLE QDateTime dialogChatDate( int id ) const;
    Q_INVOKABLE QString dialogUserName( int id ) const;
    Q_INVOKABLE QString dialogUserFirstName(int id) const;
    Q_INVOKABLE QString dialogUserLastName(int id) const;
    Q_INVOKABLE QString dialogUserPhone(int id) const;
    Q_INVOKABLE int dialogUserUid(int id) const;
    Q_INVOKABLE int dialogUserState(int id) const;
    Q_INVOKABLE QDateTime dialogUserLastTime(int id) const;
    Q_INVOKABLE QString dialogUserTitle(int id) const;
    Q_INVOKABLE QString dialogTitle( int id ) const;
    Q_INVOKABLE int dialogUnreadCount( int id ) const;
    Q_INVOKABLE QDateTime dialogMsgDate( int id ) const;
    Q_INVOKABLE QString dialogMsgLast( int id ) const;
    Q_INVOKABLE bool isDialog( int id ) const;

    Q_INVOKABLE QString title( int id ) const;

    Q_INVOKABLE QString getPhotoPath( int id ) const;

    Q_INVOKABLE QList<qint64> messageIds() const;
    Q_INVOKABLE QStringList messagesOf( int dialog_id ) const;
    Q_INVOKABLE QStringList messageIdsStringList() const;
    MessageClass message( qint64 id ) const;
    Q_INVOKABLE int messageForwardId( qint64 id ) const;
    Q_INVOKABLE QDateTime messageForwardDate( qint64 id ) const;
    Q_INVOKABLE bool messageOut( qint64 id ) const;
    Q_INVOKABLE int messageUnread( qint64 id ) const;
    Q_INVOKABLE QDateTime messageDate( qint64 id ) const;
    Q_INVOKABLE int messageService( qint64 id ) const;
    Q_INVOKABLE QString messageBody( qint64 id ) const;
    Q_INVOKABLE qreal messageBodyTextWidth( qint64 id ) const;
    Q_INVOKABLE int messageFromId( qint64 id ) const;
    Q_INVOKABLE int messageToId( qint64 id ) const;
    Q_INVOKABLE QString messageFromName( qint64 id ) const;
    Q_INVOKABLE qint64 messageMediaType( qint64 id ) const;
    Q_INVOKABLE bool messageIsPhoto( qint64 id ) const;
    Q_INVOKABLE QString messageMediaFile( qint64 id ) const;
    Q_INVOKABLE bool messageIsDeleted( qint64 id ) const;

    Q_INVOKABLE int me() const;
    Q_INVOKABLE bool started() const;

    Q_INVOKABLE QString convertDateToString( const QDateTime & date ) const;

    Q_INVOKABLE int lastWaitAndGet() const;
    Q_INVOKABLE bool authenticating() const;

public slots:
    void updateContactList();
    void updateDialogList();
    void updateDialogListUsingTimer();
    void updateContactListUsingTimer();

    void getHistory( int id, int count );

    void sendMessage( int id, const QString & msg );
    void forwardMessage( qint64 msg_id, int user_id );
    void deleteMessage( qint64 msg_id );
    void restoreMessage( qint64 msg_id );

    void loadUserInfo( int userId );
    void loadChatInfo( int chatId );

    void loadPhoto( qint64 msg_id );

    void sendFile( int dId, const QString & file );
    bool sendFileDialog( int dId );
    void markRead( int dId );

    void setStatusOnline( bool stt );

    void createChat( const QString & title, int user_id );
    void createSecretChat( int user_id );
    void renameChat( int chat_id, const QString & new_title );
    void chatAddUser( int chat_id, int user_id );
    void chatDelUser( int chat_id, int user_id );

    void search( int user_id, const QString & keyword );
    void globalSearch( const QString & keyword );

    void waitAndGetCallback( Enums::WaitAndGet type, const QVariant & var );
    void waitAndGetPhoneCallBack( const QString & phone );
    void waitAndGetAuthCodeCallBack(const QString & code, bool call_request );
    void waitAndGetUserInfoCallBack(const QString & fname, const QString & lname );

signals:
    void contactsChanged();
    void dialogsChanged();
    void meChanged();
    void incomingMsg( qint64 msg_id );
    void incomingNewMsg( qint64 msg_id );
    void userIsTyping( int chat_id, int user_id );
    void userStatusChanged( int user_id, int status, const QDateTime & when );
    void msgChanged( qint64 msg_id );
    void userPhotoChanged( int user_id );
    void chatPhotoChanged( int user_id );
    void msgSent( qint64 old_id, qint64 msg_id );

    void fileUploaded( int user_id, const QString & file );
    void fileUploading(int user_id, const QString & file, qreal percent );
    void fileUserUploaded( int user_id );
    void fileUserUploading( int user_id, qreal percent );

    void msgFileDownloaded( qint64 msg_id );
    void msgFileDownloading( qint64 msg_id, qreal percent );

    void messageDeleted( qint64 msg_id );
    void messageRestored( qint64 msg_id );

    void authenticatingChanged();
    void registeringInvalidCode();

    void waitAndGetChanged();

    void startedChanged();

private slots:
    void _waitAndGet( int type );
    void _startedChanged();
    void registeringStarted();
    void registeringFinished();

protected:
    void timerEvent(QTimerEvent *e);

private:
    TelegramPrivate *p;
};

#endif // TELEGRAM_H
