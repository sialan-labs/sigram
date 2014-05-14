#ifndef TELEGRAM_H
#define TELEGRAM_H

#include <QObject>
#include <QStringList>
#include <QDateTime>

#include "telegram/strcuts.h"

class TelegramPrivate;
class Telegram : public QObject
{
    Q_OBJECT
public:
    Telegram(int argc, char **argv, QObject *parent = 0);
    ~Telegram();

    Q_INVOKABLE QList<int> contactListUsers() const;
    UserClass contact(int id ) const;
    Q_INVOKABLE QString contactFirstName(int id) const;
    Q_INVOKABLE QString contactLastName(int id) const;
    Q_INVOKABLE QString contactPhone(int id) const;
    Q_INVOKABLE qint64 contactUid(int id) const;
    Q_INVOKABLE qint64 contactPhotoId(int id) const;
    Q_INVOKABLE TgStruncts::OnlineState contactState(int id) const;
    Q_INVOKABLE QDateTime contactLastTime(int id) const;
    Q_INVOKABLE QString contactTitle(int id);

    Q_INVOKABLE QList<int> dialogListIds() const;
    DialogClass dialog( int id ) const;
    Q_INVOKABLE bool dialogIsChat( int id ) const;
    Q_INVOKABLE QString dialogChatTitle( int id ) const;
    Q_INVOKABLE QString dialogUserName( int id ) const;
    Q_INVOKABLE QString dialogTitle( int id ) const;

public slots:
    void updateContactList();
    void updateDialogList();

    void getHistory( const QString & user, int count );

signals:
    void contactsChanged();
    void dialogsChanged();
    void started();

private:
    TelegramPrivate *p;
};

#endif // TELEGRAM_H
