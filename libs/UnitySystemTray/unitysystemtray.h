#ifndef UNITYSYSTEMTRAY_H
#define UNITYSYSTEMTRAY_H

#include <QString>
#include <QHash>
#include "unitysystemtray_global.h"

class QObject;
class UnitySystemTrayPrivate;
class UNITYSYSTEMTRAYSHARED_EXPORT UnitySystemTray
{
public:
    UnitySystemTray( const QString & name, const QString & icon );
    ~UnitySystemTray();

    void addMenu( const QString & text, QObject *obj, const char *member );
    void setIcon( const QString & icon );

    QHash<void*,QPair<QObject*,QString> > items() const;

private:
    UnitySystemTrayPrivate *p;
};

#endif // UNITYSYSTEMTRAY_H
