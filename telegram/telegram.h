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
    Q_OBJECT
public:
    Telegram(int argc, char **argv, QObject *parent = 0);
    ~Telegram();

    Q_INVOKABLE QList<int> contactListUsers() const;
    UserClass contact(int id ) const;
    Q_INVOKABLE QString contactFirstName(int id) const;
    Q_INVOKABLE QString contactLastName(int id) const;
    Q_INVOKABLE QString contactPhone(int id) const;
    Q_INVOKABLE int contactUid(int id) const;
    Q_INVOKABLE int contactState(int id) const;
    Q_INVOKABLE QDateTime contactLastTime(int id) const;
    Q_INVOKABLE QString contactTitle(int id);

    Q_INVOKABLE QList<int> dialogListIds();
    DialogClass dialog( int id ) const;
    Q_INVOKABLE bool dialogIsChat( int id ) const;
    Q_INVOKABLE QString dialogChatTitle( int id ) const;
    Q_INVOKABLE int dialogChatAdmin( int id ) const;
    Q_INVOKABLE qint64 dialogChatPhotoId( int id ) const;
    Q_INVOKABLE int dialogChatUsersNumber( int id ) const;
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

    Q_INVOKABLE int me() const;
    Q_INVOKABLE bool started() const;

    Q_INVOKABLE QString convertDateToString( const QDateTime & date );

public slots:
    void updateContactList();
    void updateDialogList();
    void updateDialogListUsingTimer();

    void getHistory( int id, int count );
    void sendMessage( int id, const QString & msg );

    void loadUserInfo( int userId );
    void loadChatInfo( int chatId );

    void loadPhoto( qint64 msg_id );

    void sendFile( int dId, const QString & file );
    void sendFileDialog( int dId );
    void markRead( int dId );

    void setStatusOnline( bool stt );

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

    void msgFileDownloaded( qint64 msg_id );
    void msgFileDownloading( qint64 msg_id, qreal percent );

    void startedChanged();

private slots:
    void _startedChanged();

protected:
    void timerEvent(QTimerEvent *e);

private:
    TelegramPrivate *p;
};

#endif // TELEGRAM_H
