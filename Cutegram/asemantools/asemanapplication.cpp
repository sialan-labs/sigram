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
#include <QPalette>
#include <QSettings>
#include <QThread>
#include <QCoreApplication>
#include <QDebug>

#ifdef QT_GUI_LIB
#define READ_DEFINITION(FUNCTION, DEFAULT_VALUE) \
    switch(aseman_app_singleton->p->appType) { \
    case GuiApplication: \
        return static_cast<QGuiApplication*>(QCoreApplication::instance())->FUNCTION(); \
        break; \
    case WidgetApplication: \
        return static_cast<QtSingleApplication*>(QCoreApplication::instance())->FUNCTION(); \
        break; \
    default: \
        return DEFAULT_VALUE; \
        break; \
    }
#else
#define READ_DEFINITION(FUNCTION, DEFAULT_VALUE) \
    return DEFAULT_VALUE;
#endif

#ifdef QT_GUI_LIB
#define SET_DIFINITION(FUNCTION, VALUE) \
    switch(aseman_app_singleton->p->appType) { \
    case GuiApplication: \
        static_cast<QGuiApplication*>(QCoreApplication::instance())->FUNCTION(VALUE); \
        break; \
    case WidgetApplication: \
        static_cast<QtSingleApplication*>(QCoreApplication::instance())->FUNCTION(VALUE); \
        break; \
    }
#else
#define SET_DIFINITION(FUNCTION, VALUE)
    Q_UNUSED(VALUE)
#endif


#ifdef QT_GUI_LIB
#include <QGuiApplication>
#endif
#ifdef QT_CORE_LIB
#include <QCoreApplication>
#endif
#ifdef QT_WIDGETS_LIB
#include <QApplication>
#include "qtsingleapplication/qtsingleapplication.h"
#endif

static QSettings *app_global_settings = 0;
static AsemanApplication *aseman_app_singleton = 0;

class AsemanApplicationPrivate
{
public:
    QFont globalFont;
    int appType;
    QCoreApplication *app;
    bool app_owner;
};

AsemanApplication::AsemanApplication() :
    QObject()
{
    p = new AsemanApplicationPrivate;
    p->app = QCoreApplication::instance();
    p->appType = NoneApplication;
    p->app_owner = false;

#ifdef QT_WIDGETS_LIB
    if( qobject_cast<QtSingleApplication*>(p->app) )
    {
        p->appType = WidgetApplication;
        p->globalFont = static_cast<QtSingleApplication*>(p->app)->font();
    }
    else
#endif
#ifdef QT_GUI_LIB
    if( qobject_cast<QGuiApplication*>(p->app) )
    {
        p->appType = GuiApplication;
        p->globalFont = static_cast<QGuiApplication*>(p->app)->font();
    }
    else
#endif
#ifdef QT_CORE_LIB
    if( qobject_cast<QCoreApplication*>(p->app) )
        p->appType = CoreApplication;
#endif

    if(!aseman_app_singleton)
        aseman_app_singleton = this;
}

