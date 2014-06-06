#include "setobject.h"

#include <QSet>

class SetObjectPrivate
{
public:
    QSet<QString> data;
};

SetObject::SetObject(QObject *parent) :
    QObject(parent)
{
    p = new SetObjectPrivate;
}

void SetObject::insert(const QString &str)
{
    p->data.insert(str);
}

void SetObject::remove(const QString &str)
{
    p->data.remove(str);
}

bool SetObject::contains(const QString &str)
{
    return p->data.contains(str);
}

QStringList SetObject::exportData() const
{
    return p->data.toList();
}

QList<int> SetObject::exportIntData() const
{
    QList<int> res;
    foreach( const QString & str, p->data )
        res << str.toInt();

    return res;
}

void SetObject::importData(const QStringList &data)
{
    p->data = data.toSet();
}

void SetObject::appendData(const QStringList &data)
{
    p->data.unite( data.toSet() );
}

SetObject::~SetObject()
{
    delete p;
}
