#ifndef ASEMANWEBPAGEGRABBER_H
#define ASEMANWEBPAGEGRABBER_H

#include "asemanquickobject.h"
#include <QUrl>

class AsemanWebPageGrabberPrivate;
class AsemanWebPageGrabber : public AsemanQuickObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(int timeOut READ timeOut WRITE setTimeOut NOTIFY timeOutChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(bool isAvailable READ isAvailable NOTIFY isAvailableChanged)

public:
    AsemanWebPageGrabber(QObject *parent = 0);
    ~AsemanWebPageGrabber();

    void setSource(const QUrl &source);
    QUrl source() const;

    void setDestination(const QString &dest);
    QString destination() const;

    void setTimeOut(int ms);
    int timeOut() const;

    bool running() const;
    bool isAvailable() const;

public slots:
    void start(bool force = false);
    QUrl check(const QUrl &source, QString *destPath = 0);

signals:
    void complete(const QImage &image);
    void finished(const QUrl &path);

    void sourceChanged();
    void destinationChanged();
    void timeOutChanged();
    void runningChanged();
    void isAvailableChanged();

private slots:
    void completed(bool stt = true);
    void loadProgress(int p);

    void createWebView();
    void destroyWebView();

private:
    AsemanWebPageGrabberPrivate *p;
};

#endif // ASEMANWEBPAGEGRABBER_H
