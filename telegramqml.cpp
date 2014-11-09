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

#include "telegramqml.h"

#include <telegram.h>

#include <QPointer>
#include <QDebug>

class TelegramQmlPrivate
{
public:
    Telegram *telegram;

    QString phoneNumber;
    QString configPath;
    QString publicKeyFile;

    bool authNeeded;
    bool authLoggedIn;
    bool phoneRegistered;
    bool phoneInvited;
    bool phoneChecked;

    QString authSignUpError;
    QString authSignInError;
    QString error;

    qint64 logout_req_id;
    qint64 checkphone_req_id;
};

TelegramQml::TelegramQml(QObject *parent) :
    QObject(parent)
{
    p = new TelegramQmlPrivate;
    p->telegram = 0;
    p->authNeeded = false;
    p->authLoggedIn = false;
    p->phoneRegistered = false;
    p->phoneInvited = false;
    p->phoneChecked = false;

    p->logout_req_id = 0;
    p->checkphone_req_id = 0;
}

QString TelegramQml::phoneNumber() const
{
    return p->phoneNumber;
}

void TelegramQml::setPhoneNumber(const QString &phone)
{
    if( p->phoneNumber == phone )
        return;

    p->phoneNumber = phone;
    emit phoneNumberChanged();
    try_init();
}

QString TelegramQml::configPath() const
{
    return p->configPath;
}

void TelegramQml::setConfigPath(const QString &conf)
{
    if( p->configPath == conf )
        return;

    p->configPath = conf;
    emit configPathChanged();
    try_init();
}

QString TelegramQml::publicKeyFile() const
{
    return p->publicKeyFile;
}

void TelegramQml::setPublicKeyFile(const QString &file)
{
    if( p->publicKeyFile == file )
        return;

    p->publicKeyFile = file;
    emit publicKeyFileChanged();
    try_init();
}

Telegram *TelegramQml::telegram() const
{
    return p->telegram;
}

bool TelegramQml::authNeeded() const
{
    return p->authNeeded;
}

bool TelegramQml::authLoggedIn() const
{
    return p->authLoggedIn;
}

bool TelegramQml::authPhoneChecked() const
{
    return p->phoneChecked;
}

bool TelegramQml::authPhoneRegistered() const
{
    return p->phoneRegistered;
}

bool TelegramQml::authPhoneInvited() const
{
    return p->phoneInvited;
}

bool TelegramQml::connected() const
{
    if( !p->telegram )
        return false;

    return p->telegram->isConnected();
}

QString TelegramQml::authSignUpError() const
{
    return p->authSignUpError;
}

QString TelegramQml::authSignInError() const
{
    return p->authSignInError;
}

QString TelegramQml::error() const
{
    return p->error;
}

void TelegramQml::authLogout()
{
    if( !p->telegram )
        return;
    if( p->logout_req_id )
        return;

    p->logout_req_id = p->telegram->authLogOut();
}

void TelegramQml::authSendCall()
{
    if( !p->telegram )
        return;

    p->telegram->authSendCall();
}

void TelegramQml::authSendInvites(const QStringList &phoneNumbers, const QString &inviteText)
{
    if( !p->telegram )
        return;

    p->telegram->authSendInvites(phoneNumbers, inviteText);
}

void TelegramQml::authSignIn(const QString &code)
{
    if( !p->telegram )
        return;

    p->telegram->authSignIn(code);

    p->authNeeded = false;
    p->authSignUpError = "";
    p->authSignInError = "";
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
    emit authNeededChanged();
}

void TelegramQml::authSignUp(const QString &code, const QString &firstName, const QString &lastName)
{
    if( !p->telegram )
        return;

    p->telegram->authSignUp(code, firstName, lastName);

    p->authNeeded = false;
    p->authSignUpError = "";
    p->authSignInError = "";
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
    emit authNeededChanged();
}

