#ifndef ASEMANMAPDOWNLOADER_H
#define ASEMANMAPDOWNLOADER_H

#include <QObject>
#include <QUrl>
#include <QSize>
#ifdef QT_POSITIONING_LIB
#include <QGeoCoordinate>
#define GEO_CLASS_NAME QGeoCoordinate
#else
#include <QPointF>
#define GEO_CLASS_NAME QPointF
#endif

class AsemanMapDownloaderPrivate;
class AsemanMapDownloader : public QObject
{
    Q_OBJECT
    Q_ENUMS(MapProvider)

    Q_PROPERTY(QUrl destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(QUrl image READ image NOTIFY imageChanged)
    Q_PROPERTY(GEO_CLASS_NAME currentGeo READ currentGeo NOTIFY currentGeoChanged)
    Q_PROPERTY(int mapProvider READ mapProvider WRITE setMapProvider NOTIFY mapProviderChanged)
    Q_PROPERTY(QSize size READ size WRITE setSize NOTIFY sizeChanged)
    Q_PROPERTY(int zoom READ zoom WRITE setZoom NOTIFY zoomChanged)
    Q_PROPERTY(bool downloading READ downloading NOTIFY downloadingChanged)

public:
    enum MapProvider {
        MapProviderGoogle = 0
    };

    AsemanMapDownloader(QObject *parent = 0);
    ~AsemanMapDownloader();

    void setDestination(const QUrl &dest);
    QUrl destination() const;

    void setMapProvider(int type);
    int mapProvider() const;

    void setSize(const QSize &size);
    QSize size() const;

    void setZoom(int zoom);
    int zoom() const;

    GEO_CLASS_NAME currentGeo() const;
    QUrl image() const;

    bool downloading() const;

public slots:
    void download(const GEO_CLASS_NAME &geo);
    bool check(const GEO_CLASS_NAME &geo);
    QString linkOf(const GEO_CLASS_NAME &geo);
    QString webLinkOf(const GEO_CLASS_NAME &geo);
    QString pathOf(const GEO_CLASS_NAME &geo);

signals:
    void destinationChanged();
    void currentGeoChanged();
    void imageChanged();
    void mapProviderChanged();
    void sizeChanged();
    void zoomChanged();
    void finished();
    void downloadingChanged();

private slots:
    void finished( const QByteArray & data );

private:
    void init_downloader();

private:
    AsemanMapDownloaderPrivate *p;
};

#endif // ASEMANMAPDOWNLOADER_H
