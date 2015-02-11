#ifndef TELEGRAMSEARCHMODEL_H
#define TELEGRAMSEARCHMODEL_H

#include <QAbstractListModel>

class MessageObject;
class TelegramQml;
class TelegramSearchModelPrivate;
class TelegramSearchModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool initializing READ initializing NOTIFY initializingChanged)
    Q_PROPERTY(QString keyword READ keyword WRITE setKeyword NOTIFY keywordChanged)

public:
    enum DialogsRoles {
        ItemRole = Qt::UserRole
    };

    TelegramSearchModel(QObject *parent = 0);
    ~TelegramSearchModel();

    TelegramQml *telegram() const;
    void setTelegram(TelegramQml *tgo );

    void setKeyword(const QString &kw);
    QString keyword() const;

    qint64 id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;
    bool initializing() const;

public slots:
    void refresh();

signals:
    void telegramChanged();
    void countChanged();
    void initializingChanged();
    void keywordChanged();

private slots:
    void searchDone(const QList<qint64> &messages);

protected:
    void timerEvent(QTimerEvent *e);

private:
    TelegramSearchModelPrivate *p;
};

#endif // TELEGRAMSEARCHMODEL_H
