/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef TELEGRAMQML_H
#define TELEGRAMQML_H

#include <QObject>

class Telegram;
class TelegramQmlPrivate;
class TelegramQml : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString phoneNumber   READ phoneNumber   WRITE setPhoneNumber   NOTIFY phoneNumberChanged  )
    Q_PROPERTY(QString configPath    READ configPath    WRITE setConfigPath    NOTIFY configPathChanged   )
    Q_PROPERTY(QString publicKeyFile READ publicKeyFile WRITE setPublicKeyFile NOTIFY publicKeyFileChanged)

    Q_PROPERTY(Telegram* telegram READ telegram NOTIFY telegramChanged)

    Q_PROPERTY(bool authNeeded      READ authNeeded      NOTIFY authNeededChanged     )
    Q_PROPERTY(bool authLoggedIn    READ authLoggedIn    NOTIFY authLoggedInChanged   )
    Q_PROPERTY(bool phoneRegistered READ phoneRegistered NOTIFY phoneRegisteredChanged)
    Q_PROPERTY(bool phoneInvited    READ phoneInvited    NOTIFY phoneInvitedChanged   )
    Q_PROPERTY(bool connected       READ connected       NOTIFY connectedChanged      )

public:
    TelegramQml(QObject *parent = 0);
    ~TelegramQml();

    QString phoneNumber() const;
    void setPhoneNumber( const QString & phone );

    QString configPath() const;
    void setConfigPath( const QString & conf );

    QString publicKeyFile() const;
    void setPublicKeyFile( const QString & file );

    Telegram *telegram() const;

    bool authNeeded() const;
    bool authLoggedIn() const;
    bool phoneRegistered() const;
    bool phoneInvited() const;
    bool connected() const;

public slots:
    void logout();
    void sendCall();
    void sendInvites(const QStringList &phoneNumbers, const QString &inviteText);

    void signIn(const QString &code);
    void signUp(const QString &code, const QString &firstName, const QString &lastName);

signals:
    void phoneNumberChanged();
    void configPathChanged();
    void publicKeyFileChanged();
    void telegramChanged();

    void authNeededChanged();
    void authLoggedInChanged();
    void phoneRegisteredChanged();
    void phoneInvitedChanged();
    void connectedChanged();

protected:
    void try_init();

private slots:
    void authNeeded_slt();
    void authLoggedIn_slt();
    void authLogOut_slt(qint64 id, bool ok);
    void authCheckPhone_slt(qint64 id, bool phoneRegistered, bool phoneInvited);

private:
    TelegramQmlPrivate *p;
};

#endif // TELEGRAMQML_H
