#include <QApplication>
#include <QWindow>
#include <QIcon>

#include "telegramgui.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Sialan Telegram");
    app.setApplicationDisplayName("Sigram");
    app.setWindowIcon(QIcon(":/files/icon.png"));
    app.setQuitOnLastWindowClosed(false);

    TelegramGui gui;
    gui.start();

    return app.exec();
}
