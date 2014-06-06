#define UPDATE_TEXT_URL "http://labs.sialan.org/sigram/update.txt"

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

void VersionChecker::dismiss(qreal version)
{
    TelegramGui::settings()->setValue( QString("General/versionCheck:%1").arg(version), false );
}

void VersionChecker::checked(const QByteArray &d)
{
    QString data = d;

    QString info;
    qreal vrsn = 0;

    const QStringList & parts = data.split("\n\n",QString::SkipEmptyParts);
    foreach( const QString & s, parts )
    {
        QStringList spl = s.split("\n");
        if( spl.count() < 2 )
            continue;

        qreal version = spl.first().toDouble();
        if( version <= VERSION )
            continue;
        if( vrsn < version )
            vrsn = version;

        info = info + "\n\n" + QStringList(spl.mid(1)).join("\n") ;
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
