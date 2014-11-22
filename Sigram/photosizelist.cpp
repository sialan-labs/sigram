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

#include "photosizelist.h"
#include "objects/types.h"

class PhotoSizeListPrivate
{
public:
    QList<PhotoSizeObject*> list;
};

PhotoSizeList::PhotoSizeList(QObject *parent) :
    QObject(parent)
{
    p = new PhotoSizeListPrivate;
}

PhotoSizeList::PhotoSizeList(const QList<PhotoSize> & another, QObject *parent) :
    QObject(parent)
{
    p = new PhotoSizeListPrivate;
    operator =(another);
}

void PhotoSizeList::operator =(const QList<PhotoSize> &another)
{
    foreach( const PhotoSize & size, another )
    {
        bool containt = false;
        for( int i=0; i<p->list.count(); i++ )
        {
            PhotoSizeObject *tmp = p->list.at(i);
            if( tmp->location()->localId() != size.location().localId() ||
                tmp->location()->dcId() != size.location().dcId() ||
                tmp->location()->volumeId() != size.location().volumeId() ||
                tmp->location()->secret() != size.location().secret() )
                continue;

            containt = true;
            break;
        }
        if( containt )
            continue;

        PhotoSizeObject *obj = new PhotoSizeObject(size, this);
        p->list << obj;
    }

    emit firstChanged();
    emit lastChanged();
    emit countChanged();
}

PhotoSizeObject *PhotoSizeList::first() const
{
    if( p->list.isEmpty() )
        return 0;

    return p->list.first();
}

PhotoSizeObject *PhotoSizeList::last() const
{
    if( p->list.isEmpty() )
        return 0;

    return p->list.last();
}

int PhotoSizeList::count() const
{
    return p->list.count();
}

PhotoSizeObject *PhotoSizeList::at(int idx)
{
    return p->list.at(idx);
}

PhotoSizeList::~PhotoSizeList()
{
    delete p;
}
