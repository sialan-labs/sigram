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

#ifndef ASEMANABSTRACTCOLORFULLLISTMODEL_H
#define ASEMANABSTRACTCOLORFULLLISTMODEL_H

#include <QAbstractListModel>
#include <QColor>

class AsemanAbstractColorfullListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ColorfullListModelRoles {
        TitleRole = Qt::UserRole,
        ColorRole,
        IsHeaderRole,
        ModelItemRole,
        EndColorfullListModelRoles
    };

    AsemanAbstractColorfullListModel(QObject *parent = 0);
    ~AsemanAbstractColorfullListModel();

    virtual QHash<qint32,QByteArray> roleNames() const;
    virtual int count() const = 0;

public slots:
    virtual class AsemanColorfullListItem *get( int row ) = 0;

signals:
    void countChanged();
};


class AsemanColorfullListItem: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString title    READ title    NOTIFY titleChanged   )
    Q_PROPERTY(QColor  color    READ color    NOTIFY colorChanged   )
    Q_PROPERTY(bool    isHeader READ isHeader NOTIFY isHeaderChanged)

public:
    AsemanColorfullListItem( QObject *parent = 0 );
    ~AsemanColorfullListItem();

    void setTitle( const QString & title );
    QString title() const;

    void setColor( const QColor & color );
    QColor color() const;

    void setIsHeader( bool header );
    bool isHeader() const;

signals:
    void titleChanged();
    void colorChanged();
    void isHeaderChanged();

private:
    class AsemanColorfullListItemPrivate *p;
};

Q_DECLARE_METATYPE(AsemanColorfullListItem*)

#endif // ASEMANABSTRACTCOLORFULLLISTMODEL_H
