/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "sigram.h"
#include "sialantools/sialanquickview.h"
#include "telegramqml.h"

#include <QPointer>
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>

class SigramPrivate
{
public:
    QPointer<SialanQuickView> viewer;
};

Sigram::Sigram(QObject *parent) :
    QObject(parent)
{
    p = new SigramPrivate;

    qmlRegisterType<TelegramQml>("Sigram", 1, 0, "Telegram");
}

void Sigram::start()
{
    if( p->viewer )
        return;

    p->viewer = new SialanQuickView(
#ifdef QT_DEBUG
                SialanQuickView::AllExceptLogger
#else
                SialanQuickView::AllComponents
#endif
                );
    p->viewer->engine()->rootContext()->setContextProperty( "sigram", this );
    p->viewer->setSource(QUrl(QStringLiteral("qrc:/qml/Sigram/main.qml")));
    p->viewer->show();
}

void Sigram::incomingAppMessage(const QString &msg)
{
    if( msg == "show" )
    {
        p->viewer->show();
        p->viewer->requestActivate();
    }
}

Sigram::~Sigram()
{
    delete p;
}
