#include "asemanwebpagegrabber.h"

#include <QPixmap>
#include <QTimer>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QDir>
#include <QImageWriter>
#include <QPointer>
#include <QDebug>

#ifdef ASEMAN_WEBENGINE
#include <QWebEngineFrame>
#include <QWebEngineView>
#include <QWebEngineSettings>
#define WEBFRAME_CLASS QWebEngineFrame
#define WEBVIEW_CLASS QWebEngineView
#define WEBSETTINGS_CLASS QWebEngineSettings
#else
#ifdef ASEMAN_WEBKIT
#include <QWebFrame>
#include <QWebView>
#include <QWebSettings>
#define WEBFRAME_CLASS QWebFrame
#define WEBVIEW_CLASS QWebView
#define WEBSETTINGS_CLASS QWebSettings
#endif
#endif

class AsemanWebPageGrabberPrivate
{
public:
    QPointer<WEBVIEW_CLASS> viewer;

    QTimer *timer;
    QTimer *destroyTimer;

    QUrl source;
    QString destination;
    QString destPrivate;
    int timeOut;
    int progress;
};

AsemanWebPageGrabber::AsemanWebPageGrabber(QObject *parent) :
    AsemanQuickObject(parent)
{
    p = new AsemanWebPageGrabberPrivate;
    p->timeOut = 0;
    p->progress = 0;

    p->timer = new QTimer(this);
    p->timer->setSingleShot(true);

    p->destroyTimer = new QTimer(this);
    p->destroyTimer->setSingleShot(true);
    p->destroyTimer->setInterval(1000);

    connect(p->timer, SIGNAL(timeout()), SLOT(completed()));
    connect(p->destroyTimer, SIGNAL(timeout()), SLOT(destroyWebView()));
}

void AsemanWebPageGrabber::setSource(const QUrl &source)
{
    if(p->source == source)
        return;

    p->source = source;
    emit sourceChanged();
}

QUrl AsemanWebPageGrabber::source() const
{
    return p->source;
}

void AsemanWebPageGrabber::setDestination(const QString &dest)
{
    if(p->destination == dest)
        return;

    p->destination = dest;
    emit destinationChanged();
}

QString AsemanWebPageGrabber::destination() const
{
    return p->destination;
}

void AsemanWebPageGrabber::setTimeOut(int ms)
{
    if(p->timeOut == ms)
        return;

    p->timeOut = ms;
    emit timeOutChanged();
}

int AsemanWebPageGrabber::timeOut() const
{
    return p->timeOut;
}

bool AsemanWebPageGrabber::running() const
{
    return p->viewer;
}

void AsemanWebPageGrabber::start(bool force)
{
    if(!force)
    {
        const QUrl &checkUrl = check(p->source, &(p->destPrivate));
        if(!checkUrl.isEmpty())
        {
            emit finished(checkUrl);
            return;
        }
    }
    else
        p->destPrivate.clear();

    createWebView();

    p->progress = 0;
    p->viewer->stop();
    p->viewer->setUrl(p->source);

    p->timer->stop();
    if(p->timeOut)
    {
        p->timer->setInterval(p->timeOut);
        p->timer->start();
    }
}

QUrl AsemanWebPageGrabber::check(const QUrl &source, QString *destPath)
{
    if(source.isEmpty())
        return QUrl();

    if(!p->destination.isEmpty())
    {
        QDir().mkpath(p->destination);

        const QString &urlString = source.toString();
        const QString hash = QCryptographicHash::hash(urlString.toUtf8(), QCryptographicHash::Md5).toHex();
        QString destPrivate = p->destination + "/" + hash + ".png";
        if(destPath)
            *destPath = destPrivate;

        if(QFileInfo::exists(destPrivate))
            return QUrl::fromLocalFile(destPrivate);
    }

    return QUrl();
}

void AsemanWebPageGrabber::completed(bool stt)
{
    if(!stt)
        return;
    if(!p->viewer)
        return;
    if(p->progress < 80)
    {
        p->timer->stop();
        p->viewer->stop();

        destroyWebView();
        emit complete(QImage());
        emit finished(QUrl());
        p->destPrivate.clear();
        return;
    }

    p->timer->stop();
    p->viewer->stop();

    const QPixmap pixmap = p->viewer->grab();
    const QImage &image = pixmap.toImage();

    if(!p->destPrivate.isEmpty())
    {
        QImageWriter writer(p->destPrivate);
        writer.write(image);
    }

    destroyWebView();

    emit complete(image);
    emit finished(QUrl::fromLocalFile(p->destPrivate));
    p->destPrivate.clear();
}

void AsemanWebPageGrabber::loadProgress(int pr)
{
    p->progress = pr;
}

void AsemanWebPageGrabber::createWebView()
{
    p->destroyTimer->stop();
    if(p->viewer)
        return;

    p->viewer = new WEBVIEW_CLASS();
    p->viewer->resize(800, 800);
    p->viewer->page()->mainFrame()->setScrollBarPolicy(Qt::Horizontal, Qt::ScrollBarAlwaysOff);
    p->viewer->page()->mainFrame()->setScrollBarPolicy(Qt::Vertical, Qt::ScrollBarAlwaysOff);
//    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::JavascriptEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::JavaEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::PluginsEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::PrivateBrowsingEnabled, true);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::LinksIncludedInFocusChain, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::JavascriptCanOpenWindows, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::JavascriptCanCloseWindows, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::JavascriptCanAccessClipboard, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::OfflineStorageDatabaseEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::OfflineWebApplicationCacheEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::LocalStorageEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::LocalContentCanAccessFileUrls, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::AcceleratedCompositingEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::NotificationsEnabled, false);
    p->viewer->settings()->setAttribute(WEBSETTINGS_CLASS::Accelerated2dCanvasEnabled, false);

    connect(p->viewer, SIGNAL(loadProgress(int)), SLOT(loadProgress(int)));
    connect(p->viewer, SIGNAL(loadFinished(bool)), SLOT(completed(bool)), Qt::QueuedConnection);

    emit runningChanged();
}

void AsemanWebPageGrabber::destroyWebView()
{
    if(!p->viewer)
        return;

    delete p->viewer;
    emit runningChanged();
}

AsemanWebPageGrabber::~AsemanWebPageGrabber()
{
    if(p->viewer)
        delete p->viewer;
    delete p;
}

