#ifndef TELEGRAM_H
#define TELEGRAM_H

#include <QThread>
#include <QMap>
#include <QDebug>
#include <QDateTime>

class MessageClass;
class DialogClass;
class UserClass;
class TelegramCorePrivare;
class TelegramCore : public QObject
{
    Q_OBJECT
public:
    TelegramCore(int argc, char **argv, QObject *parent = 0);
    ~TelegramCore();

    int callExec();

public slots:
    void contactList();
    void dialogList();

    void getHistory( const QString & user, int count );
    void sendMessage( const QString & user, const QString & msg );

    void setStatusOnline( bool stt );

    void loadUserInfo( const QString & user );
    void loadChatInfo( const QString & chat );

    void loadPhoto( qint64 msg_id );

    void sendFile( const QString & peer, const QString & file );
    void markRead( const QString & peer );

    void start();

signals:
    void started();

    void contactListClear();
    void contactFounded( const UserClass & contact );
    void contactListFinished();

    void dialogListClear();
    void dialogFounded( const DialogClass & contact );
    void dialogListFinished();

    void msgMarkedAsRead( qint64 msg_id, const QDateTime & date );
    void msgSent( qint64 msg_id, const QDateTime & date );

    void incomingMsg( const MessageClass & msg );
    void userIsTyping( int chat_id, int user_id );
    void userStatusChanged( int user_id, int status, const QDateTime & when );

    void photoFound( int id, qint64 volume );
    void fileLoaded( qint64 volume, int localId, const QString & path );

    void fileUploading(int user_id, const QString & file, qint64 total, qint64 uploaded );
    void fileDownloading(qint64 volume, qint64 total, qint64 downloaded );

private:
    void send_command( const QString & cmd );

private:
    TelegramCorePrivare *p;
};

#endif // TELEGRAM_H
