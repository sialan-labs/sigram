#ifndef ASEMANKDEWALLET_H
#define ASEMANKDEWALLET_H

#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <QByteArray>

class AsemanKdeWalletPrivate;
class AsemanKdeWallet : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availableWallets READ availableWallets NOTIFY availableWalletsChanged)
    Q_PROPERTY(bool opened READ opened NOTIFY openedChanged)
    Q_PROPERTY(QString wallet READ wallet WRITE setWallet NOTIFY walletChanged)
    Q_PROPERTY(QStringList folderList READ folderList NOTIFY folderListChanged)

public:
    AsemanKdeWallet(QObject *parent = 0);
    ~AsemanKdeWallet();

    QStringList availableWallets() const;
    QStringList folderList() const;

    void setWallet(const QString &wallet);
    QString wallet() const;

    bool opened() const;

public slots:
    bool createFolder(const QString &name);
    bool removeFolder(const QString &name);
    QByteArray readEntry(const QString &folder, const QString &key);
    QVariantMap readEntryList(const QString &folder, const QString &key);
    QByteArray readMap(const QString &folder, const QString &key);
    QVariantMap readMapList(const QString &folder, const QString &key);
    QString readPassword(const QString &folder, const QString &key);
    QVariantMap readPasswordList(const QString &folder, const QString &key);
    int removeEntry(const QString &folder, const QString &key);
    int renameEntry(const QString &folder, const QString &oldName, const QString &newName);
    int writeEntry(const QString &folder, const QString &key, const QByteArray &value);
    int writeEntry(const QString &folder, const QString &key, const QByteArray &value, int entryType);
    int writeMap(const QString &folder, const QString &key, const QByteArray &value);
    int writePassword(const QString &folder, const QString &key, const QString &value);
    bool hasEntry(const QString &folder, const QString &key);
    bool hasFolder(const QString &folder);

    bool open();
    bool close();

signals:
    void availableWalletsChanged();
    void folderListChanged();
    void openedChanged();
    void walletChanged();

private slots:
    void fetchWalletsList();
    void fetchFolderList();

private:
    AsemanKdeWalletPrivate *p;
};

#endif // ASEMANKDEWALLET_H
