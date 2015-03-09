#ifndef ASEMANQUICKOBJECT_H
#define ASEMANQUICKOBJECT_H

#include <QObject>
#include <QQmlListProperty>

class AsemanQuickObjectPrivate;
class AsemanQuickObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<QObject> items READ items NOTIFY itemsChanged)
    Q_CLASSINFO("DefaultProperty", "items")

public:
    AsemanQuickObject(QObject *parent = 0);
    ~AsemanQuickObject();

    QQmlListProperty<QObject> items();

signals:
    void itemsChanged();

private:
    static void append(QQmlListProperty<QObject> *p, QObject *v);
    static int count(QQmlListProperty<QObject> *p);
    static QObject *at(QQmlListProperty<QObject> *p, int idx);
    static void clear(QQmlListProperty<QObject> *p);

private:
    AsemanQuickObjectPrivate *p;
};

#endif // ASEMANQUICKOBJECT_H
