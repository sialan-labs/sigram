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

public slots:
    void contactList();
    void dialogList();
    void getHistory( const QString & user, int count );

signals:
    void contactsChanged();
    void dialogsChanged();
    void tgStarted();
    void incomingMsg( const MessageClass & msg );

protected:
    void run();

private slots:
    void _contactListClear();
    void _contactFounded( const UserClass & contact );
    void _contactListFinished();

    void _dialogListClear();
    void _dialogFounded( const DialogClass & dialog );
    void _dialogListFinished();

    void _incomingMsg( const MessageClass & msg );

private:
    TelegramThreadPrivate *p;
};

#endif // TELEGRAMTHREAD_H
