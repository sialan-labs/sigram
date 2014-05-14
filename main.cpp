#include <QGuiApplication>
#include "telegramgui.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    TelegramGui gui;
    gui.start();

    return app.exec();
}
