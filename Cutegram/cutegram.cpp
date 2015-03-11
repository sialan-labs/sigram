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

#define UNITY_LIGHT (p->desktop->desktopSession()==AsemanDesktopTools::Unity && !p->desktop->titleBarIsDark())
#define UNITY_ICON_PATH(NUM) "/tmp/aseman-telegram-client-trayicon" + QString::number(NUM) + (darkSystemTray()?"-dark":"-light") + ".png"
#define SYSTRAY_ICON (darkSystemTray()?":/qml/Cutegram/files/systray-dark.png":":/qml/Cutegram/files/systray.png")

#include "cutegram.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemancalendarconverter.h"
#include "asemantools/asemandesktoptools.h"
#include "asemantools/asemandevices.h"
#include "asemantools/asemanapplication.h"
#include "telegramqml.h"
#include "profilesmodel.h"
#include "telegrammessagesmodel.h"
#include "dialogfilesmodel.h"
#include "telegramdialogsmodel.h"
#include "telegramwallpapersmodel.h"
#include "telegramsearchmodel.h"
#include "telegramcontactsmodel.h"
#include "telegramuploadsmodel.h"
#include "telegramchatparticipantsmodel.h"
#include "themeitem.h"
#include "emojis.h"
#include "unitysystemtray.h"
#include "userdata.h"
#include "cutegramenums.h"

#include <QPointer>
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>
#include <QDebug>
#include <QImageWriter>
#include <QTextDocument>
#include <QImageReader>
#include <QSystemTrayIcon>
#include <QGuiApplication>
#include <QMenu>
#include <QAction>
#include <QPainter>
#include <QPainterPath>
#include <QDesktopServices>
#include <QMimeDatabase>

#ifdef Q_OS_MAC
#include <QtMac>
#endif

class CutegramPrivate
{
public:
    QPointer<AsemanQuickView> viewer;
    bool close_blocker;
    int sysTrayCounter;
    int startupOption;
    bool notification;
    bool minimumDialogs;
    bool showLastMessage;
    bool darkSystemTray;
    bool closingState;
    bool cutegramSubscribe;

    QTextDocument *doc;

    QSystemTrayIcon *sysTray;
    UnitySystemTray *unityTray;

    AsemanDesktopTools *desktop;

    QTranslator *translator;
    QString translationsPath;
    QString themesPath;

    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString language;

    QString background;
    QString messageAudio;
    QString masterColor;
    QFont font;

    QPalette mainPalette;

    QMimeDatabase mdb;

    QStringList themes;
    QString theme;
    QPointer<QQmlComponent> currentThemeComponent;
    QPointer<ThemeItem> currentTheme;
};

