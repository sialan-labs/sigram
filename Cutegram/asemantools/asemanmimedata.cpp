#include "asemanmimedata.h"

class AsemanMimeDataPrivate
{
public:
    QString text;
    QString html;
    QList<QUrl> urls;
    QVariantMap dataMap;
};

AsemanMimeData::AsemanMimeData(QObject *parent) :
    QObject(parent)
{
    p = new AsemanMimeDataPrivate;
}

void AsemanMimeData::setText(const QString &txt)
{
    if(p->text == txt)
        return;

    p->text = txt;
    emit textChanged();
}

QString AsemanMimeData::text() const
{
    return p->text;
}

void AsemanMimeData::setHtml(const QString &html)
{
    if(p->html == html)
        return;

    p->html = html;
    emit htmlChanged();
}

QString AsemanMimeData::html() const
{
    return p->html;
}

void AsemanMimeData::setUrls(const QList<QUrl> &urls)
{
    if(p->urls == urls)
        return;

    p->urls = urls;
    emit urlsChanged();
}

QList<QUrl> AsemanMimeData::urls() const
{
    return p->urls;
}

void AsemanMimeData::setDataMap(const QVariantMap &map)
{
    if(p->dataMap == map)
        return;

    p->dataMap = map;
    emit dataMapChanged();
}

QVariantMap AsemanMimeData::dataMap() const
{
    return p->dataMap;
}

AsemanMimeData::~AsemanMimeData()
{
    delete p;
}

