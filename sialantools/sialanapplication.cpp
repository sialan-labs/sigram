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

#include "sialanapplication.h"

#include <QDir>
#include <QFont>

class SialanApplicationPrivate
{
public:
    QString globalFontFamily;
    QString globalMonoFontFamily;
};

SialanApplication *sialan_app_obj = 0;
SialanApplication::SialanApplication(int &argc, char **argv) :
    INHERIT_QAPP (argc,argv)
{
    p = new SialanApplicationPrivate;
    p->globalFontFamily = "Droid Kaqaz Sans";
    p->globalMonoFontFamily = "Droid Sans Mono";

    sialan_app_obj = this;
}

QString SialanApplication::homePath()
{
#ifdef Q_OS_ANDROID
    return QDir::homePath();
#else
#ifdef Q_OS_IOS
    return QDir::homePath();
#else
#ifdef Q_OS_WIN
    return QDir::homePath() + "/AppData/Local/" + QCoreApplication::organizationName().toLower() + "/" + QCoreApplication::applicationName().toLower();
#else
#ifdef Q_OS_UBUNTUTOUCH
    return QDir::homePath() + "/.config/" + QCoreApplication::organizationDomain().toLower();
#else
    return QDir::homePath() + "/.config/" + QCoreApplication::organizationName().toLower() + "/" + QCoreApplication::applicationName().toLower();
#endif
#endif
#endif
#endif
}

QString SialanApplication::appPath()
{
    return QCoreApplication::applicationDirPath();
}

QString SialanApplication::logPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationName() + "/" + QCoreApplication::applicationName() + "/log";
#else
    return homePath()+"/log";
#endif
}

QString SialanApplication::confsPath()
{
    return homePath() + "/config.ini";
}

QString SialanApplication::tempPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationName() + "/" + QCoreApplication::applicationName() + "/temp";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/tmp/";
#else
    return QDir::tempPath();
#endif
#endif
}

QString SialanApplication::backupsPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationName() + "/" + QCoreApplication::applicationName() + "/backups";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/backups/";
#else
    return homePath() + "/backups";
#endif
#endif
}

QString SialanApplication::cameraPath()
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

SialanApplication *SialanApplication::instance()
{
    return sialan_app_obj;
}

void SialanApplication::setGlobalFontFamily(const QString &fontFamily)
{
    if( p->globalFontFamily == fontFamily )
        return;

    p->globalFontFamily = fontFamily;
    emit globalFontFamilyChanged();
}

QString SialanApplication::globalFontFamily() const
{
    return p->globalFontFamily;
}

void SialanApplication::setGlobalMonoFontFamily(const QString &fontFamily)
{
    if( p->globalMonoFontFamily == fontFamily )
        return;

    p->globalMonoFontFamily = fontFamily;
    emit globalMonoFontFamilyChanged();
}

QString SialanApplication::globalMonoFontFamily() const
{
    return p->globalMonoFontFamily;
}

void SialanApplication::refreshTranslations()
{
    emit languageUpdated();
}

void SialanApplication::back()
{
    emit backRequest();
}

SialanApplication::~SialanApplication()
{
    sialan_app_obj = 0;
    delete p;
}
