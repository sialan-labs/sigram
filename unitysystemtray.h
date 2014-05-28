#ifndef UNITYSYSTEMTRAY_H
#define UNITYSYSTEMTRAY_H

#include <QString>
#include <QHash>

class QObject;
class UnitySystemTrayPrivate;
class UnitySystemTray
{
public:
    UnitySystemTray( const QString & name, const QString & icon );
    ~UnitySystemTray();

    void addMenu( const QString & text, QObject *obj, const char *member );

    QHash<void*,QPair<QObject*,QString> > items() const;

private:
    UnitySystemTrayPrivate *p;
};

#endif // UNITYSYSTEMTRAY_H
