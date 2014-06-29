/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef QMLSTATICOBJECTHANDLER_H
#define QMLSTATICOBJECTHANDLER_H

#include <QObject>

class QmlStaticObjectHandlerPrivate;
class QmlStaticObjectHandler : public QObject
{
    Q_PROPERTY(QString createMethod READ createMethod WRITE setCreateMethod NOTIFY createMethodChanged)
    Q_PROPERTY(QObject* createObject READ createObject WRITE setCreateObject NOTIFY createObjectChanged)
    Q_OBJECT
public:
    QmlStaticObjectHandler(QObject *parent = 0);
    ~QmlStaticObjectHandler();

    void setCreateMethod( const QString & m );
    QString createMethod() const;

    void setCreateObject( QObject *obj );
    QObject *createObject() const;

public slots:
    QObject *newObject();
    void freeObject( QObject *obj );

signals:
    void createMethodChanged();
    void createObjectChanged();

private slots:
    void object_destroyed( QObject *obj );

private:
    QmlStaticObjectHandlerPrivate *p;
};

#endif // QMLSTATICOBJECTHANDLER_H
