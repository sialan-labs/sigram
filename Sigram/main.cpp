/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <QApplication>
#include <QWindow>
#include <QIcon>

#include "telegramgui.h"
#include "qtsingleapplication/qtsingleapplication.h"

int main(int argc, char *argv[])
{
    QtSingleApplication app(argc, argv);
    app.setApplicationName("Sialan Telegram");
    app.setApplicationDisplayName("Sigram");
    app.setOrganizationDomain("org.sialan.kaqaz");
    app.setOrganizationName("Sialan");
    app.setWindowIcon(QIcon(":/files/icon.png"));
    app.setQuitOnLastWindowClosed(false);

    if( app.isRunning() )
    {
        app.sendMessage("show");
        return 0;
    }

    TelegramGui gui;
    gui.start();

    QObject::connect( &app, SIGNAL(messageReceived(QString)), &gui, SLOT(incomingAppMessage(QString)) );

    return app.exec();
}
