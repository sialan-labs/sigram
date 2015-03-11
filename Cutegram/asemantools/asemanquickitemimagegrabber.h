#ifndef ASEMANQUICKITEMIMAGEGRABBER_H
#define ASEMANQUICKITEMIMAGEGRABBER_H

#include <QObject>
#include <QImage>
#include <QUrl>

class QQuickItem;
class AsemanQuickItemImageGrabberPrivate;
class AsemanQuickItemImageGrabber : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem* item READ item WRITE setItem NOTIFY itemChanged)
    Q_PROPERTY(QImage image READ image NOTIFY imageChanged)
    Q_PROPERTY(QUrl defaultImage READ defaultImage WRITE setDefaultImage NOTIFY defaultImageChanged)

public:
    AsemanQuickItemImageGrabber(QObject *parent = 0);
    ~AsemanQuickItemImageGrabber();

    void setItem(QQuickItem *item);
    QQuickItem *item() const;

    void setDefaultImage(const QUrl &url);
    QUrl defaultImage() const;

    QImage image() const;

public slots:
    void start();

signals:
    void itemChanged();
    void imageChanged();
    void defaultImageChanged();

private slots:
    void ready();

private:
    AsemanQuickItemImageGrabberPrivate *p;
};

#endif // ASEMANQUICKITEMIMAGEGRABBER_H
