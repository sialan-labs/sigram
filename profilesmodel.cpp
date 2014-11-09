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

#include "profilesmodel.h"
#include "sigram_macros.h"
#include "sialantools/sialandevices.h"
#include "sialantools/sialanapplication.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QFile>
#include <QSettings>
#include <QDebug>

class ProfilesModelPrivate
{
public:
    QSqlDatabase db;
    QString path;

    QHash<QString,ProfilesModelItem*> data;
    QList<QString> numbers;
};

ProfilesModel::ProfilesModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new ProfilesModelPrivate;
    p->path = SialanApplication::homePath()  + "/profiles.sqlite";

    if( !SialanApplication::settings()->value("initialize/profiles_db",false).toBool() )
        QFile::copy(PROFILES_DB_PATH,p->path);

    SialanApplication::settings()->setValue("initialize/profiles_db",true);
    QFile(p->path).setPermissions(QFile::WriteOwner|QFile::WriteGroup|QFile::ReadUser|QFile::ReadGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE",PROFILES_DB_CONNECTION);
    p->db.setDatabaseName(p->path);
    p->db.open();

    init_buffer();
}

QString ProfilesModel::id(const QModelIndex &index) const
{
    int row = index.row();
    return p->numbers.at(row);
}

int ProfilesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return p->numbers.count();
}

QVariant ProfilesModel::data(const QModelIndex &index, int role) const
{
    QVariant res;
    const QString & key = id(index);
    switch( role )
    {
    case NumberRole:
        res = p->data[key]->number();
        break;

    case Qt::DisplayRole:
    case NameRole:
        res = p->data[key]->name();
        break;

    case IconRole:
        res = p->data[key]->icon();
        break;

    case MuteRole:
        res = p->data[key]->mute();
        break;

    case ItemRole:
        res = QVariant::fromValue<ProfilesModelItem*>(p->data[key]);
        break;
    }

    return res;
}

bool ProfilesModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    const QString & key = id(index);
    switch( role )
    {
    case NumberRole:
    case ItemRole:
        return false;
        break;

    case Qt::DisplayRole:
    case NameRole:
        p->data[key]->setName(value.toString());
        return true;
        break;

    case IconRole:
        p->data[key]->setIcon(value.toString());
        return true;
        break;

    case MuteRole:
        p->data[key]->setMute(value.toBool());
        return true;
        break;
    }

    return false;
}

QHash<qint32, QByteArray> ProfilesModel::roleNames() const
{
    QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( NumberRole, "number");
    res->insert( NameRole, "name");
    res->insert( IconRole, "icon");
    res->insert( MuteRole, "mute");
    res->insert( ItemRole, "item");

    return *res;
}

Qt::ItemFlags ProfilesModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index)
    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

int ProfilesModel::count() const
{
    return p->numbers.count();
}

QStringList ProfilesModel::keys() const
{
    return p->numbers;
}

ProfilesModelItem *ProfilesModel::add(const QString &number)
{
    if( p->data.contains(number) )
        return 0;

    beginInsertRows(QModelIndex(),count(),count());

    ProfilesModelItem *item = new ProfilesModelItem(number, this);
    item->setNumber(number);

    p->data[number] = item;
    p->numbers.append(number);

    emit countChanged();
    emit keysChanged();

    save(number);
    endInsertRows();

    return item;
}

bool ProfilesModel::remove(const QString &number)
{
    if( p->data.contains(number) )
        return false;

    const int row = p->numbers.indexOf(number);
    beginRemoveRows(QModelIndex(),row,row);

    p->numbers.removeOne(number);
    ProfilesModelItem *item = p->data.take(number);
    item->deleteLater();

    emit countChanged();
    emit keysChanged();

    endRemoveRows();

    QSqlQuery query(p->db);
    query.prepare("DELETE FROM profiles WHERE number=:number");
    query.bindValue(":number", number);
    query.exec();

    return true;
}

bool ProfilesModel::containt(const QString &number)
{
    return p->data.contains(number);
}

ProfilesModelItem *ProfilesModel::get(const QString &number)
{
    return p->data.value(number);
}

void ProfilesModel::init_buffer()
{
    QSqlQuery profiles_query(p->db);
    profiles_query.prepare("SELECT number, name, icon, mute FROM profiles");
    profiles_query.exec();

    while( profiles_query.next() )
    {
        const QSqlRecord & record = profiles_query.record();

        beginInsertRows(QModelIndex(),count(),count());

        const QString & key = record.value(0).toString();
        ProfilesModelItem *item = new ProfilesModelItem(key, this);
        item->setNumber(key);
        item->setName( record.value(1).toString() );
        item->setIcon( record.value(2).toString() );
        item->setMute( record.value(3).toBool() );

        p->data[key] = item;
        p->numbers.append(key);
        endInsertRows();
    }

    emit countChanged();
    emit keysChanged();
}

void ProfilesModel::save(const QString &key)
{
    ProfilesModelItem *item = p->data.value(key);
    if( !item )
        return;

    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO profiles (number,name,icon,mute) VALUES (:nmbr,:name,:icon,:mute)");
    query.bindValue(":nmbr", item->number());
    query.bindValue(":name", item->name());
    query.bindValue(":icon", item->icon());
    query.bindValue(":mute", item->mute());
    query.exec();
}

ProfilesModel::~ProfilesModel()
{
    delete p;
}


class ProfilesModelItemPrivate
{
public:
    ProfilesModel *model;
    QString key;

    QString number;
    QString name;
    QString icon;
    bool mute;
};

ProfilesModelItem::ProfilesModelItem(const QString &key, ProfilesModel *parent) :
    QObject(parent)
{
    p = new ProfilesModelItemPrivate;
    p->mute = false;
    p->model = parent;
    p->key = key;
}

QString ProfilesModelItem::number() const
{
    return p->number;
}

void ProfilesModelItem::setNumber(const QString &number)
{
    if( number == p->number )
        return;

    p->number = number;
    save();
    emit numberChanged();
}

QString ProfilesModelItem::name() const
{
    return p->name;
}

void ProfilesModelItem::setName(const QString &name)
{
    if( name == p->name )
        return;

    p->name = name;
    save();
    emit nameChanged();
}

QString ProfilesModelItem::icon() const
{
    return p->icon;
}

void ProfilesModelItem::setIcon(const QString &icon)
{
    if( icon == p->icon )
        return;

    p->icon = icon;
    save();
    emit iconChanged();
}

bool ProfilesModelItem::mute() const
{
    return p->mute;
}

void ProfilesModelItem::setMute(bool mute)
{
    if( mute == p->mute )
        return;

    p->mute = mute;
    save();
    emit muteChanged();
}

void ProfilesModelItem::save()
{
    QMetaObject::invokeMethod( p->model, "save", Qt::QueuedConnection, Q_ARG(QString,p->key) );
}

ProfilesModelItem::~ProfilesModelItem()
{
    delete p;
}