Cutegram::Cutegram(QObject *parent) :
    QObject(parent)
{
    QFont default_font;
#ifdef Q_OS_MAC
    default_font.setPointSize(9);
#endif

    p = new CutegramPrivate;
    p->doc = new QTextDocument(this);
    p->desktop = new AsemanDesktopTools(this);
    p->sysTray = 0;
    p->unityTray = 0;
    p->sysTrayCounter = 0;
    p->closingState = false;
    p->startupOption = AsemanApplication::settings()->value("General/startupOption", static_cast<int>(StartupAutomatic) ).toInt();
    p->notification = AsemanApplication::settings()->value("General/notification", true ).toBool();
    p->minimumDialogs = AsemanApplication::settings()->value("General/minimumDialogs", false ).toBool();
    p->showLastMessage = AsemanApplication::settings()->value("General/showLastMessage", false ).toBool();
    p->cutegramSubscribe = AsemanApplication::settings()->value("General/cutegramSubscribe", true ).toBool();
    p->darkSystemTray = AsemanApplication::settings()->value("General/darkSystemTray", UNITY_LIGHT ).toBool();
    p->background = AsemanApplication::settings()->value("General/background").toString();
    p->masterColor = AsemanApplication::settings()->value("General/masterColor").toString();
    p->messageAudio = AsemanApplication::settings()->value("General/messageAudio","files/new_msg.ogg").toString();
    p->font = AsemanApplication::settings()->value("General/font", default_font).value<QFont>();
    p->translator = new QTranslator(this);
    p->theme = AsemanApplication::settings()->value("General/theme","Abrisham.qml").toString();

#ifdef Q_OS_ANDROID
    p->close_blocker = true;
    p->translationsPath = "assets:/files/translations";
    p->themesPath = "assets:/themes";
#else
    p->close_blocker = false;
    p->translationsPath = AsemanDevices::resourcePath() + "/files/translations/";
    p->themesPath = AsemanDevices::resourcePath() + "/themes/";
#endif

    p->themes = QDir(p->themesPath).entryList( QStringList()<<"*.qml" ,QDir::Files, QDir::Name);

    qRegisterMetaType<TelegramQml*>("TelegramQml*");
    qRegisterMetaType<UserData*>("UserData*");
    qRegisterMetaType< QList<qint32> >("QList<qint32>");

    qmlRegisterType<TelegramQml>("Cutegram", 1, 0, "Telegram");
    qmlRegisterType<ProfilesModel>("Cutegram", 1, 0, "ProfilesModel");
    qmlRegisterType<ProfilesModelItem>("Cutegram", 1, 0, "ProfilesModelItem");
    qmlRegisterType<TelegramMessagesModel>("Cutegram", 1, 0, "MessagesModel");
    qmlRegisterType<DialogFilesModel>("Cutegram", 1, 0, "DialogFilesModel");
    qmlRegisterType<TelegramWallpapersModel>("Cutegram", 1, 0, "WallpapersModel");
    qmlRegisterType<TelegramDialogsModel>("Cutegram", 1, 0, "DialogsModel");
    qmlRegisterType<TelegramContactsModel>("Cutegram", 1, 0, "ContactsModel");
    qmlRegisterType<TelegramUploadsModel>("Cutegram", 1, 0, "UploadsModel");
    qmlRegisterType<TelegramSearchModel>("Cutegram", 1, 0, "SearchModel");
    qmlRegisterType<CutegramEnums>("Cutegram", 1, 0, "CutegramEnums");
    qmlRegisterType<ThemeItem>("Cutegram", 1, 0, "CutegramTheme");
    qmlRegisterType<TelegramChatParticipantsModel>("Cutegram", 1, 0, "ChatParticipantsModel");
    qmlRegisterType<Emojis>("Cutegram", 1, 0, "Emojis");
    qmlRegisterUncreatableType<UserData>("Cutegram", 1, 0, "UserData", "");

    init_languages();
}

QSize Cutegram::imageSize(const QString &pt)
{
    QString path = pt;
    if(path.left(AsemanDevices::localFilesPrePath().length()) == AsemanDevices::localFilesPrePath())
        path = path.mid(AsemanDevices::localFilesPrePath().length());
    if(path.isEmpty())
        return QSize();

    QImageReader img(path);
    return img.size();
}

bool Cutegram::filsIsImage(const QString &pt)
{
    QString path = pt;
    if(path.left(AsemanDevices::localFilesPrePath().length()) == AsemanDevices::localFilesPrePath())
        path = path.mid(AsemanDevices::localFilesPrePath().length());
    if(path.isEmpty())
        return false;

    return p->mdb.mimeTypeForFile(path).name().toLower().contains("image");
}

qreal Cutegram::htmlWidth(const QString &txt)
{
    p->doc->setHtml(txt);
    return p->doc->size().width() + 10;
}

void Cutegram::deleteFile(const QString &pt)
{
    QString path = pt;
    if(path.left(AsemanDevices::localFilesPrePath().length()) == AsemanDevices::localFilesPrePath())
        path = path.mid(AsemanDevices::localFilesPrePath().length());
    if(path.isEmpty())
        return;

    QFile::remove(path);
}

QString Cutegram::storeMessage(const QString &msg)
{
    const QString &path = AsemanApplication::tempPath() + "/" + QDateTime::currentDateTime().toString("ddd MMMM d yy - hh mm") + ".txt";
    QFile file(path);
    if(!file.open(QFile::WriteOnly))
        return QString();

    file.write(msg.toUtf8());
    file.close();

    return path;
}

QString Cutegram::getTimeString(const QDateTime &dt)
{
    if( QDate::currentDate() == dt.date() ) // TODAY
        return dt.toString("HH:mm");
    else
    if( dt.date().daysTo(QDate::currentDate()) < 7 )
        return dt.toString("ddd HH:mm");
    else
    if( dt.date().year() == QDate::currentDate().year() )
        return dt.toString("dd MMM");
    else
        return dt.toString("dd MMM yy");
}

int Cutegram::showMenu(const QStringList &actions, QPoint point)
{
    if( point.isNull() )
        point = QCursor::pos();

    QMenu menu;
    QList<QAction*> pointers;
    for( int i=0; i<actions.count(); i++ )
        pointers << menu.addAction(actions.value(i));

    QAction *res = menu.exec(point);
    return pointers.indexOf(res);
}

