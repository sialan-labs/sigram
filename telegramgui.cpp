#include "telegramgui.h"
#include "telegram/telegram.h"

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QGuiApplication>

class TelegramGuiPrivate
{
public:
    QQmlApplicationEngine *engine;
    Telegram *tg;

    char *args;
};

TelegramGui::TelegramGui(QObject *parent) :
    QObject(parent)
{
    p = new TelegramGuiPrivate;
    p->engine = 0;
    p->tg = 0;
    p->args = QGuiApplication::arguments().first().toUtf8().data();
}

void TelegramGui::start()
{
    if( p->engine )
        return;

    p->tg = new Telegram(1,&(p->args));

    p->engine = new QQmlApplicationEngine(this);
    p->engine->rootContext()->setContextProperty( "Telegram", p->tg );
    p->engine->load(QUrl(QStringLiteral("qrc:///main.qml")));
}

TelegramGui::~TelegramGui()
{
    delete p;
}
