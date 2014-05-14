#include <QGuiApplication>
#include <QDebug>
#include "telegram.h"

int main (int argc, char **argv)
{
    QGuiApplication app(argc,argv);

    Telegram tg(argc,argv);

    return app.exec();
}
