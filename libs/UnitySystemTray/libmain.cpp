#include "unitysystemtray.h"

extern "C" void *createObject( const QString & name, const QString & icon )
{
    return new UnitySystemTray(name, icon);
}

extern "C" void addMenu( void *pntr, const QString & text, QObject *obj, const char *member )
{
    UnitySystemTray *ust = static_cast<UnitySystemTray*>(pntr);
    ust->addMenu( text, obj, member );
}

extern "C" void setIcon( void *pntr, const QString & icon )
{
    UnitySystemTray *ust = static_cast<UnitySystemTray*>(pntr);
    ust->setIcon( icon );
}
