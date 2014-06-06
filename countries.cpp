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

#define FILE_PATH QString(QCoreApplication::applicationDirPath() + "/countries/countries.csv")
#define FLAGS_PATH QString(QCoreApplication::applicationDirPath() + "/countries/flags/")

#include "countries.h"

#include <QCoreApplication>
#include <QFile>
#include <QStringList>
#include <QHash>
#include <QDebug>

class CountriesPrivate
{
public:
    QHash<QString, QHash<QString,QString> > data;
    bool inited;
};

Countries::Countries(QObject *parent) :
    QObject(parent)
{
    p = new CountriesPrivate;
    p->inited = false;
}

QStringList Countries::countries()
{
    init_buff();
    QStringList res = p->data.keys();
    res.sort();
    return res;
}

QString Countries::phoneCode(const QString &country)
{
    init_buff();
    return p->data[country]["callingCode"];
}

QString Countries::countryFlag(const QString &country)
{
    init_buff();
    return FLAGS_PATH + p->data[country]["cca2"].toLower() + ".png";
}

void Countries::init_buff()
{
    if( p->inited )
        return;

    QFile file(FILE_PATH);
    if( !file.open(QFile::ReadOnly) )
        return;

    QString data = file.readAll();
    QStringList splits = data.split("\n",QString::SkipEmptyParts);
    if( splits.isEmpty() )
        return;

    QStringList heads = splits.takeFirst().split(";",QString::SkipEmptyParts);

    foreach( const QString & s, splits )
    {
        const QStringList & parts = s.split(";",QString::SkipEmptyParts);
        for( int i=0; i<parts.count(); i++ )
        {
            const QString & prt = parts.at(i);
            p->data[parts.first()][heads.at(i)] = prt;
        }
    }

    p->inited = true;
}

Countries::~Countries()
{
    delete p;
}
