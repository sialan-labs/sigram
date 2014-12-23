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

#ifndef PROFILES_H
#define PROFILES_H

#include <QAbstractItemModel>
#include <QStringList>

class ProfilesModelPrivate;
class ProfilesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QStringList keys READ keys NOTIFY keysChanged)

    friend class ProfilesModelItem;

public:
    enum ProfilesRoles {
        NumberRole = Qt::UserRole,
        NameRole,
        IconRole,
        MuteRole,
        ItemRole
    };

    ProfilesModel(QObject *parent = 0);
    ~ProfilesModel();

    QString id( const QModelIndex &index ) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex & index, const QVariant & value, int role = Qt::EditRole);

    QHash<qint32,QByteArray> roleNames() const;
    Qt::ItemFlags flags(const QModelIndex &index) const;

    int count() const;
    QStringList keys() const;

public slots:
    class ProfilesModelItem *add( const QString & number );
    bool remove( const QString & number );
    bool containt( const QString & number );

    ProfilesModelItem *get( const QString & number );

signals:
    void countChanged();
    void keysChanged();

private slots:
    void save( const QString & key );

private:
    void init_buffer();

private:
    ProfilesModelPrivate *p;
};


class ProfilesModelItemPrivate;
class ProfilesModelItem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString number READ number NOTIFY numberChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(bool mute READ mute WRITE setMute NOTIFY muteChanged)

public:
    ProfilesModelItem(const QString & key = QString(), ProfilesModel *parent = 0);
    ~ProfilesModelItem();

    QString number() const;
    void setNumber( const QString & number );

    QString name() const;
    void setName( const QString & name );

    QString icon() const;
    void setIcon( const QString & icon );

    bool mute() const;
    void setMute( bool stt );

signals:
    void numberChanged();
    void nameChanged();
    void iconChanged();
    void muteChanged();

private:
    void save();

private:
    ProfilesModelItemPrivate *p;
};

#endif // PROFILES_H