void Cutegram::start()
{
    if( p->viewer )
        return;

    p->viewer = new AsemanQuickView( AsemanQuickView::AllExceptLogger );
    p->viewer->engine()->rootContext()->setContextProperty( "Cutegram", this );
    init_theme();

    p->viewer->setSource(QUrl(QStringLiteral("qrc:/qml/Cutegram/main.qml")));

    switch(startupOption())
    {
    case StartupAutomatic:
        if(AsemanApplication::settings()->value("General/lastWindowState",true).toBool())
            p->viewer->show();
        break;

    case StartupVisible:
        p->viewer->show();
        break;

    case StartupHide:
        break;
    }

    init_systray();
}

void Cutegram::restart()
{
    QProcess::startDetached(QCoreApplication::applicationFilePath(), QStringList()<<"--force");
    quit();
}

void Cutegram::logout(const QString &phone)
{
    const QString &home = AsemanApplication::homePath();
    const QString &ppath = home + "/" + phone;
    QFile::remove(ppath + "/auth");
    QFile::remove(ppath + "/config");
    QFile::remove(ppath + "/secret");
    QFile::remove(ppath + "/database.db");
    QFile::remove(ppath + "/database.db-journal");

    restart();
}

void Cutegram::close()
{
    p->close_blocker = false;
    p->viewer->close();
}

void Cutegram::quit()
{
    p->closingState = true;
    emit closingStateChanged();

    QGuiApplication::quit();
}

void Cutegram::contact()
{
    QDesktopServices::openUrl(QUrl("http://aseman.co/en/contact-us/cutegram/"));
}

void Cutegram::aboutAseman()
{
    emit aboutAsemanRequest();
    active();
}

void Cutegram::about()
{
    p->viewer->root()->setProperty("aboutMode", true);
    active();
}

void Cutegram::configure()
{
    emit configureRequest();
    active();
}

void Cutegram::incomingAppMessage(const QString &msg)
{
    if( msg == "show" )
    {
        active();
    }
}

void Cutegram::active()
{
    p->viewer->show();
    p->viewer->requestActivate();
}

void Cutegram::setSysTrayCounter(int count, bool force)
{
    if( count == p->sysTrayCounter && !force )
        return;

    const QImage & img = generateIcon( QImage(SYSTRAY_ICON), count );
    if( p->sysTray )
    {
        p->sysTray->setIcon( QPixmap::fromImage(img) );
    }
    else
    if( p->unityTray )
    {
        QString path = UNITY_ICON_PATH(count);
        QFile::remove(path);
        QImageWriter writer(path);
        writer.write(img);
        p->unityTray->setIcon(path);
    }

    p->sysTrayCounter = count;

#ifdef Q_OS_MAC
    QtMac::setBadgeLabelText(count?QString::number(count):"");
#endif

    emit sysTrayCounterChanged();
}

int Cutegram::sysTrayCounter() const
{
    return p->sysTrayCounter;
}

bool Cutegram::eventFilter(QObject *o, QEvent *e)
{
    if( o == p->viewer )
    {
        switch( static_cast<int>(e->type()) )
        {
        case QEvent::Close:
            if( p->close_blocker )
            {
                static_cast<QCloseEvent*>(e)->ignore();
                emit backRequest();
            }
            else
            {
                static_cast<QCloseEvent*>(e)->accept();
            }

            return false;
            break;
        }
    }

    return QObject::eventFilter(o,e);
}

void Cutegram::systray_action(QSystemTrayIcon::ActivationReason act)
{
    switch( static_cast<int>(act) )
    {
    case QSystemTrayIcon::Trigger:
        if( p->viewer->isVisible() && p->viewer->isActive() )
            p->viewer->hide();
        else
        {
            active();
        }
        break;

    case QSystemTrayIcon::Context:
        showContextMenu();
        break;
    }
}

