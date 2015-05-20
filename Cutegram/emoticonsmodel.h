#ifndef EMOTICONSMODEL_H
#define EMOTICONSMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QUrl>

#include "emojis.h"

class EmoticonsModelPrivate;
class EmoticonsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(EmoticonType)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(Emojis* emojis READ emojis WRITE setEmojis NOTIFY emojisChanged)
    Q_PROPERTY(QList<QUrl> stickerSubPaths READ stickerSubPaths WRITE setStickerSubPaths NOTIFY stickerSubPathsChanged)
    Q_PROPERTY(QStringList keys READ keys NOTIFY keysChanged)
    Q_PROPERTY(QString currentKey READ currentKey WRITE setCurrentKey NOTIFY currentKeyChanged)
    Q_PROPERTY(int currentKeyIndex READ currentKeyIndex NOTIFY currentKeyIndexChanged)
    Q_PROPERTY(QStringList recentKeys READ recentKeys NOTIFY recentKeysChanged)

public:
    enum FileRoles {
        KeyRole = Qt::UserRole,
        TypeRole,
        PathRole
    };

    enum EmoticonType {
        EmoticonEmoji,
        EmoticonSticker
    };

    EmoticonsModel(QObject *parent = 0);
    ~EmoticonsModel();

    void setEmojis(Emojis *emojis);
    Emojis *emojis() const;

    void setStickerSubPaths(const QList<QUrl> &subpaths);
    QList<QUrl> stickerSubPaths() const;

    QStringList keys() const;
    QStringList recentKeys() const;

    void setCurrentKey(const QString &key);
    QString currentKey() const;
    int currentKeyIndex() const;

    QString id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

public slots:
    void refresh();
    void pushToRecent(const QString &key);

signals:
    void countChanged();
    void emojisChanged();
    void stickerSubPathsChanged();
    void keysChanged();
    void currentKeyChanged();
    void currentKeyIndexChanged();
    void recentKeysChanged();

private:
    void refreshKeys();
    void changed(const QStringList &list);

private:
    EmoticonsModelPrivate *p;
};

#endif // EMOTICONSMODEL_H
