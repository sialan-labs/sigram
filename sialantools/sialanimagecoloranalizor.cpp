/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define MAX_ACTIVE_THREADS 4
#define IMAGE_WIDTH 400

#include "sialanimagecoloranalizor.h"

#include <QThread>
#include <QCoreApplication>
#include <QQueue>
#include <QSet>
#include <QImageReader>
#include <QImage>
#include <QFileInfo>
#include <QDebug>

SialanImageColorAnalizorThread *colorizor_thread = 0;

class SialanImageColorAnalizorPrivate
{
public:
    QString source;
    QColor color;
    int method;
};

SialanImageColorAnalizor::SialanImageColorAnalizor(QObject *parent) :
    QObject(parent)
{
    p = new SialanImageColorAnalizorPrivate;
    p->method = Normal;

    if( !colorizor_thread )
        colorizor_thread = new SialanImageColorAnalizorThread(QCoreApplication::instance());

    connect( colorizor_thread, SIGNAL(found(QString)), SLOT(found(QString)) );
}

QString SialanImageColorAnalizor::source() const
{
    return p->source;
}

void SialanImageColorAnalizor::setSource(const QString &source)
{
    if( p->source == source )
        return;

    p->source = source;
    emit sourceChanged();

    if( p->source.isEmpty() )
        return;

    colorizor_thread->analize(p->method, source);
    found(p->source);
}

int SialanImageColorAnalizor::method() const
{
    return p->method;
}

void SialanImageColorAnalizor::setMethod(int m)
{
    if( p->method == m )
        return;

    p->method = static_cast<Method>(m);
    emit methodChanged();
}

QColor SialanImageColorAnalizor::color() const
{
    return p->color;
}

void SialanImageColorAnalizor::found(const QString &path)
{
    if( path != p->source )
        return;

    const QHash<QString,QColor> & results = colorizor_thread->results();
    if( !results.contains(p->source) )
        return;

    p->color = results.value(p->source);
    emit colorChanged();
}

SialanImageColorAnalizor::~SialanImageColorAnalizor()
{
    delete p;
}


class SialanImageColorAnalizorThreadPrivate
{
public:
    QHash<QString,QColor> results;

    QQueue<QString> queue;
    QSet<SialanImageColorAnalizorCore*> cores;
    QQueue<SialanImageColorAnalizorCore*> free_cores;
};

SialanImageColorAnalizorThread::SialanImageColorAnalizorThread(QObject *parent) :
    QObject(parent)
{
    p = new SialanImageColorAnalizorThreadPrivate;
}

const QHash<QString, QColor> &SialanImageColorAnalizorThread::results() const
{
    return p->results;
}

void SialanImageColorAnalizorThread::analize(int method, const QString &path)
{
    if( p->results.contains(path) )
        return;

    SialanImageColorAnalizorCore *core = getCore();
    if( !core )
    {
        p->queue.append(path);
        return;
    }

    QMetaObject::invokeMethod( core, "analize", Qt::QueuedConnection, Q_ARG(int,method) , Q_ARG(QString,path) );
}

void SialanImageColorAnalizorThread::found_slt(SialanImageColorAnalizorCore *c, const QString &source, const QColor & color)
{
    p->results[source] = color;
    emit found(source);

    p->free_cores.append(c);
    if( p->queue.isEmpty() )
        return;

    SialanImageColorAnalizorCore *core = getCore();
    if( !core )
        return;

    const QString & path = p->queue.takeFirst();
    QMetaObject::invokeMethod( core, "analize", Qt::QueuedConnection, Q_ARG(QString,path) );
}

SialanImageColorAnalizorCore *SialanImageColorAnalizorThread::getCore()
{
    if( !p->free_cores.isEmpty() )
        return p->free_cores.takeFirst();
    if( p->cores.count() > MAX_ACTIVE_THREADS )
        return 0;

    QThread *thread = new QThread(this);

    SialanImageColorAnalizorCore *core = new SialanImageColorAnalizorCore();
    core->moveToThread(thread);

    connect( core, SIGNAL(found_slt(SialanImageColorAnalizorCore*,QString,QColor)), SLOT(found_slt(SialanImageColorAnalizorCore*,QString,QColor)), Qt::QueuedConnection );

    thread->start();
    p->cores.insert(core);

    return core;
}

SialanImageColorAnalizorThread::~SialanImageColorAnalizorThread()
{
    foreach( SialanImageColorAnalizorCore *core, p->cores )
    {
        QThread *thread = core->thread();
        thread->quit();
        thread->wait();
        core->deleteLater();
    }

    delete p;
}


class SialanImageColorAnalizorCorePrivate
{
public:
};

SialanImageColorAnalizorCore::SialanImageColorAnalizorCore(QObject *parent) :
    QObject(parent)
{
    p = new SialanImageColorAnalizorCorePrivate;
}

void SialanImageColorAnalizorCore::analize(int method, const QString &path)
{
    QImageReader image(path);

    QSize image_size = image.size();
    qreal ratio = image_size.width()/(qreal)image_size.height();
    image_size.setWidth( IMAGE_WIDTH );
    image_size.setHeight( IMAGE_WIDTH/ratio );

    image.setScaledSize( image_size );
    const QImage & img = image.read();

    QColor result;

    switch( method )
    {
    case SialanImageColorAnalizor::Normal:
    {
        qreal sum_r = 0;
        qreal sum_g = 0;
        qreal sum_b = 0;
        int count = 0;

        for( int i=0 ; i<image_size.width(); i++ )
        {
            for( int j=0 ; j<image_size.height(); j++ )
            {
                QColor clr = img.pixel(i,j);
                qreal mid = (clr.red()+clr.green()+clr.blue())/3;
                if( mid > 180 || mid < 70 )
                    continue;

                sum_r += clr.red();
                sum_g += clr.green();
                sum_b += clr.blue();
                count++;
            }
        }

        result = QColor( sum_r/count, sum_g/count, sum_b/count );
    }
        break;

    case SialanImageColorAnalizor::MoreSaturation:
    {

    }
        break;
    }

    emit found_slt( this, path, result );
}

SialanImageColorAnalizorCore::~SialanImageColorAnalizorCore()
{
    delete p;
}
