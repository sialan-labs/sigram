#ifndef ASEMANABSTRACTLISTMODEL_H
#define ASEMANABSTRACTLISTMODEL_H

#include <QAbstractListModel>
#include <QStringList>

class AsemanAbstractListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    AsemanAbstractListModel(QObject *parent = 0);
    virtual ~AsemanAbstractListModel();

    Q_INVOKABLE QStringList roles() const;

public Q_SLOTS:
    QVariant get(int index, int role) const;
    QVariant get(int index, const QString &roleName) const;
    QVariantMap get(int index) const;
};

#endif // ASEMANABSTRACTLISTMODEL_H
