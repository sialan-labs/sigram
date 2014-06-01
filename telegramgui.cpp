#define NOTIFY_ACT_SHOW 0
#define NOTIFY_ACT_MUTE 1
#define NOTIFY_ACT_RMND 2

#include "telegramgui.h"
#include "notification.h"
#include "unitysystemtray.h"
#include "telegram_macros.h"
#include "userdata.h"
#include "telegram/telegram.h"

#include <QtQml>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QClipboard>
#include <QMimeData>
#include <QDebug>
#include <QHash>
#include <QFileDialog>
#include <QFile>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QScreen>
#include <QAction>
#include <QPointer>
#include <QSettings>
#include <QQuickItem>
#include <QDesktopServices>
#include <QQuickWindow>
#include <QDir>

QPointer<QSettings> tg_settings;

class TelegramGuiPrivate
{
public:
    Notification *notify;
    UserData *userdata;

    QSystemTrayIcon *sysTray;
    UnitySystemTray *unityTray;

    QQmlApplicationEngine *engine;
    Telegram *tg;

    char *args;

    QQuickWindow *root;
    QHash<int,bool> mutes;

    QString background;
};

TelegramGui::TelegramGui(QObject *parent) :
    QObject(parent)
{
    p = new TelegramGuiPrivate;
    p->engine = 0;
    p->tg = 0;
    p->args = QGuiApplication::arguments().first().toUtf8().data();

    QDir().mkpath(HOME_PATH);
    if( !tg_settings )
        tg_settings = new QSettings( HOME_PATH + "/telegram.conf", QSettings::IniFormat, this);

    p->background = tg_settings->value( "General/background", QString() ).toString();
    p->notify = new Notification(this);

    connect( p->notify, SIGNAL(notifyAction(uint,QString)), SLOT(notify_action(uint,QString)) );

    qmlRegisterType<Enums>("org.sialan.telegram", 1, 0, "Enums");
}

QSettings *TelegramGui::settings()
{
    return tg_settings;
}

void TelegramGui::setMute(int id, bool stt)
{
    if( p->mutes.value(id) == stt )
        return;

    p->mutes.insert(id, stt);
    emit muted(id, stt);
}

bool TelegramGui::isMuted(int id) const
{
    return p->mutes.value(id);
}

QSize TelegramGui::screenSize() const
{
    const QList<QScreen*> & list = QGuiApplication::screens();
    if( list.isEmpty() )
        return QSize();

    return list.first()->size();
}

QPoint TelegramGui::mousePos() const
{
    return QCursor::pos();
}

QPoint TelegramGui::mapToGlobal(QQuickItem *item, const QPoint &pnt)
{
    return item->window()->mapToGlobal( item->mapToScene(pnt).toPoint() );
}

QPoint TelegramGui::mapToScene(QQuickItem *item, const QPoint &pnt)
{
    return item->mapToScene(pnt).toPoint();
}

QString TelegramGui::appPath() const
{
    return QCoreApplication::applicationDirPath() + "/";
}

QStringList TelegramGui::fonts() const
{
    return fontsOf(appPath() + "/fonts");
}

QStringList TelegramGui::fontsOf(const QString &path) const
{
    QStringList res;
    const QStringList & list = QDir(path).entryList(QStringList() << "*.ttf", QDir::Files);
    foreach( const QString & f, list )
        res << path + "/" + f;

    const QStringList & dirs = QDir(path).entryList(QDir::Dirs|QDir::NoDotAndDotDot);
    foreach( const QString & d, dirs )
        res << fontsOf( path + "/" + d );

    return res;
}

void TelegramGui::setBackground(const QString &path)
{
    if( path == p->background )
        return;

    p->background = path;
    tg_settings->setValue( "General/background", p->background );
    emit backgroundChanged();
}

QString TelegramGui::background() const
{
    return p->background;
}

QString TelegramGui::getOpenFile()
{
    return QFileDialog::getOpenFileName();
}

int TelegramGui::desktopSession()
{
    static int result = -1;
    if( result != -1 )
        return result;

#ifdef Q_OS_MAC
    result = Enums::Mac;
#else
#ifdef Q_OS_WIN
    result = Enums::Windows;
#else
    static QString *desktop_session = 0;
    if( !desktop_session )
        desktop_session = new QString( qgetenv("DESKTOP_SESSION") );

    if( desktop_session->contains("kde",Qt::CaseInsensitive) )
        result = Enums::Kde;
    else
    if( desktop_session->contains("ubuntu",Qt::CaseInsensitive) )
        result = Enums::Unity;
    else
        result = Enums::Gnome;
#endif
#endif

    if( result == -1 )
        result = Enums::Unknown;

    return result;
}

void TelegramGui::start()
{
    if( p->engine )
        return;

    p->tg = new Telegram(1,&(p->args));
    p->userdata = new UserData(this);

    p->engine = new QQmlApplicationEngine(this);
    p->engine->rootContext()->setContextProperty( "Telegram", p->tg );
    p->engine->rootContext()->setContextProperty( "Gui", this );
    p->engine->rootContext()->setContextProperty( "UserData", p->userdata );
    p->engine->load(QUrl(QStringLiteral("qrc:///main.qml")));

    p->root = static_cast<QQuickWindow*>(p->engine->rootObjects().first());

    if( desktopSession() == Enums::Unity )
    {
        QFile::copy(":/files/sys_tray.png","/tmp/sialan-telegram-client-trayicon.png");

        p->unityTray = new UnitySystemTray( QCoreApplication::applicationName(), "/tmp/sialan-telegram-client-trayicon.png" );
        p->unityTray->addMenu( tr("Show"), this, "show" );
        p->unityTray->addMenu( tr("Configure"), this, "configure" );
        p->unityTray->addMenu( tr("About"), this, "about" );
        p->unityTray->addMenu( tr("Quit"), this, "quit" );
    }
    else
    {
        p->sysTray = new QSystemTrayIcon( QIcon(":/files/sys_tray.png"), this );
        p->sysTray->show();

        connect( p->sysTray, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), SLOT(systray_action(QSystemTrayIcon::ActivationReason)) );
    }
}

