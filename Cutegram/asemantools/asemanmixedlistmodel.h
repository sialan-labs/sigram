#ifndef ASEMANMIXEDLISTMODEL_H
#define ASEMANMIXEDLISTMODEL_H

#include "asemanabstractlistmodel.h"

class AsemanMixedListModelPrivate;
class AsemanMixedListModel : public AsemanAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(RolesModelObject)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QVariantList models READ models WRITE setModels NOTIFY modelsChanged)

public:
    enum DataRoles {
        RolesModelObject = Qt::UserRole + 1000000
    };

    AsemanMixedListModel(QObject *parent = 0);
    ~AsemanMixedListModel();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::DisplayRole);

    QHash<qint32,QByteArray> roleNames() const;
    int count() const;

    void setModels(const QVariantList &list);
    QVariantList models() const;

    Qt::ItemFlags flags(const QModelIndex & index) const;
    bool insertColumns(int column, int count, const QModelIndex & parent = QModelIndex());
    bool insertRows(int row, int count, const QModelIndex & parent = QModelIndex());
    bool moveColumns(const QModelIndex & sourceParent, int sourceColumn, int count, const QModelIndex & destinationParent, int destinationChild);
    bool moveRows(const QModelIndex & sourceParent, int sourceRow, int count, const QModelIndex & destinationParent, int destinationChild);
    bool removeColumns(int column, int count, const QModelIndex & parent = QModelIndex());
    bool removeRows(int row, int count, const QModelIndex & parent = QModelIndex());

signals:
    void countChanged();
    void modelsChanged();

private slots:
    void columnsAboutToBeInserted_slt(const QModelIndex & parent, int first, int last);
    void columnsAboutToBeMoved_slt(const QModelIndex & sourceParent, int sourceStart, int sourceEnd, const QModelIndex & destinationParent, int destinationColumn);
    void columnsAboutToBeRemoved_slt(const QModelIndex & parent, int first, int last);
    void columnsInserted_slt(const QModelIndex & parent, int first, int last);
    void columnsMoved_slt(const QModelIndex & parent, int start, int end, const QModelIndex & destination, int column);
    void columnsRemoved_slt(const QModelIndex & parent, int first, int last);
    void dataChanged_slt(const QModelIndex & topLeft, const QModelIndex & bottomRight, const QVector<int> & roles = QVector<int> ());
    void headerDataChanged_slt(Qt::Orientation orientation, int first, int last);
    void layoutAboutToBeChanged_slt(const QList<QPersistentModelIndex> & parents = QList<QPersistentModelIndex> (), QAbstractItemModel::LayoutChangeHint hint = QAbstractItemModel::NoLayoutChangeHint);
    void layoutChanged_slt(const QList<QPersistentModelIndex> & parents = QList<QPersistentModelIndex> (), QAbstractItemModel::LayoutChangeHint hint = QAbstractItemModel::NoLayoutChangeHint);
    void modelAboutToBeReset_slt();
    void modelReset_slt();
    void rowsAboutToBeInserted_slt(const QModelIndex & parent, int start, int end);
    void rowsAboutToBeMoved_slt(const QModelIndex & sourceParent, int sourceStart, int sourceEnd, const QModelIndex & destinationParent, int destinationRow);
    void rowsAboutToBeRemoved_slt(const QModelIndex & parent, int first, int last);
    void rowsInserted_slt(const QModelIndex & parent, int first, int last);
    void rowsMoved_slt(const QModelIndex & parent, int start, int end, const QModelIndex & destination, int row);
    void rowsRemoved_slt(const QModelIndex & parent, int first, int last);
    void modelDestroyed(QObject *obj);
    void reinit_prv();

private:
    void reinit();

protected:
    QModelIndex mapFromModelIndex(QAbstractListModel *model, const QModelIndex &index) const;
    int mapFromModel(QAbstractListModel *model, int row) const;

    QModelIndex mapToModelIndex(QAbstractListModel *model, const QModelIndex &index) const;
    int mapToModel(QAbstractListModel *model, int row) const;

    int modelPad(QAbstractListModel *model) const;

private:
    AsemanMixedListModelPrivate *p;
};

#endif // ASEMANMIXEDLISTMODEL_H
