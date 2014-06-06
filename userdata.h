#ifndef USERDATA_H
#define USERDATA_H

#include <QObject>

class UserDataPrivate;
class UserData : public QObject
{
    Q_OBJECT
public:
    UserData(QObject *parent = 0);
    ~UserData();

    void addMute( int id );
    void removeMute( int id );
    QList<int> mutes() const;
    bool isMuted(int id);

public slots:
    void reconnect();
    void disconnect();

private:
    void init_buffer();

private:
    UserDataPrivate *p;
};

#endif // USERDATA_H
