/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
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

#include "asemancountriesmodel.h"

#include <QFile>
#include <QStringList>
#include <QHash>
#include <QDebug>

class AsemanCountriesModelPrivate
{
public:
    QMap<QString, QHash<QString,QString> > data;
    QList<QString> list;
};

AsemanCountriesModel::AsemanCountriesModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new AsemanCountriesModelPrivate;
    init_buff();
}

QString AsemanCountriesModel::id(const QModelIndex &index) const
{
    int row = index.row();
    return p->list.at(row);
}

int AsemanCountriesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->list.count();
}

QVariant AsemanCountriesModel::data(const QModelIndex &index, int role) const
{
    QVariant res;
    const QString & key = id(index);
    switch( role )
    {
    case Qt::DisplayRole:
    case NameRole:
        res = p->data[key]["name"];
        break;

    case NativeNameRole:
        res = p->data[key]["nativeName"];
        break;

    case TldRole:
        res = p->data[key]["tld"];
        break;

    case Cca2Role:
        res = p->data[key]["cca2"];
        break;

    case Ccn3Role:
        res = p->data[key]["ccn3"];
        break;

    case Cca3Role:
        res = p->data[key]["cca3"];
        break;

    case CurrencyRole:
        res = p->data[key]["currency"];
        break;

    case CallingCodeRole:
        res = p->data[key]["callingCode"];
        break;

    case CapitalRole:
        res = p->data[key]["capital"];
        break;

    case AltSpellingsRole:
        res = p->data[key]["altSpellings"];
        break;

    case RelevanceRole:
        res = p->data[key]["relevance"];
        break;

    case RegionRole:
        res = p->data[key]["region"];
        break;

    case SubregionRole:
        res = p->data[key]["subregion"];
        break;

    case LanguageRole:
        res = p->data[key]["language"];
        break;

    case LanguageCodesRole:
        res = p->data[key]["languageCodes"];
        break;

    case TranslationsRole:
        res = p->data[key]["translations"];
        break;

    case LatlngRole:
        res = p->data[key]["latlng"];
        break;

    case DemonymRole:
        res = p->data[key]["demonym"];
        break;

    case BordersRole:
        res = p->data[key]["borders"];
        break;

    case AreaRole:
        res = p->data[key]["area"];
        break;
    }

    return res;
}

QHash<qint32, QByteArray> AsemanCountriesModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( NameRole, "name");
    res->insert( NativeNameRole, "nativeName");
    res->insert( TldRole, "tld");
    res->insert( Cca2Role, "cca2");
    res->insert( Ccn3Role, "ccn3");
    res->insert( Cca3Role, "cca3");
    res->insert( CurrencyRole, "currency");
    res->insert( CallingCodeRole, "callingCode");
    res->insert( CapitalRole, "capital");
    res->insert( AltSpellingsRole, "altSpellings");
    res->insert( RelevanceRole, "relevance");
    res->insert( RegionRole, "region");
    res->insert( SubregionRole, "subregion");
    res->insert( LanguageRole, "language");
    res->insert( LanguageCodesRole, "languageCodes");
    res->insert( TranslationsRole, "translations");
    res->insert( LatlngRole, "latlng");
    res->insert( DemonymRole, "demonym");
    res->insert( BordersRole, "borders");
    res->insert( AreaRole, "area");

    return *res;
}

int AsemanCountriesModel::count() const
{
    return p->list.count();
}

void AsemanCountriesModel::init_buff()
{
    QFile file(":/asemantools/files/countries.csv");
    if( !file.open(QFile::ReadOnly) )
        return;

    QString data = file.readAll();
    QStringList splits = data.split("\n",QString::SkipEmptyParts);
    if( splits.isEmpty() )
        return;

    QStringList heads = splits.takeFirst().split(";");

    foreach( const QString & s, splits )
    {
        const QStringList & parts = s.split(";");
        for( int i=0; i<parts.count(); i++ )
        {
            const QString & prt = parts.at(i);
            p->data[parts.first().toLower()][heads.at(i)] = prt.split(",").first();
        }
    }

    p->list = p->data.keys();
    emit countChanged();
}

AsemanCountriesModel::~AsemanCountriesModel()
{
    delete p;
}
