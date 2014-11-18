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
#include "sialantools/sialancalendarconverter.h"
#include "telegramqml.h"
#include "profilesmodel.h"
#include "telegrammessagesmodel.h"
#include "telegramdialogsmodel.h"
#include "emojis.h"

#include <QPointer>
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>
#include <QDebug>
#include <QTextDocument>
#include <QImageReader>

class SigramPrivate
{
public:
    QPointer<SialanQuickView> viewer;
    bool close_blocker;

    QTextDocument *doc;
};

Sigram::Sigram(QObject *parent) :
    QObject(parent)
{
    p = new SigramPrivate;
    p->doc = new QTextDocument(this);

#ifdef Q_OS_ANDROID
    p->close_blocker = true;
#else
    p->close_blocker = false;
#endif
    qmlRegisterType<TelegramQml>("Sigram", 1, 0, "Telegram");
    qmlRegisterType<ProfilesModel>("Sigram", 1, 0, "ProfilesModel");
    qmlRegisterType<ProfilesModelItem>("Sigram", 1, 0, "ProfilesModelItem");
    qmlRegisterType<TelegramMessagesModel>("Sigram", 1, 0, "MessagesModel");
    qmlRegisterType<TelegramDialogsModel>("Sigram", 1, 0, "DialogsModel");
    qmlRegisterType<Emojis>("Sigram", 1, 0, "Emojis");
}

QSize Sigram::imageSize(const QString &path)
{
    QImageReader img(path);
    return img.size();
}

qreal Sigram::htmlWidth(const QString &txt)
{
    p->doc->setHtml(txt);
    return p->doc->size().width() + 10;
}

QString Sigram::getTimeString(const QDateTime &dt)
{
    if( QDate::currentDate() == dt.date() ) // TODAY
        return dt.toString("HH:mm");
    else
    if( dt.date().daysTo(QDate::currentDate()) < 7 )
        return dt.toString("ddd HH:mm");
    else
    if( dt.date().year() == QDate::currentDate().year() )
        return dt.toString("dd MMM");
    else
        return dt.toString("dd MMM yy");
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
    p->viewer->engine()->rootContext()->setContextProperty( "Sigram", this );
    p->viewer->setSource(QUrl(QStringLiteral("qrc:/qml/Sigram/main.qml")));
    p->viewer->show();
}

void Sigram::close()
{
    p->close_blocker = false;
    p->viewer->close();
}

void Sigram::incomingAppMessage(const QString &msg)
{
    if( msg == "show" )
    {
        p->viewer->show();
        p->viewer->requestActivate();
    }
}

bool Sigram::eventFilter(QObject *o, QEvent *e)
{
    if( o == p->viewer )
    {
        switch( static_cast<int>(e->type()) )
        {
        case QEvent::Close:
            if( p->close_blocker )
            {
                static_cast<QCloseEvent*>(e)->ignore();
                emit backRequest();
            }
            else
            {
                static_cast<QCloseEvent*>(e)->accept();
            }

            return false;
            break;
        }
    }

    return QObject::eventFilter(o,e);
}

Sigram::~Sigram()
{
    delete p;
}