void TelegramQml::try_init()
{
    if( p->telegram )
    {
        delete p->telegram;
        p->telegram = 0;
    }
    if( p->phoneNumber.isEmpty() || p->publicKeyFile.isEmpty() || p->configPath.isEmpty() )
        return;

    p->telegram = new Telegram(p->phoneNumber, p->configPath, p->publicKeyFile);

    connect( p->telegram, SIGNAL(authNeeded())                          , SLOT(authNeeded_slt())                           );
    connect( p->telegram, SIGNAL(authLoggedIn())                        , SLOT(authLoggedIn_slt())                         );
    connect( p->telegram, SIGNAL(authLogOutAnswer(qint64,bool))         , SLOT(authLogOut_slt(qint64,bool))                );
    connect( p->telegram, SIGNAL(authCheckPhoneAnswer(qint64,bool,bool)), SLOT(authCheckPhone_slt(qint64,bool,bool))       );
    connect( p->telegram, SIGNAL(authSendCallAnswer(qint64,bool))       , SLOT(authSendCall_slt(qint64,bool))              );
    connect( p->telegram, SIGNAL(authSendCodeAnswer(qint64,bool,qint32)), SLOT(authSendCode_slt(qint64,bool,qint32))       );
    connect( p->telegram, SIGNAL(authSendInvitesAnswer(qint64,bool))    , SLOT(authSendInvites_slt(qint64,bool))           );
    connect( p->telegram, SIGNAL(authSignInError(qint64,qint32,QString)), SLOT(authSignInError_slt(qint64,qint32,QString)) );
    connect( p->telegram, SIGNAL(authSignUpError(qint64,qint32,QString)), SLOT(authSignUpError_slt(qint64,qint32,QString)) );
    connect( p->telegram, SIGNAL(connected())                           , SIGNAL(connectedChanged())                       );
    connect( p->telegram, SIGNAL(disconnected())                        , SIGNAL(connectedChanged())                       );

    emit telegramChanged();

    p->telegram->init();
}

void TelegramQml::authNeeded_slt()
{
    p->authNeeded = true;
    p->authLoggedIn = false;

    emit authNeededChanged();
    emit authLoggedInChanged();

    if( p->telegram && !p->checkphone_req_id )
        p->checkphone_req_id = p->telegram->authCheckPhone();
}

void TelegramQml::authLoggedIn_slt()
{
    p->authNeeded = false;
    p->authLoggedIn = true;

    qDebug() << "\n\n\nLoggedIn\n\n\n";

    emit authNeededChanged();
    emit authLoggedInChanged();
}

void TelegramQml::authLogOut_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    p->authNeeded = ok;
    p->authLoggedIn = !ok;
    p->logout_req_id = 0;

    emit authNeededChanged();
    emit authLoggedInChanged();
}

void TelegramQml::authSendCode_slt(qint64 id, bool phoneRegistered, qint32 sendCallTimeout)
{
    Q_UNUSED(id)
    emit authCodeRequested(phoneRegistered, sendCallTimeout );
}

void TelegramQml::authSendCall_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    emit authCallRequested(ok);
}

void TelegramQml::authSendInvites_slt(qint64 id, bool ok)
{
    Q_UNUSED(id)
    emit authInvitesSent(ok);
}

void TelegramQml::authCheckPhone_slt(qint64 id, bool phoneRegistered, bool phoneInvited)
{
    Q_UNUSED(id)
    p->phoneRegistered = phoneRegistered;
    p->phoneInvited = phoneInvited;
    p->phoneChecked = true;

    emit authPhoneRegisteredChanged();
    emit authPhoneInvitedChanged();
    emit authPhoneCheckedChanged();

    if( p->telegram )
        p->telegram->authSendCode();
}

void TelegramQml::authSignInError_slt(qint64 id, qint32 errorCode, QString errorText)
{
    Q_UNUSED(id)
    Q_UNUSED(errorCode)

    p->authSignUpError = "";
    p->authSignInError = errorText;
    p->authNeeded = true;
    emit authNeededChanged();
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
}

void TelegramQml::authSignUpError_slt(qint64 id, qint32 errorCode, QString errorText)
{
    Q_UNUSED(id)
    Q_UNUSED(errorCode)

    p->authSignUpError = errorText;
    p->authSignInError = "";
    p->authNeeded = true;
    emit authNeededChanged();
    emit authSignInErrorChanged();
    emit authSignUpErrorChanged();
}

void TelegramQml::error(qint64 id, qint32 errorCode, QString errorText)
{
    Q_UNUSED(id)
    Q_UNUSED(errorCode)
    p->error = errorText;
    emit errorChanged();
}

TelegramQml::~TelegramQml()
{
    if( p->telegram )
        delete p->telegram;

    delete p;
}