void TelegramGui::sendNotify(quint64 msg_id)
{
    QStringList actions;
    if( desktopSession() != Enums::Unity )
    {
        actions << QString("%1:%2").arg(NOTIFY_ACT_SHOW).arg(msg_id) << tr("Show");
        actions << QString("%1:%2").arg(NOTIFY_ACT_MUTE).arg(msg_id) << tr("Mute");
//        actions << QString("%1:%2").arg(NOTIFY_ACT_RMND).arg(msg_id) << tr("Mute & Remind");
    }

    int to_id = p->tg->messageToId(msg_id);
    int from_id = p->tg->messageFromId(msg_id);
    if( from_id == p->tg->me() )
        return;
    if( isMuted(to_id) || isMuted(from_id) )
        return;

    QString title = p->tg->messageFromName(msg_id);
    QString icon = p->tg->getPhotoPath(from_id);
    QString body = p->tg->messageBody(msg_id);
    if( p->tg->dialogIsChat(to_id) )
        title += tr("at %1").arg(p->tg->dialogTitle(to_id));
    else
    if( p->tg->dialogIsChat(from_id) )
        title += tr("at %1").arg(p->tg->dialogTitle(from_id));

    p->notify->sendNotify( title, body, icon, 0, 3000, actions );
}

void TelegramGui::openFile(const QString &file)
{
    QDesktopServices::openUrl( QUrl(file) );
}

void TelegramGui::copyFile(const QString &file)
{
    QStringList paths;
    paths << file;

    QList<QUrl> urls;
    QString data = "copy";

    foreach( const QString & p, paths ) {
        QUrl url = QUrl::fromLocalFile(p);
        urls << url;
        data += "\nfile://" + url.toLocalFile();
    }

    QMimeData *mimeData = new QMimeData();
    mimeData->setUrls( urls );
    mimeData->setData( "x-special/gnome-copied-files", data.toUtf8() );

    QGuiApplication::clipboard()->setMimeData(mimeData);
}

void TelegramGui::saveFile(const QString &file)
{
    const QString & path = QFileDialog::getSaveFileName();
    if( path.isEmpty() )
        return;

    QFile::copy( file, path );
}

void TelegramGui::copyText(const QString &txt)
{
    QGuiApplication::clipboard()->setText( txt );
}

int TelegramGui::showMenu(const QStringList &list)
{
    QMenu menu;

    QList<QAction*> actions;
    foreach( const QString & l, list )
        actions << (l.isEmpty()? menu.addSeparator() : menu.addAction(l));

    menu.move( QCursor::pos() );
    QAction *res = menu.exec();

    return actions.indexOf(res);
}

void TelegramGui::notify_action(uint id, const QString &act)
{
    Q_UNUSED(id)
    const QStringList & splits = act.split(":");
    if( splits.count() != 2 )
        return;

    uint act_id = splits.at(0).toUInt();
    quint64 msg_id = splits.at(1).toULongLong();

    int to_id = p->tg->messageToId(msg_id);
    int from_id = p->tg->messageFromId(msg_id);
    int current = from_id;
    if( p->tg->dialogIsChat(to_id) )
        current = to_id;

    switch (act_id) {
    case NOTIFY_ACT_SHOW:
        p->root->setVisible( true );
        p->root->setProperty( "current", current );
        p->root->requestActivate();
        p->notify->closeNotification(id);
        break;

    case NOTIFY_ACT_MUTE:
        setMute( current, true );
        p->notify->closeNotification(id);
        break;

    case NOTIFY_ACT_RMND:
        break;
    }
}

void TelegramGui::systray_action(QSystemTrayIcon::ActivationReason act)
{
    switch( static_cast<int>(act) )
    {
    case QSystemTrayIcon::Trigger:
        if( p->root->isVisible() && p->root->isActive() )
            p->root->hide();
        else
        {
            p->root->setVisible( true );
            p->root->requestActivate();
        }
        break;

    case QSystemTrayIcon::Context:
        showContextMenu();
        break;
    }
}

void TelegramGui::showContextMenu()
{
    QMenu menu;
    menu.move( QCursor::pos() );

    QAction *show_act = menu.addAction( tr("Show") );
    menu.addSeparator();
    QAction *conf_act = menu.addAction( tr("Configure") );
    QAction *abut_act = menu.addAction( tr("About") );
    menu.addSeparator();
    QAction *exit_act = menu.addAction( tr("Exit") );
    QAction *res_act  = menu.exec();

    if( res_act == show_act )
        show();
    else
    if( res_act == conf_act )
        configure();
    else
    if( res_act == abut_act )
        about();
    else
    if( res_act == exit_act )
        quit();
}

void TelegramGui::configure()
{
    p->root->setVisible( true );
    p->root->requestActivate();
    QMetaObject::invokeMethod( p->root, "showMyConfigure" );
}

void TelegramGui::about()
{
    p->root->setVisible( true );
    p->root->requestActivate();
    p->root->setProperty( "about", !p->root->property("about").toBool() );
    p->root->setProperty( "focus", true );
}

void TelegramGui::quit()
{
    QCoreApplication::quit();
}

void TelegramGui::show()
{
    p->root->setVisible( true );
    p->root->requestActivate();
}

TelegramGui::~TelegramGui()
{
    delete p;
}
