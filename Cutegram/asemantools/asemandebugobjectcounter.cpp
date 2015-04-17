#include "asemandebugobjectcounter.h"

#include <QTimer>
#include <QPointer>
#include <QMap>
#include <QDebug>

class AsemanDebugObjectCounterPrivate
{
public:
    QTimer *timer;
    QPointer<QObject> object;
};

AsemanDebugObjectCounter::AsemanDebugObjectCounter(QObject *parent) :
    QObject(parent)
{
    p = new AsemanDebugObjectCounterPrivate;
    p->timer = new QTimer(this);

    connect(p->timer, SIGNAL(timeout()), SLOT(timeout()));
}

void AsemanDebugObjectCounter::start(QObject *object, int interval)
{
    p->timer->stop();

    p->object = object;
    p->timer->setInterval(interval);
    p->timer->start();
}

void AsemanDebugObjectCounter::timeout()
{
    if(!p->object)
    {
        p->timer->stop();
        return;
    }

    QMap<QString,int> counts;
    calculate(p->object, counts);

    qDebug() << "\n\n";
    int total = 0;
    QMapIterator<QString,int> i(counts);
    while(i.hasNext())
    {
        i.next();
        qDebug() << i.key() + " = " << i.value();
        total += i.value();
    }

    qDebug() << "total" << total;
}

void AsemanDebugObjectCounter::calculate(QObject *obj, QMap<QString, int> &count)
{
    count[obj->metaObject()->className()] = count[obj->metaObject()->className()]+1;

    QObjectList childs = obj->children();
    foreach(QObject *child, childs)
        calculate(child, count);
}

AsemanDebugObjectCounter::~AsemanDebugObjectCounter()
{
    delete p;
}

