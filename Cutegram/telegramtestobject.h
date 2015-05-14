#ifndef TELEGRAMTESTOBJECT_H
#define TELEGRAMTESTOBJECT_H

#include <QObject>
#include "telegram.h"

class TelegramTestObjectPrivate;
class TelegramTestObject : public QObject
{
    Q_OBJECT
public:
    TelegramTestObject(QObject *parent = 0);
    ~TelegramTestObject();

public slots:
    void start();

private slots:
    void authNeeded();
    void authLoggedIn();
    void authSendCode();
    void messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, QList<Dialog> dialogs, QList<Message> messages, QList<Chat> chats, QList<User> users);

private:
    TelegramTestObjectPrivate *p;
};

#endif // TELEGRAMTESTOBJECT_H
