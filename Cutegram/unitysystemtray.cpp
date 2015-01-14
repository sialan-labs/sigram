/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define LIB_PATH AsemanDevices::libsPath() + "/plugins/UnitySystemTray"

#include "asemantools/asemandevices.h"
#include "unitysystemtray.h"

#include <QCoreApplication>
#include <QLibrary>

typedef void* (*CreateObjectPrototype)(const QString & name, const QString & icon);
typedef void (*AddMenuPrototype)(void *pntr, const QString & text, QObject *obj, const char *member);
typedef void (*SetIconPrototype)(void *pntr, const QString & icon);

class UnitySystemTrayPrivate
{
public:
    CreateObjectPrototype createObject;
    AddMenuPrototype addMenu;
    SetIconPrototype setIcon;

    void *pntr;
};

UnitySystemTray::UnitySystemTray(const QString & name, const QString & icon)
{
    p = new UnitySystemTrayPrivate;
    p->pntr = 0;

    p->createObject = (CreateObjectPrototype) QLibrary::resolve(LIB_PATH, "createObject");
    p->addMenu = (AddMenuPrototype) QLibrary::resolve(LIB_PATH, "addMenu");
    p->setIcon = (SetIconPrototype) QLibrary::resolve(LIB_PATH, "setIcon");

    if( p->createObject )
        p->pntr = p->createObject(name, icon);
}

void UnitySystemTray::addMenu( const QString & text, QObject *obj, const char *member )
{
    if( !p->pntr )
        return;

    p->addMenu( p->pntr, text, obj, member );
}

void UnitySystemTray::setIcon( const QString & icon )
{
    if( !p->pntr )
        return;

    p->setIcon( p->pntr, icon );
}

void *UnitySystemTray::pntr()
{
    return p->pntr;
}

UnitySystemTray::~UnitySystemTray()
{
    delete p;
}
