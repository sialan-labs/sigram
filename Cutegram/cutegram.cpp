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

#define UNITY_ICON_PATH(NUM) "/tmp/aseman-telegram-client-trayicon" + QString::number(NUM) + ".png"

#include "cutegram.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemancalendarconverter.h"
#include "asemantools/asemandesktoptools.h"
#include "asemantools/asemandevices.h"
#include "asemantools/asemanapplication.h"
#include "telegramqml.h"
#include "profilesmodel.h"
#include "telegrammessagesmodel.h"
#include "telegramdialogsmodel.h"
#include "telegramwallpapersmodel.h"
#include "telegramcontactsmodel.h"
#include "telegramuploadsmodel.h"
#include "telegramchatparticipantsmodel.h"
#include "emojis.h"
#include "unitysystemtray.h"
#include "userdata.h"

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

class CutegramPrivate
{
public:
    QPointer<AsemanQuickView> viewer;
    bool close_blocker;
    int sysTrayCounter;
    int startupOption;
    bool notification;

    QTextDocument *doc;

    QSystemTrayIcon *sysTray;
    UnitySystemTray *unityTray;

    AsemanDesktopTools *desktop;

    QTranslator *translator;
    QString translationsPath;

    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString language;
};

Cutegram::Cutegram(QObject *parent) :
    QObject(parent)
{
    p = new CutegramPrivate;
    p->doc = new QTextDocument(this);
    p->desktop = new AsemanDesktopTools(this);
    p->sysTray = 0;
    p->unityTray = 0;
    p->sysTrayCounter = 0;
    p->startupOption = AsemanApplication::settings()->value("General/startupOption", static_cast<int>(StartupAutomatic) ).toInt();
    p->notification = AsemanApplication::settings()->value("General/notification", true ).toBool();
    p->translator = new QTranslator(this);

#ifdef Q_OS_ANDROID
    p->close_blocker = true;
    p->translationsPath = "assets:/files/translations";
#else
    p->close_blocker = false;
    p->translationsPath = AsemanDevices::resourcePath() + "/files/translations/";
#endif

    qRegisterMetaType<TelegramQml*>("TelegramQml*");
    qRegisterMetaType<UserData*>("UserData*");

    qmlRegisterType<TelegramQml>("Cutegram", 1, 0, "Telegram");
    qmlRegisterType<ProfilesModel>("Cutegram", 1, 0, "ProfilesModel");
    qmlRegisterType<ProfilesModelItem>("Cutegram", 1, 0, "ProfilesModelItem");
    qmlRegisterType<TelegramMessagesModel>("Cutegram", 1, 0, "MessagesModel");
    qmlRegisterType<TelegramWallpapersModel>("Cutegram", 1, 0, "WallpapersModel");
    qmlRegisterType<TelegramDialogsModel>("Cutegram", 1, 0, "DialogsModel");
    qmlRegisterType<TelegramContactsModel>("Cutegram", 1, 0, "ContactsModel");
    qmlRegisterType<TelegramUploadsModel>("Cutegram", 1, 0, "UploadsModel");
    qmlRegisterType<TelegramChatParticipantsModel>("Cutegram", 1, 0, "ChatParticipantsModel");
    qmlRegisterType<Emojis>("Cutegram", 1, 0, "Emojis");
    qmlRegisterUncreatableType<UserData>("Cutegram", 1, 0, "UserData", "");

    init_languages();
}

QSize Cutegram::imageSize(const QString &path)
{
    QImageReader img(path);
    return img.size();
}

qreal Cutegram::htmlWidth(const QString &txt)
{
    p->doc->setHtml(txt);
    return p->doc->size().width() + 10;
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

    p->viewer = new AsemanQuickView(
#ifdef QT_DEBUG
                AsemanQuickView::AllExceptLogger
#else
                AsemanQuickView::AllComponents
#endif
                );
    p->viewer->engine()->rootContext()->setContextProperty( "Cutegram", this );
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

void Cutegram::close()
{
    p->close_blocker = false;
    p->viewer->close();
}

void Cutegram::quit()
{
    QGuiApplication::quit();
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

void Cutegram::setSysTrayCounter(int count)
{
    if( count == p->sysTrayCounter )
        return;

    const QImage & img = generateIcon( QImage(":/qml/Cutegram/files/systray.png"), count );
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
        QFile::copy(":/qml/Cutegram/files/systray.png",UNITY_ICON_PATH(0));

        p->unityTray = new UnitySystemTray( QCoreApplication::applicationName(), UNITY_ICON_PATH(0) );
        if( !p->unityTray->pntr() )
            QGuiApplication::setQuitOnLastWindowClosed(true);

        p->unityTray->addMenu( tr("Show"), this, "active" );
        p->unityTray->addMenu( tr("Configure"), this, "configure" );
        p->unityTray->addMenu( tr("About"), this, "about" );
        p->unityTray->addMenu( tr("About Aseman"), this, "aboutAseman" );
        p->unityTray->addMenu( tr("License"), this, "showLicense" );
        p->unityTray->addMenu( tr("Donate"), this, "showDonate" );
        p->unityTray->addMenu( tr("Quit"), this, "quit" );
    }
    if( !p->unityTray || !p->unityTray->pntr() )
    {
        p->sysTray = new QSystemTrayIcon( QIcon(":/qml/Cutegram/files/systray.png"), this );
        p->sysTray->show();

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
    QAction *abut_act = menu.addAction( tr("About") );
    QAction *sabt_act = menu.addAction( tr("About Aseman") );
    menu.addSeparator();
    QAction *lcns_act = menu.addAction( tr("License") );
    QAction *dnt_act  = menu.addAction( tr("Donate") );
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
        emit configureRequest();
        active();
    }
    else
    if( res_act == abut_act )
    {

    }
    else
    if( res_act == sabt_act )
    {
        emit aboutAsemanRequest();
        active();
    }
    else
    if( res_act == lcns_act )
    {

    }
    else
    if( res_act == dnt_act && dnt_act != 0 )
    {

    }
    else
    if( res_act == exit_act )
    {
        p->viewer->close();
        QGuiApplication::quit();
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

        QString  lang = QLocale::languageToString(locale.language());
        QVariant data = p->translationsPath + "/" + languages[i];

        p->languages.insert( lang, data );
        p->locales.insert( lang , locale );

        if( lang == AsemanApplication::settings()->value("General/Language","English").toString() )
            setLanguage( lang );
    }
    setLanguage( "English" );
}

Cutegram::~Cutegram()
{
    delete p;
}
