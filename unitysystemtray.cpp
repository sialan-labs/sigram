#define LIB_PATH QCoreApplication::applicationDirPath() + "/plugins/UnitySystemTray"
#include "unitysystemtray.h"

#include <QCoreApplication>
#include <QLibrary>

typedef void* (*CreateObjectPrototype)(const QString & name, const QString & icon);
typedef void (*AddMenuPrototype)(void *pntr, const QString & text, QObject *obj, const char *member);

class UnitySystemTrayPrivate
{
public:
    CreateObjectPrototype createObject;
    AddMenuPrototype addMenu;

    void *pntr;
};

UnitySystemTray::UnitySystemTray(const QString & name, const QString & icon)
{
    p = new UnitySystemTrayPrivate;
    p->pntr = 0;

    p->createObject = (CreateObjectPrototype) QLibrary::resolve(LIB_PATH, "createObject");
    p->addMenu = (AddMenuPrototype) QLibrary::resolve(LIB_PATH, "addMenu");

    if( p->createObject )
        p->pntr = p->createObject(name, icon);
}

void UnitySystemTray::addMenu( const QString & text, QObject *obj, const char *member )
{
    if( !p->pntr )
        return;

    p->addMenu( p->pntr, text, obj, member );
}

UnitySystemTray::~UnitySystemTray()
{
    delete p;
}
