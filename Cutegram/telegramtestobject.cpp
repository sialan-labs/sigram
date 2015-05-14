#include "telegramtestobject.h"

#include <telegram.h>

#include <QCoreApplication>
#include <QDebug>
#include <QTimer>
#include <QInputDialog>

class TelegramTestObjectPrivate
{
public:
    Telegram *tg;
};

TelegramTestObject::TelegramTestObject(QObject *parent) :
    QObject(parent)
{
    p = new TelegramTestObjectPrivate;
    p->tg = 0;

    QTimer::singleShot(500, this, SLOT(start()));
}

void TelegramTestObject::start()
{
    if(p->tg)
        return;

    p->tg = new Telegram("+989212130443", "/home/bardia/test/", QCoreApplication::applicationDirPath() + "/tg-server.pub");
    p->tg->init();

    connect(p->tg, SIGNAL(authNeeded()), SLOT(authNeeded()));
    connect(p->tg, SIGNAL(authLoggedIn()), SLOT(authLoggedIn()));
    connect(p->tg, SIGNAL(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)),
            SLOT(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)) );
}

void TelegramTestObject::authNeeded()
{
    qDebug() << __PRETTY_FUNCTION__;
    p->tg->authCheckPhone();
    QTimer::singleShot(2000, this, SLOT(authSendCode()));
}

void TelegramTestObject::authLoggedIn()
{
    qDebug() << __PRETTY_FUNCTION__;
    p->tg->messagesGetDialogs();
}

void TelegramTestObject::authSendCode()
{
    qDebug() << __PRETTY_FUNCTION__;
    p->tg->authSendCode();

    QString code = QInputDialog::getText(0, "get code", "get code");
    if(code.isEmpty())
        QTimer::singleShot(2000, this, SLOT(authSendCode()));
    else
        p->tg->authSignIn(code);
}

void TelegramTestObject::messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, QList<Dialog> dialogs, QList<Message> messages, QList<Chat> chats, QList<User> users)
{
    foreach(User u, users)
        qDebug() << u.firstName();
}

TelegramTestObject::~TelegramTestObject()
{
    delete p;
}

