/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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

#ifndef PHOTOSIZELIST_H
#define PHOTOSIZELIST_H

#include <QObject>

class PhotoSize;
class PhotoSizeObject;
class PhotoSizeListPrivate;
class PhotoSizeList : public QObject
{
    Q_OBJECT

    Q_PROPERTY(PhotoSizeObject* first READ first NOTIFY firstChanged)
    Q_PROPERTY(PhotoSizeObject* last READ last NOTIFY lastChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    PhotoSizeList(QObject *parent = 0);
    PhotoSizeList(const QList<PhotoSize> & another, QObject *parent = 0);
    ~PhotoSizeList();

    void operator =( const QList<PhotoSize> & another );

    PhotoSizeObject *first() const;
    PhotoSizeObject *last() const;

    int count() const;

public slots:
    PhotoSizeObject *at( int idx );

signals:
    void firstChanged();
    void lastChanged();
    void countChanged();

private:
    PhotoSizeListPrivate *p;
};

Q_DECLARE_METATYPE(PhotoSizeList*)

#endif // PHOTOSIZELIST_H
