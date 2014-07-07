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

#define UPDATE_TEXT_URL "http://dl.labs.sialan.org/sigram_update.txt"

#include <QDir>
#include <QTimerEvent>
#include <QSettings>

#include "versionchecker.h"
#include "downloader.h"
#include "telegramgui.h"
#include "telegram_macros.h"

class VersionCheckerPrivate
{
public:
    Downloader *downloader;
    int recheck_timer;
};

VersionChecker::VersionChecker(QObject *parent) :
    QObject(parent)
{
    p = new VersionCheckerPrivate;
    p->downloader = new Downloader(this);
    p->recheck_timer = startTimer(21600000);

    connect( p->downloader, SIGNAL(finished(QByteArray)), SLOT(checked(QByteArray)) );

    check();
}

void VersionChecker::check()
{
    p->downloader->setPath(UPDATE_TEXT_URL);
    p->downloader->start();
}

void VersionChecker::dismiss(const QString &version)
{
    TelegramGui::settings()->setValue( QString("General/versionCheck:%1").arg(version), false );
}

void VersionChecker::checked(const QByteArray &d)
{
    QString data = d;

    QString info;
    QString vrsn = "0";

    const QStringList & parts = data.split("\n\n",QString::SkipEmptyParts);
    foreach( const QString & s, parts )
    {
        QStringList spl = s.split("\n");
        if( spl.count() < 2 )
            continue;

        QString version = spl.first().trimmed();
        if( version <= VERSION )
            continue;
        if( vrsn < version )
            vrsn = version;

        info = info + "\n\n" + QStringList(spl.mid(1)).join("\n") ;
    }

    if( info.contains(DONATE_KEY) )
    {
        info.remove(DONATE_KEY);
        TelegramGui::setDonate(true);
    }

    if( !TelegramGui::settings()->value( QString("General/versionCheck:%1").arg(vrsn), true ).toBool() )
        return;
    if( vrsn > VERSION  )
        emit updateAvailable( vrsn, info.trimmed() );
}

void VersionChecker::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->recheck_timer )
    {
        check();
    }
}

VersionChecker::~VersionChecker()
{
    delete p;
}
