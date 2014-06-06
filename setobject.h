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

#ifndef SETOBJECT_H
#define SETOBJECT_H

#include <QObject>
#include <QStringList>

class SetObjectPrivate;
class SetObject : public QObject
{
    Q_OBJECT
public:
    SetObject(QObject *parent = 0);
    ~SetObject();

public slots:
    void insert(const QString &str );
    void remove(const QString &str );
    bool contains(const QString &str );

    QStringList exportData() const;
    QList<int> exportIntData() const;
    void importData(const QStringList & data);
    void appendData(const QStringList & data);

private:
    SetObjectPrivate *p;
};

#endif // SETOBJECT_H
