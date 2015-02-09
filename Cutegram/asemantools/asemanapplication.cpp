/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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

#include "asemanapplication.h"
#include "asemantools.h"

#include <QDir>
#include <QFont>
#include <QSettings>
#include <QThread>
#include <QCoreApplication>
#include <QDebug>

static QSettings *app_global_settings = 0;
static AsemanApplication *aseman_app_singleton = 0;

class AsemanApplicationPrivate
{
public:
    QFont globalFont;
};

#ifdef ASEMAN_QML_PLUGIN
AsemanApplication::AsemanApplication() :
    INHERIT_QAPP ()
  #else
AsemanApplication::AsemanApplication(int &argc, char **argv) :
    INHERIT_QAPP (argc,argv)
  #endif
{
    p = new AsemanApplicationPrivate;
    if(!aseman_app_singleton)
        aseman_app_singleton = this;
}

QString AsemanApplication::homePath()
{
    QString result;

#ifdef Q_OS_ANDROID
    result = QDir::homePath();
#else
#ifdef Q_OS_IOS
    result = QDir::homePath();
#else
#ifdef Q_OS_WIN
    result = QDir::homePath() + "/AppData/Local/" + QCoreApplication::applicationName();
#else
    result = QDir::homePath() + "/.config/" + QCoreApplication::applicationName();
#endif
#endif
#endif

    return result;
}

QString AsemanApplication::appPath()
{
    return QCoreApplication::applicationDirPath();
}

QString AsemanApplication::appFilePath()
{
    return QCoreApplication::applicationFilePath();
}

QString AsemanApplication::logPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationDomain() + "/" + QCoreApplication::applicationName() + "/log";
#else
    return homePath()+"/log";
#endif
}

QString AsemanApplication::confsPath()
{
    return homePath() + "/config.ini";
}

QString AsemanApplication::tempPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationDomain() + "/" + QCoreApplication::applicationName() + "/temp";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/tmp/";
#else
    return QDir::tempPath();
#endif
#endif
}

QString AsemanApplication::backupsPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationDomain() + "/" + QCoreApplication::applicationName() + "/backups";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/backups/";
#else
    return homePath() + "/backups";
#endif
#endif
}

QString AsemanApplication::cameraPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/DCIM";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/camera/";
#else
    return QDir::homePath() + "/Pictures/Camera";
#endif
#endif
}

AsemanApplication *AsemanApplication::instance()
{
    return aseman_app_singleton;
}

void AsemanApplication::setGlobalFont(const QFont &font)
{
    if(p->globalFont == font)
        return;

    p->globalFont = font;
    emit globalFontChanged();
}

QFont AsemanApplication::globalFont() const
{
    return p->globalFont;
}

QSettings *AsemanApplication::settings()
{
    if( !app_global_settings )
    {
        QDir().mkpath(AsemanApplication::homePath());
        app_global_settings = new QSettings( AsemanApplication::homePath() + "/config.ini", QSettings::IniFormat );
    }

    return app_global_settings;
}

void AsemanApplication::refreshTranslations()
{
    emit languageUpdated();
}

void AsemanApplication::back()
{
    emit backRequest();
}

void AsemanApplication::sleep(quint64 ms)
{
    QThread::msleep(ms);
}

void AsemanApplication::setSetting(const QString &key, const QVariant &value)
{
    settings()->setValue(key, value);
}

QVariant AsemanApplication::readSetting(const QString &key, const QVariant &defaultValue)
{
    return settings()->value(key, defaultValue);
}

bool AsemanApplication::event(QEvent *e)
{
#ifdef Q_OS_MAC
    switch(e->type())
    {
    case QEvent::ApplicationActivate:
        clickedOnDock();
        break;

    default:
        break;
    }
#endif

    return INHERIT_QAPP::event(e);
}

AsemanApplication::~AsemanApplication()
{
    if(aseman_app_singleton == this)
        aseman_app_singleton = 0;

    delete p;
}