void Cutegram::init_systray()
{
    if( p->desktop->desktopSession() == AsemanDesktopTools::Unity || p->desktop->desktopSession() == AsemanDesktopTools::GnomeFallBack )
    {
        QFile::remove(UNITY_ICON_PATH(0));
        QFile::copy(SYSTRAY_ICON,UNITY_ICON_PATH(0));

        p->unityTray = new UnitySystemTray( QCoreApplication::applicationName(), UNITY_ICON_PATH(0) );
        if( !p->unityTray->pntr() )
            QGuiApplication::setQuitOnLastWindowClosed(true);

        p->unityTray->addMenu( tr("Show"), this, "active" );
        p->unityTray->addMenu( tr("Configure"), this, "configure" );
        p->unityTray->addMenu( tr("Contact"), this, "contact" );
        p->unityTray->addMenu( tr("About"), this, "about" );
        p->unityTray->addMenu( tr("About Aseman"), this, "aboutAseman" );
        p->unityTray->addMenu( tr("Quit"), this, "quit" );
    }
    if( !p->unityTray || !p->unityTray->pntr() )
    {
        p->sysTray = new QSystemTrayIcon( QIcon(SYSTRAY_ICON), this );
#ifndef Q_OS_MAC
        p->sysTray->show();
#endif

        connect( p->sysTray, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), SLOT(systray_action(QSystemTrayIcon::ActivationReason)) );
    }
}

void Cutegram::showContextMenu()
{
    QMenu menu;
    menu.move( QCursor::pos() );

    QAction *show_act = menu.addAction( tr("Show") );
    menu.addSeparator();
    QAction *conf_act = menu.addAction( tr("Configure") );
    QAction *cnct_act = menu.addAction( tr("Contact") );
    menu.addSeparator();
    QAction *abut_act = menu.addAction( tr("About") );
    QAction *sabt_act = menu.addAction( tr("About Aseman") );
    menu.addSeparator();
    QAction *exit_act = menu.addAction( tr("Exit") );
    QAction *res_act  = menu.exec();

    if( res_act == show_act )
    {
        active();
    }
    else
    if( res_act == conf_act )
    {
        configure();
    }
    else
    if( res_act == cnct_act )
    {
        contact();
    }
    else
    if( res_act == abut_act )
    {
        about();
    }
    else
    if( res_act == sabt_act )
    {
        aboutAseman();
    }
    else
    if( res_act == exit_act )
    {
        quit();
    }
}

QImage Cutegram::generateIcon(const QImage &img, int count)
{
    QImage res = img;
    if( count == 0 )
        return img;

    QRect rct;
    rct.setX( img.width()/5 );
    rct.setWidth( 4*img.width()/5 );
    rct.setY( img.height()-rct.width() );
    rct.setHeight( rct.width() );

    QPainterPath path;
    path.addEllipse(rct);

    QPainter painter(&res);
    painter.setRenderHint( QPainter::Antialiasing , true );
    painter.fillPath( path, QColor("#ff0000") );
    painter.setPen("#333333");
    painter.drawPath( path );
    painter.setPen("#ffffff");
    painter.drawText( rct, Qt::AlignCenter | Qt::AlignHCenter, QString::number(count) );

    return res;
}

QStringList Cutegram::languages()
{
    QStringList res = p->languages.keys();
    res.sort();
    return res;
}

void Cutegram::setLanguage(const QString &lang)
{
    if( p->language == lang )
        return;

    QGuiApplication::removeTranslator(p->translator);
    p->translator->load(p->languages.value(lang).toString(),"languages");
    QGuiApplication::installTranslator(p->translator);
    p->language = lang;

    AsemanApplication::settings()->setValue("General/Language",lang);

    emit languageChanged();
    emit languageDirectionChanged();
}

QString Cutegram::language() const
{
    return p->language;
}

bool Cutegram::closingState() const
{
    return p->closingState;
}

void Cutegram::setStartupOption(int opt)
{
    if(opt == p->startupOption)
        return;

    p->startupOption = opt;
    AsemanApplication::settings()->setValue("General/startupOption", opt);
    emit startupOptionChanged();
}

int Cutegram::startupOption() const
{
    return p->startupOption;
}

void Cutegram::setNotification(bool stt)
{
    if(p->notification == stt)
        return;

    p->notification = stt;
    AsemanApplication::settings()->setValue("General/notification", stt);
    emit notificationChanged();
}

bool Cutegram::notification() const
{
    return p->notification;
}

void Cutegram::setMinimumDialogs(bool stt)
{
    if(p->minimumDialogs == stt)
        return;

    p->minimumDialogs = stt;
    AsemanApplication::settings()->setValue("General/minimumDialogs", stt);
    emit minimumDialogsChanged();
}

bool Cutegram::minimumDialogs() const
{
    return p->minimumDialogs;
}

void Cutegram::setShowLastMessage(bool stt)
{
    if(p->showLastMessage == stt)
        return;

    p->showLastMessage = stt;
    AsemanApplication::settings()->setValue("General/showLastMessage", stt);
    emit showLastMessageChanged();
}

