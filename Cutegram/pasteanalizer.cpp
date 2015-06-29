#include "pasteanalizer.h"
#include "asemantools/asemanapplication.h"

#include <QClipboard>
#include <QApplication>
#include <QMimeData>
#include <QImage>
#include <QImageWriter>
#include <QFile>
#include <QDebug>

class PasteAnalizerPrivate
{
public:
    QString text;
    QString path;
    QString temp;
};

PasteAnalizer::PasteAnalizer(QObject *parent) :
    QObject(parent)
{
    p = new PasteAnalizerPrivate;
}

QString PasteAnalizer::path() const
{
    return p->path;
}

QString PasteAnalizer::text() const
{
    return p->text;
}

QString PasteAnalizer::temp() const
{
    return p->temp;
}

void PasteAnalizer::setTemp(const QString &temp)
{
    if(p->temp == temp)
        return;

    p->temp = temp;
    emit tempChanged();
}

bool PasteAnalizer::analize()
{
    QClipboard *cb = AsemanApplication::clipboard();
    if(!cb)
        return false;

    const QMimeData *data = cb->mimeData();
    if(!data)
        return false;

    QImage image;

    if (data->hasImage())
    {
        image = qvariant_cast<QImage>(data->imageData());
    }

    if(!image.isNull())
    {
        const QString &path = p->temp + "/image.png";
        QFile::remove(path);
        QImageWriter writer(path);
        if(!writer.write(image))
            return false;

        p->path = path;
        p->text.clear();

        emit pathChanged();
        emit textChanged();
        return true;
    }

    return false;
}

PasteAnalizer::~PasteAnalizer()
{
    delete p;
}

