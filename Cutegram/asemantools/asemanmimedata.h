#ifndef ASEMANMIMEDATA_H
#define ASEMANMIMEDATA_H

#include <QObject>
#include <QUrl>
#include <QVariantMap>

class AsemanMimeDataPrivate;
class AsemanMimeData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString html READ html WRITE setHtml NOTIFY htmlChanged)
    Q_PROPERTY(QList<QUrl> urls READ urls WRITE setUrls NOTIFY urlsChanged)
    Q_PROPERTY(QVariantMap dataMap READ dataMap WRITE setDataMap NOTIFY dataMapChanged)

public:
    AsemanMimeData(QObject *parent = 0);
    ~AsemanMimeData();

    void setText(const QString &txt);
    QString text() const;

    void setHtml(const QString &html);
    QString html() const;

    void setUrls(const QList<QUrl> &urls);
    QList<QUrl> urls() const;

    void setDataMap(const QVariantMap &map);
    QVariantMap dataMap() const;

signals:
    void textChanged();
    void htmlChanged();
    void urlsChanged();
    void dataMapChanged();

private:
    AsemanMimeDataPrivate *p;
};

Q_DECLARE_METATYPE(AsemanMimeData*)

#endif // ASEMANMIMEDATA_H
