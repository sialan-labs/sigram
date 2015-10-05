#ifndef CONTRIBUTORSMODEL_H
#define CONTRIBUTORSMODEL_H

#include "asemantools/asemanabstractlistmodel.h"
#include <QList>
#include <QUrl>

class ContributorsModelItem;
class ContributorsModelPrivate;
class ContributorsModel : public AsemanAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(ItemRoles)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QList<QUrl> files READ files WRITE setFiles NOTIFY filesChanged)

public:
    enum ItemRoles {
        TextRole = Qt::UserRole,
        LinkRole,
        TypeRole
    };

    ContributorsModel(QObject *parent = 0);
    ~ContributorsModel();

    void setFiles(const QList<QUrl> & urls);
    QList<QUrl> files() const;

    int id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

public slots:
    void refresh();

signals:
    void countChanged();
    void filesChanged();

private:
    QList<ContributorsModelItem> readData() const;

private:
    ContributorsModelPrivate *p;
};

#endif // CONTRIBUTORSMODEL_H
