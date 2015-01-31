#ifndef DATABASECORE_H
#define DATABASECORE_H

#include <QObject>
#include <types/types.h>

class DbChat { public: DbChat(): chat(Chat::typeChatEmpty){} Chat chat; };
class DbUser { public: DbUser(): user(User::typeUserEmpty){} User user; };
class DbDialog { public: DbDialog(): dialog(){} Dialog dialog; };
class DbMessage { public: DbMessage(): message(){} Message message; };
class DbPeer { public: DbPeer(): peer(Peer::typePeerUser){} Peer peer; };

class DatabaseCorePrivate;
class DatabaseCore : public QObject
{
    Q_OBJECT
public:
    DatabaseCore(const QString &path, const QString &phoneNumber, QObject *parent = 0);
    ~DatabaseCore();

public slots:
    void reconnect();
    void disconnect();

    void insertUser(const DbUser &user);
    void insertChat(const DbChat &chat);
    void insertDialog(const DbDialog &dialog, bool encrypted);
    void insertMessage(const DbMessage &message);

    void readFullDialogs();
    void readMessages(const DbPeer &peer, int offset, int limit);

    void setValue(const QString &key, const QString &value);
    QString value(const QString &key) const;

    void deleteMessage(qint64 msgId);
    void deleteDialog(qint64 dlgId);
    void deleteHistory(qint64 dlgId);

signals:
    void userFounded(const DbUser &user);
    void chatFounded(const DbChat &chat);
    void dialogFounded(const DbDialog &dialog, bool encrypted);
    void messageFounded(const DbMessage &message);
    void valueChanged(const QString &value);

private:
    void readDialogs();
    void readUsers();
    void readChats();

    void init_buffer();
    void update_db();
    void update_moveFiles();
    QHash<qint64, QStringList> userFiles();
    QHash<qint64, QStringList> userFilesOf(const QString &mediaColumn);
    QHash<qint64, QStringList> userPhotos();
    QHash<qint64, QStringList> userProfilePhotosOf(const QString &table);

    QList<qint32> stringToUsers(const QString &str);
    QString usersToString( const QList<qint32> &users );

    void insertAudio(const Audio &audio);
    void insertVideo(const Video &video);
    void insertDocument(const Document &document);
    void insertGeo(int id, const GeoPoint &geo);
    void insertPhoto(const Photo &photo);
    void insertPhotoSize(qint64 pid, const QList<PhotoSize> &sizes);

    Audio readAudio(qint64 id);
    Video readVideo(qint64 id);
    Document readDocument(qint64 id);
    GeoPoint readGeo(qint64 id);
    Photo readPhoto(qint64 id);
    QList<PhotoSize> readPhotoSize(qint64 pid);

    void begin();
    void commit();

protected:
    void timerEvent(QTimerEvent *e);

private:
    DatabaseCorePrivate *p;
};

Q_DECLARE_METATYPE(DbUser)
Q_DECLARE_METATYPE(DbChat)
Q_DECLARE_METATYPE(DbDialog)
Q_DECLARE_METATYPE(DbMessage)
Q_DECLARE_METATYPE(DbPeer)

#endif // DATABASECORE_H
