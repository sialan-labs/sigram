#ifndef USERNAMEFILTERMODEL_H
#define USERNAMEFILTERMODEL_H

#include <QAbstractListModel>

class TelegramQml;
class UserNameFilterModelPrivate;
class UserNameFilterModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(QString keyword READ keyword WRITE setKeyword NOTIFY keywordChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum FilterRoles {
        UserIdRole = Qt::UserRole
    };

    UserNameFilterModel(QObject *parent = 0);
    ~UserNameFilterModel();

    TelegramQml *telegram() const;
    void setTelegram(TelegramQml *tg );

    qint64 id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

    void setKeyword(const QString &keyword);
    QString keyword() const;

signals:
    void telegramChanged();
    void countChanged();
    void keywordChanged();

private slots:
    void listChanged();

private:
    UserNameFilterModelPrivate *p;
};

#endif // USERNAMEFILTERMODEL_H