AsemanApplication::AsemanApplication(int &argc, char **argv, ApplicationType appType) :
    QObject()
{
    if(!aseman_app_singleton)
        aseman_app_singleton = this;

    p = new AsemanApplicationPrivate;
    p->appType = appType;
    p->app_owner = true;

    switch(p->appType)
    {
#ifdef QT_CORE_LIB
    case CoreApplication:
        p->app = new QCoreApplication(argc, argv);
        connect(p->app, SIGNAL(organizationNameChanged())  , SIGNAL(organizationNameChanged()));
        connect(p->app, SIGNAL(organizationDomainChanged()), SIGNAL(organizationDomainChanged()));
        connect(p->app, SIGNAL(applicationNameChanged())   , SIGNAL(applicationNameChanged()));
        connect(p->app, SIGNAL(applicationVersionChanged()), SIGNAL(applicationVersionChanged()));
        break;
#endif
#ifdef QT_GUI_LIB
    case GuiApplication:
        p->app = new QGuiApplication(argc, argv);
        connect(p->app, SIGNAL(lastWindowClosed()), SIGNAL(lastWindowClosed()));

        p->globalFont = static_cast<QGuiApplication*>(p->app)->font();
        break;
#endif
#ifdef QT_WIDGETS_LIB
    case WidgetApplication:
        p->app = new QtSingleApplication(argc, argv);
        connect(p->app, SIGNAL(messageReceived(QString)), SIGNAL(messageReceived(QString)));

        p->globalFont = static_cast<QtSingleApplication*>(p->app)->font();
        break;
#endif
    default:
        p->app = 0;
        break;
    }
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

QString AsemanApplication::applicationDirPath()
{
    return QCoreApplication::applicationDirPath();
}

QString AsemanApplication::applicationFilePath()
{
    return QCoreApplication::applicationFilePath();
}

qint64 AsemanApplication::applicationPid()
{
    return QCoreApplication::applicationPid();
}

void AsemanApplication::setOrganizationDomain(const QString &orgDomain)
{
    QCoreApplication::setOrganizationDomain(orgDomain);
}

QString AsemanApplication::organizationDomain()
{
    return QCoreApplication::organizationDomain();
}

void AsemanApplication::setOrganizationName(const QString &orgName)
{
    QCoreApplication::setOrganizationName(orgName);
}

QString AsemanApplication::organizationName()
{
    return QCoreApplication::organizationName();
}

void AsemanApplication::setApplicationName(const QString &application)
{
    QCoreApplication::setApplicationName(application);
}

QString AsemanApplication::applicationName()
{
    return QCoreApplication::applicationName();
}

void AsemanApplication::setApplicationVersion(const QString &version)
{
    QCoreApplication::setApplicationVersion(version);
}

QString AsemanApplication::applicationVersion()
{
    return QCoreApplication::applicationVersion();
}

void AsemanApplication::setApplicationDisplayName(const QString &name)
{
    SET_DIFINITION(setApplicationDisplayName, name)
}

QString AsemanApplication::applicationDisplayName()
{
    READ_DEFINITION(applicationDisplayName, QString())
}

QString AsemanApplication::platformName()
{
    READ_DEFINITION(platformName, QString())
}

QStringList AsemanApplication::arguments()
{
    return QCoreApplication::arguments();
}

void AsemanApplication::setQuitOnLastWindowClosed(bool quit)
{
    SET_DIFINITION(setQuitOnLastWindowClosed, quit)
}

bool AsemanApplication::quitOnLastWindowClosed()
{
    READ_DEFINITION(quitOnLastWindowClosed, false)
}

QClipboard *AsemanApplication::clipboard()
{
    READ_DEFINITION(clipboard, 0)
}

#ifdef QT_GUI_LIB
void AsemanApplication::setWindowIcon(const QIcon &icon)
{
    SET_DIFINITION(setWindowIcon, icon)
}

QIcon AsemanApplication::windowIcon()
{
    READ_DEFINITION(windowIcon, QIcon())
}
#endif

bool AsemanApplication::isRunning()
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == WidgetApplication)
        return static_cast<QtSingleApplication*>(QCoreApplication::instance())->isRunning();
#endif

    return false;
}

int AsemanApplication::appType()
{
    return aseman_app_singleton->p->appType;
}

void AsemanApplication::sendMessage(const QString &msg)
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == WidgetApplication)
        static_cast<QtSingleApplication*>(QCoreApplication::instance())->sendMessage(msg);
#else
    Q_UNUSED(msg)
#endif
}

AsemanApplication *AsemanApplication::instance()
{
    return aseman_app_singleton;
}

QCoreApplication *AsemanApplication::qapp()
{
    return QCoreApplication::instance();
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

QFont AsemanApplication::font()
{
    READ_DEFINITION(font, QFont())
}

void AsemanApplication::setFont(const QFont &f)
{
    SET_DIFINITION(setFont, f);
}

#ifdef QT_GUI_LIB
QPalette AsemanApplication::palette()
{
    READ_DEFINITION(palette, QPalette())
}

void AsemanApplication::setPalette(const QPalette &pal)
{
    SET_DIFINITION(setPalette, pal);
}
#endif

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

int AsemanApplication::exec()
{
    return p->app->exec();
}

void AsemanApplication::exit(int retcode)
{
    aseman_app_singleton->p->app->exit(retcode);
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

    return QObject::event(e);
}

AsemanApplication::~AsemanApplication()
{
    if(aseman_app_singleton == this)
        aseman_app_singleton = 0;

    if(p->app && p->app_owner)
        delete p->app;

    delete p;
}
