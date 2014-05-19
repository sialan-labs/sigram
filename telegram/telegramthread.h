#ifndef TELEGRAMTHREAD_H
#define TELEGRAMTHREAD_H

#include <QThread>

class MessageClass;
class DialogClass;
class UserClass;
class TelegramThreadPrivate;
class TelegramThread : public QThread
{
    Q_OBJECT
public:
    TelegramThread(int argc, char **argv, QObject *parent = 0);
    ~TelegramThread();

    int callExec();

    const QHash<int,UserClass> & contacts() const;
    const QHash<int,DialogClass> & dialogs() const;

    const QHash<int,QMap<qint64, qint64> > & usersMessages() const;
    const QHash<qint64,MessageClass> & messages() const;

public slots:
    void contactList();
    void dialogList();
    void getHistory(int id, int count );
    void sendMessage( int id, const QString & msg );

signals:
    void contactsChanged();
    void dialogsChanged();
    void tgStarted();
    void incomingMsg( qint64 msg_id );
    void userIsTyping( int chat_id, int user_id );
    void userStatusChanged( int user_id, int status, const QDateTime & when );
    void msgChanged( qint64 msg_id );
    void msgSent( qint64 old_id, qint64 msg_id );

protected:
    void run();

private slots:
    void _contactListClear();
    void _contactFounded( const UserClass & contact );
    void _contactListFinished();

    void _dialogListClear();
    void _dialogFounded( const DialogClass & dialog );
    void _dialogListFinished();

    void _msgMarkedAsRead(qint64 msg_id, const QDateTime &date );
    void _msgSent(qint64 msg_id, const QDateTime &date );
    void _incomingMsg( const MessageClass & msg );
    void _userStatusChanged(int user_id, int status, const QDateTime &when );

private:
    TelegramThreadPrivate *p;
};

#endif // TELEGRAMTHREAD_H