bool Cutegram::showLastMessage() const
{
    return p->showLastMessage;
}

void Cutegram::setDarkSystemTray(bool stt)
{
    if(p->darkSystemTray == stt)
        return;

    p->darkSystemTray = stt;
    AsemanApplication::settings()->setValue("General/darkSystemTray", stt);

    setSysTrayCounter(sysTrayCounter(), true);
    emit darkSystemTrayChanged();
}

bool Cutegram::darkSystemTray() const
{
    return p->darkSystemTray;
}

void Cutegram::setBackground(const QString &background)
{
    if(p->background == background)
        return;

    p->background = background;
    AsemanApplication::settings()->setValue("General/background", background);
    emit backgroundChanged();
}

QString Cutegram::background() const
{
    return p->background;
}

void Cutegram::setMessageAudio(const QString &file)
{
    if(p->messageAudio == file)
        return;

    p->messageAudio = file;
    AsemanApplication::settings()->setValue("General/messageAudio", file);
    emit messageAudioChanged();
}

QString Cutegram::messageAudio() const
{
    return p->messageAudio;
}

void Cutegram::setMasterColor(const QString &color)
{
    if(p->masterColor == color)
        return;

    p->masterColor = color;
    AsemanApplication::settings()->setValue("General/masterColor", color);

    emit masterColorChanged();
    emit highlightColorChanged();
}

QString Cutegram::masterColor() const
{
    return p->masterColor;
}

QColor Cutegram::highlightColor() const
{
    return p->masterColor.isEmpty()? p->mainPalette.highlight().color() : QColor(p->masterColor);
}

void Cutegram::setFont(const QFont &font)
{
    if(p->font == font)
        return;

    p->font = font;
    AsemanApplication::settings()->setValue("General/font", font);
    emit fontChanged();
}

QFont Cutegram::font() const
{
    return p->font;
}

void Cutegram::setAsemanSubscribe(bool stt)
{
    if(p->cutegramSubscribe == stt)
        return;

    p->cutegramSubscribe = stt;
    AsemanApplication::settings()->setValue("General/cutegramSubscribe", stt);

    emit cutegramSubscribeChanged();
}

bool Cutegram::cutegramSubscribe() const
{
    return p->cutegramSubscribe;
}

QStringList Cutegram::themes() const
{
    return p->themes;
}

void Cutegram::setTheme(const QString &theme)
{
    if(p->theme == theme)
        return;

    p->theme = theme;
    AsemanApplication::settings()->setValue("General/theme",p->theme);
    init_theme();

    emit themeChanged();
}

QString Cutegram::theme() const
{
    return p->theme;
}

ThemeItem *Cutegram::currentTheme()
{
    return p->currentTheme;
}

void Cutegram::init_languages()
{
    QDir dir(p->translationsPath);
    QStringList languages = dir.entryList( QDir::Files );
    if( !languages.contains("lang-en.qm") )
        languages.prepend("lang-en.qm");

    for( int i=0 ; i<languages.size() ; i++ )
    {
        QString locale_str = languages[i];
        locale_str.truncate( locale_str.lastIndexOf('.') );
        locale_str.remove( 0, locale_str.indexOf('-') + 1 );

        QLocale locale(locale_str);

        QString  lang = QString("%1 (%2)").arg(QLocale::languageToString(locale.language()), QLocale::countryToString(locale.country()));
        QVariant data = p->translationsPath + "/" + languages[i];

        p->languages.insert( lang, data );
        p->locales.insert( lang , locale );

        if( lang == AsemanApplication::settings()->value("General/Language","English (UnitedStates)").toString() )
            setLanguage( lang );
    }
}

void Cutegram::init_theme()
{
    if(p->currentThemeComponent)
        p->currentThemeComponent->deleteLater();
    if(p->currentTheme)
        p->currentTheme->deleteLater();

    p->currentThemeComponent = new QQmlComponent(p->viewer->engine(), p->themesPath + "/" + p->theme);
    p->currentTheme = static_cast<ThemeItem*>(p->currentThemeComponent->create());

    emit currentThemeChanged();
}

QVariantList Cutegram::intListToVariantList(const QList<qint32> &list)
{
    QVariantList res;
    foreach(const qint32 u, list)
        res << u;

    return res;
}

QList<qint32> Cutegram::variantListToIntList(const QVariantList &list)
{
    QList<qint32> res;
    foreach(const QVariant &l, list)
        res << l.toInt();

    return res;
}

Cutegram::~Cutegram()
{
    delete p;
}
