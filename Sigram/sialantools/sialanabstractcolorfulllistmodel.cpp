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

#include "sialanabstractcolorfulllistmodel.h"

SialanAbstractColorfullListModel::SialanAbstractColorfullListModel(QObject *parent) :
    QAbstractListModel(parent)
{
    qRegisterMetaType<SialanColorfullListItem*>("SialanColorfullListItem*");
}

QHash<qint32, QByteArray> SialanAbstractColorfullListModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( TitleRole    , "title"     );
    res->insert( ColorRole    , "color"     );
    res->insert( IsHeaderRole , "isHeader"  );
    res->insert( ModelItemRole, "modelItem" );

    return *res;
}

SialanAbstractColorfullListModel::~SialanAbstractColorfullListModel()
{
}


class SialanColorfullListItemPrivate
{
public:
    QString title;
    QColor color;
    bool isHeader;
};

SialanColorfullListItem::SialanColorfullListItem(QObject *parent) :
    QObject(parent)
{
    p = new SialanColorfullListItemPrivate;
    p->isHeader = false;
}

void SialanColorfullListItem::setTitle(const QString &title)
{
    if( p->title == title )
        return;

    p->title = title;
    emit titleChanged();
}

QString SialanColorfullListItem::title() const
{
    return p->title;
}

void SialanColorfullListItem::setColor(const QColor &color)
{
    if( p->color == color )
        return;

    p->color = color;
    emit colorChanged();
}

QColor SialanColorfullListItem::color() const
{
    return p->color;
}

void SialanColorfullListItem::setIsHeader(bool header)
{
    if( p->isHeader == header )
        return;

    p->isHeader = header;
    emit isHeaderChanged();
}

bool SialanColorfullListItem::isHeader() const
{
    return p->isHeader;
}

SialanColorfullListItem::~SialanColorfullListItem()
{
    delete p;
}
