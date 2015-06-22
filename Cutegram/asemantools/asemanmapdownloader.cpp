#include "asemanmapdownloader.h"
#include "asemandownloader.h"

#include <QFile>
#include <QDir>
#include <QDebug>

class AsemanMapDownloaderPrivate
{
public:
    GEO_CLASS_NAME geo;
    QUrl destination;
    QUrl image;
    AsemanDownloader *downloader;
    int mapProvider;
    QSize size;
    int zoom;
    bool downloading;
};

AsemanMapDownloader::AsemanMapDownloader(QObject *parent) :
    QObject(parent)
{
    p = new AsemanMapDownloaderPrivate;
    p->downloader = 0;
    p->mapProvider = 0;
    p->size = QSize(256,256);
    p->zoom = 15;
    p->downloading = false;
}

void AsemanMapDownloader::setDestination(const QUrl &dest)
{
    if(p->destination == dest)
        return;

    p->destination = dest;
    emit destinationChanged();
}

QUrl AsemanMapDownloader::destination() const
{
    return p->destination;
}

void AsemanMapDownloader::setMapProvider(int type)
{
    if(p->mapProvider == type)
        return;

    p->mapProvider = type;
    emit mapProviderChanged();
}

int AsemanMapDownloader::mapProvider() const
{
    return p->mapProvider;
}

void AsemanMapDownloader::setSize(const QSize &size)
{
    if(p->size == size)
        return;

    p->size = size;
    emit sizeChanged();
}

QSize AsemanMapDownloader::size() const
{
    return p->size;
}

void AsemanMapDownloader::setZoom(int zoom)
{
    if(p->zoom == zoom)
        return;

    p->zoom = zoom;
    emit zoomChanged();
}

int AsemanMapDownloader::zoom() const
{
    return p->zoom;
}

GEO_CLASS_NAME AsemanMapDownloader::currentGeo() const
{
    return p->geo;
}

QUrl AsemanMapDownloader::image() const
{
    return p->image;
}

bool AsemanMapDownloader::downloading() const
{
    return p->downloading;
}

void AsemanMapDownloader::download(const GEO_CLASS_NAME &geo)
{
    if(p->geo == geo)
        return;
    if(p->destination.isEmpty())
        return;
#ifdef QT_POSITIONING_LIB
    if(!geo.isValid())
        return;
#else
    if(geo.isNull())
        return;
#endif

    p->geo = geo;
    QDir().mkpath(p->destination.toLocalFile());

    const QString filePath = pathOf(p->geo);
    if(QFile::exists(filePath))
    {
        p->image = QUrl::fromLocalFile(filePath);
        emit currentGeoChanged();
        emit imageChanged();
        emit finished();
        return;
    }

    init_downloader();

    p->downloader->setDestination(filePath);
    p->downloader->setPath( linkOf(p->geo) );
    p->downloader->start();

    p->downloading = true;
    emit currentGeoChanged();
    emit downloadingChanged();
}

bool AsemanMapDownloader::check(const GEO_CLASS_NAME &geo)
{
    return QFile::exists( pathOf(geo) );
}

QString AsemanMapDownloader::linkOf(const GEO_CLASS_NAME &geo)
{
    QString path;
    switch(p->mapProvider)
    {
    default:
    case MapProviderGoogle:
        path = QString("http://maps.google.com/maps/api/staticmap?center=") +
        #ifdef QT_POSITIONING_LIB
                        QString::number(geo.latitude()) + "," +
                        QString::number(geo.longitude()) +
        #else
                        QString::number(geo.x()) + "," +
                        QString::number(geo.y()) +
        #endif
                        "&zoom=" + QString::number(p->zoom) + "&size=" +
                        QString::number(p->size.width()) + "x" +
                        QString::number(p->size.height()) +
                "&sensor=false";
        break;
    }

    return path;
}

QString AsemanMapDownloader::webLinkOf(const GEO_CLASS_NAME &geo)
{
    QString path;
    switch(p->mapProvider)
    {
    default:
    case MapProviderGoogle:
        path = QString("http://maps.google.com/maps?&q=") +
        #ifdef QT_POSITIONING_LIB
                        QString::number(geo.latitude()) + "," +
                        QString::number(geo.longitude());
        #else
                        QString::number(geo.x()) + "," +
                        QString::number(geo.y());
        #endif
        break;
    }

    return path;
}

QString AsemanMapDownloader::pathOf(const GEO_CLASS_NAME &geo)
{
    QString filePath = p->destination.toLocalFile() + "/" +
                       QString::number(p->mapProvider) + "_" +
#ifdef QT_POSITIONING_LIB
                       QString::number(geo.latitude()) + "x" +
                       QString::number(geo.longitude()) + "_" +
#else
                       QString::number(geo.x()) + "x" +
                       QString::number(geo.y()) + "_" +
#endif
                       QString::number(p->size.width()) + "x" +
                       QString::number(p->size.height()) + ".png";

    return filePath;
}

void AsemanMapDownloader::finished(const QByteArray &data)
{
    Q_UNUSED(data)

    p->image = QUrl::fromLocalFile(p->downloader->destination());

    p->downloading = false;

    emit downloadingChanged();
    emit imageChanged();
    emit finished();
}

void AsemanMapDownloader::init_downloader()
{
    if(p->downloader)
        return;

    p->downloader = new AsemanDownloader(this);

    connect(p->downloader, SIGNAL(finished(QByteArray)), SLOT(finished(QByteArray)), Qt::QueuedConnection);
}

AsemanMapDownloader::~AsemanMapDownloader()
{
    delete p;
}

