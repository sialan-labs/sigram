#ifndef TAGFILTERMODEL_H
#define TAGFILTERMODEL_H

#include <QAbstractListModel>

class UserData;
class TagFilterModelPrivate;
class TagFilterModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(UserData* userData READ userData WRITE setUserData NOTIFY userDataChanged)
    Q_PROPERTY(QString keyword READ keyword WRITE setKeyword NOTIFY keywordChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum TagFilterRoles {
        TagRole = Qt::UserRole
    };

    TagFilterModel(QObject *parent = 0);
    ~TagFilterModel();

    void setUserData(UserData *userData);
    UserData *userData() const;

    QString id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

    void setKeyword(const QString &keyword);
    QString keyword() const;

public slots:
    void refresh();
    QString get(int idx);

signals:
    void userDataChanged();
    void countChanged();
    void keywordChanged();

private:
    void listChanged();

private:
    TagFilterModelPrivate *p;
};

#endif // TAGFILTERMODEL_H
