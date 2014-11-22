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

#ifndef SIALANCOUNTRIESMODEL_H
#define SIALANCOUNTRIESMODEL_H

#include <QObject>
#include <QStringList>
#include <QAbstractListModel>

class SialanCountriesModelPrivate;
class SialanCountriesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ColorfullListModelRoles {
        NameRole = Qt::UserRole,
        NativeNameRole,
        TldRole,
        Cca2Role,
        Ccn3Role,
        Cca3Role,
        CurrencyRole,
        CallingCodeRole,
        CapitalRole,
        AltSpellingsRole,
        RelevanceRole,
        RegionRole,
        SubregionRole,
        LanguageRole,
        LanguageCodesRole,
        TranslationsRole,
        LatlngRole,
        DemonymRole,
        BordersRole,
        AreaRole
    };

    SialanCountriesModel(QObject *parent = 0);
    ~SialanCountriesModel();

    QString id( const QModelIndex &index ) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;
    int count() const;

signals:
    void countChanged();

private:
    void init_buff();

private:
    SialanCountriesModelPrivate *p;
};

#endif // SIALANCOUNTRIESMODEL_H
