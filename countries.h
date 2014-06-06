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

#ifndef COUNTRIES_H
#define COUNTRIES_H

#include <QObject>
#include <QStringList>

class CountriesPrivate;
class Countries : public QObject
{
    Q_OBJECT
public:
    Countries(QObject *parent = 0);
    ~Countries();

public slots:
    QStringList countries();
    QString phoneCode( const QString & country );
    QString countryFlag( const QString & country );

private:
    void init_buff();

private:
    CountriesPrivate *p;
};

#endif // COUNTRIES_H
