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

#define LINUX_DEFAULT_DPI 96
#define WINDOWS_DEFAULT_DPI 96
#define UTOUCH_DEFAULT_DPI 76

#include "asemandevices.h"
#include "asemanapplication.h"

#ifdef Q_OS_ANDROID
#include "asemanjavalayer.h"
#endif

#include <QTimerEvent>
#include <QGuiApplication>
#include <QMimeType>
#include <QMimeDatabase>
#include <QUrl>
#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QClipboard>
#include <QtCore/qmath.h>
#include <QScreen>
#include <QDateTime>
#include <QDebug>
#include <QMimeData>

class AsemanDevicesPrivate
{
public:
    int hide_keyboard_timer;
    bool keyboard_stt;

    QMimeDatabase mime_db;

#ifdef Q_OS_ANDROID
    AsemanJavaLayer *java_layer;
#endif
};

AsemanDevices::AsemanDevices(QObject *parent) :
    QObject(parent)
{
    p = new AsemanDevicesPrivate;
    p->hide_keyboard_timer = 0;
    p->keyboard_stt = false;

#ifdef Q_OS_ANDROID
    p->java_layer = AsemanJavaLayer::instance();

    connect( p->java_layer, SIGNAL(incomingShare(QString,QString)), SLOT(incoming_share(QString,QString)), Qt::QueuedConnection );
    connect( p->java_layer, SIGNAL(incomingImage(QString))        , SLOT(incoming_image(QString))        , Qt::QueuedConnection );
    connect( p->java_layer, SIGNAL(selectImageResult(QString))    , SLOT(select_image_result(QString))   , Qt::QueuedConnection );
    connect( p->java_layer, SIGNAL(activityPaused())              , SLOT(activity_paused())              , Qt::QueuedConnection );
    connect( p->java_layer, SIGNAL(activityResumed())             , SLOT(activity_resumed())             , Qt::QueuedConnection );
#endif

    connect( QGuiApplication::inputMethod(), SIGNAL(visibleChanged()), SLOT(keyboard_changed()) );
    connect( static_cast<QGuiApplication*>(QCoreApplication::instance())->clipboard(), SIGNAL(dataChanged()), SIGNAL(clipboardChanged()) );

    QScreen *scr = screen();
    if( scr )
        connect( scr, SIGNAL(geometryChanged(QRect)), SIGNAL(geometryChanged()) );
}

bool AsemanDevices::isMobile() const
{
    return isTouchDevice() && !isTablet();
}

bool AsemanDevices::isTablet() const
{
#ifdef Q_OS_ANDROID
    return isTouchDevice() && p->java_layer->isTablet();
#else
    return isTouchDevice() && lcdPhysicalSize() >= 6;
#endif
}

bool AsemanDevices::isLargeTablet() const
{
#ifdef Q_OS_ANDROID
    return isTablet() && p->java_layer->getSizeName() == 3;
#else
    return isTouchDevice() && lcdPhysicalSize() >= 9;
#endif
}

bool AsemanDevices::isTouchDevice() const
{
    return isAndroid() || isIOS() || isWindowsPhone() || isUbuntuTouch();
}

bool AsemanDevices::isDesktop() const
{
    return !isTouchDevice();
}

bool AsemanDevices::isMacX() const
{
#ifdef Q_OS_MAC
    return true;
#else
    return false;
#endif
}

bool AsemanDevices::isWindows() const
{
#ifdef Q_OS_WIN
    return true;
#else
    return false;
#endif
}

bool AsemanDevices::isLinux() const
{
#ifdef Q_OS_LINUX
    return true;
#else
    return false;
#endif
}

bool AsemanDevices::isAndroid() const
{
#ifdef Q_OS_ANDROID
    return true;
#else
    return false;
#endif
}

bool AsemanDevices::isIOS() const
{
#ifdef Q_OS_IOS
    return true;
#else
    return false;
#endif
}

bool AsemanDevices::isUbuntuTouch() const
{
#ifdef Q_OS_UBUNTUTOUCH
    return true;
#else
    return false;
#endif
}

bool AsemanDevices::isWindowsPhone() const
{
#ifdef Q_OS_WINPHONE
    return true;
#else
    return false;
#endif
}

QScreen *AsemanDevices::screen() const
{
    const QList<QScreen*> & screens = QGuiApplication::screens();
    if( screens.isEmpty() )
        return 0;

    return screens.first();
}

QObject *AsemanDevices::screenObj() const
{
    return screen();
}

qreal AsemanDevices::lcdPhysicalSize() const
{
    qreal w = lcdPhysicalWidth();
    qreal h = lcdPhysicalHeight();

    return qSqrt( h*h + w*w );
}

qreal AsemanDevices::lcdPhysicalWidth() const
{
    if( QGuiApplication::screens().isEmpty() )
        return 0;

    QScreen *scr = QGuiApplication::screens().first();
    return (qreal)scr->size().width()/scr->physicalDotsPerInchX();
}

qreal AsemanDevices::lcdPhysicalHeight() const
{
    if( QGuiApplication::screens().isEmpty() )
        return 0;

    QScreen *scr = QGuiApplication::screens().first();
    return (qreal)scr->size().height()/scr->physicalDotsPerInchY();
}

qreal AsemanDevices::lcdDpiX() const
{
    if( QGuiApplication::screens().isEmpty() )
        return 0;

    QScreen *scr = QGuiApplication::screens().first();
    return scr->physicalDotsPerInchX();
}

qreal AsemanDevices::lcdDpiY() const
{
    if( QGuiApplication::screens().isEmpty() )
        return 0;

    QScreen *scr = QGuiApplication::screens().first();
    return scr->physicalDotsPerInchY();
}

QSize AsemanDevices::screenSize() const
{
    if( QGuiApplication::screens().isEmpty() )
        return QSize();

    QScreen *scr = QGuiApplication::screens().first();
    return scr->size();
}

qreal AsemanDevices::keyboardHeight() const
{
#ifdef Q_OS_UBUNTUTOUCH
    return screenSize().height()*0.5;
#else
    const QSize & scr_size = screenSize();
    bool portrait = scr_size.width()<scr_size.height();
    if( portrait )
    {
        if( isMobile() )
            return screenSize().height()*0.6;
        else
            return screenSize().height()*0.4;
    }
    else
    {
        if( isMobile() )
            return screenSize().height()*0.7;
        else
            return screenSize().height()*0.5;
    }
#endif
}

bool AsemanDevices::transparentStatusBar() const
{
#ifdef Q_OS_ANDROID
    return p->java_layer->transparentStatusBar();
#else
    return false;
#endif
}

bool AsemanDevices::transparentNavigationBar() const
{
#ifdef Q_OS_ANDROID
    return p->java_layer->transparentNavigationBar();
#else
    return false;
#endif
}

qreal AsemanDevices::standardTitleBarHeight() const
{
    return 50*density();
}

int AsemanDevices::densityDpi() const
{
#ifdef Q_OS_ANDROID
    return p->java_layer->densityDpi();
#else
    return lcdDpiX();
#endif
}

qreal AsemanDevices::density() const
{
#ifdef Q_OS_ANDROID
    qreal ratio = isTablet()? 1.28 : 1;
//    if( isLargeTablet() )
//        ratio = 1.6;

    return p->java_layer->density()*ratio;
#else
#ifdef Q_OS_IOS
    qreal ratio = isTablet()? 1.28 : 1;
    return ratio*densityDpi()/180.0;
#else
#ifdef Q_OS_LINUX
#ifdef Q_OS_UBUNTUTOUCH
    return screen()->logicalDotsPerInch()/UTOUCH_DEFAULT_DPI;
#else
    return screen()->logicalDotsPerInch()/LINUX_DEFAULT_DPI;
#endif
#else
#ifdef Q_OS_WIN32
    return 0.95*screen()->logicalDotsPerInch()/WINDOWS_DEFAULT_DPI;
#else
    return 1;
#endif
#endif
#endif
#endif
}

qreal AsemanDevices::fontDensity() const
{
#ifdef Q_OS_ANDROID
    qreal ratio = (1.28)*1.35;
    return p->java_layer->density()*ratio;
#else
#ifdef Q_OS_IOS
    return 1.4;
#else
#ifdef Q_OS_LINUX
#ifdef Q_OS_UBUNTUTOUCH
    qreal ratio = 1.3;
    return ratio*density();
#else
    qreal ratio = 1.3;
    return ratio*density();
#endif
#else
#ifdef Q_OS_WIN32
    qreal ratio = 1.4;
    return ratio*density();
#else
    qreal ratio = 1.3;
    return ratio*density();
#endif
#endif
#endif
#endif
}

QString AsemanDevices::localFilesPrePath()
{
#ifdef Q_OS_WIN
    return "file:///";
#else
    return "file://";
#endif
}

QString AsemanDevices::clipboard() const
{
    return QGuiApplication::clipboard()->text();
}

bool AsemanDevices::keyboard() const
{
    return p->keyboard_stt;
}

QList<QUrl> AsemanDevices::clipboardUrl() const
{
    return QGuiApplication::clipboard()->mimeData()->urls();
}

void AsemanDevices::setClipboardUrl(const QList<QUrl> &urls)
{
    QString data = "copy";

    foreach( const QUrl &url, urls )
        data += "\nfile://" + url.toLocalFile();

    QMimeData *mime = new QMimeData();
    mime->setUrls(urls);
    mime->setData( "x-special/gnome-copied-files", data.toUtf8() );

    QGuiApplication::clipboard()->setMimeData(mime);
}

QString AsemanDevices::cameraLocation()
{
    return AsemanApplication::cameraPath();
}

QString AsemanDevices::picturesLocation()
{
    QStringList probs;
    probs = QStandardPaths::standardLocations( QStandardPaths::PicturesLocation );

#ifdef Q_OS_ANDROID
    probs << "/sdcard/Pictures";
#else
    probs << QDir::homePath() + "/Pictures";
#endif

    foreach( const QString & prob, probs )
        if( QFile::exists(prob) )
            return prob;

    return probs.last();
}

QString AsemanDevices::musicsLocation()
{
    QStringList probs;
    probs = QStandardPaths::standardLocations( QStandardPaths::MusicLocation );

#ifdef Q_OS_ANDROID
    probs << "/sdcard/Music";
#else
    probs << QDir::homePath() + "/Music";
#endif

    foreach( const QString & prob, probs )
        if( QFile::exists(prob) )
            return prob;

    return probs.last();
}

QString AsemanDevices::documentsLocation()
{
    QStringList probs;
    probs = QStandardPaths::standardLocations( QStandardPaths::DocumentsLocation );

#ifdef Q_OS_ANDROID
    probs << "/sdcard/documents";
    probs << "/sdcard/Documents";
#else
    probs << QDir::homePath() + "/Documents";
#endif

    foreach( const QString & prob, probs )
        if( QFile::exists(prob) )
            return prob;

    return probs.last();
}

QString AsemanDevices::resourcePath()
{
#ifdef Q_OS_ANDROID
    return "assets:";
#else
#ifndef Q_OS_MAC
    QString result = QCoreApplication::applicationDirPath() + "/../share/" + QCoreApplication::applicationName().toLower();
    QFileInfo file(result);
    if(file.exists() && file.isDir())
        return file.filePath();
    else
        return QCoreApplication::applicationDirPath() + "/";
#else
    return QCoreApplication::applicationDirPath() + "/../Resources/";
#endif
#endif
}

QString AsemanDevices::resourcePathQml()
{
#ifdef Q_OS_ANDROID
    return resourcePath();
#else
    return localFilesPrePath() + resourcePath();
#endif
}

QString AsemanDevices::libsPath()
{
#ifndef Q_OS_MAC
    QString result = QCoreApplication::applicationDirPath() + "/../lib/" + QCoreApplication::applicationName().toLower();
    QFileInfo file(result);
    if(file.exists() && file.isDir())
        return file.filePath();
    else
        return QCoreApplication::applicationDirPath() + "/";
#else
    return QCoreApplication::applicationDirPath() + "/../Resources/";
#endif
}

void AsemanDevices::hideKeyboard()
{
#ifndef DESKTOP_DEVICE
    if( p->hide_keyboard_timer )
        killTimer(p->hide_keyboard_timer);

    p->hide_keyboard_timer = startTimer(250);
#endif
}

void AsemanDevices::showKeyboard()
{
#ifndef DESKTOP_DEVICE
    if( p->hide_keyboard_timer )
    {
        killTimer(p->hide_keyboard_timer);
        p->hide_keyboard_timer = 0;
    }

    QGuiApplication::inputMethod()->show();
    p->keyboard_stt = true;

    emit keyboardChanged();
#endif
}

void AsemanDevices::share(const QString &subject, const QString &message)
{
#ifdef Q_OS_ANDROID
    p->java_layer->sharePaper( subject, message );
#else
    QString adrs = QString("mailto:%1?subject=%2&body=%3").arg(QString(),subject,message);
    QDesktopServices::openUrl( adrs );
#endif
}

void AsemanDevices::openFile(const QString &address)
{
#ifdef Q_OS_ANDROID
    const QMimeType & t = p->mime_db.mimeTypeForFile(address);
    p->java_layer->openFile( address, t.name() );
#else
    QDesktopServices::openUrl( QUrl(address) );
#endif
}

void AsemanDevices::shareFile(const QString &address)
{
#ifdef Q_OS_ANDROID
    const QMimeType & t = p->mime_db.mimeTypeForFile(address);
    p->java_layer->shareFile( address, t.name() );
#else
    QDesktopServices::openUrl( QUrl(address) );
#endif
}

void AsemanDevices::setClipboard(const QString &text)
{
    QGuiApplication::clipboard()->setText( text );
}

bool AsemanDevices::startCameraPicture()
{
#ifdef Q_OS_ANDROID
    return p->java_layer->startCamera( cameraLocation() + "/aseman_" + QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch()) + ".jpg" );
#else
    return false;
#endif
}

bool AsemanDevices::getOpenPictures()
{
#ifdef Q_OS_ANDROID
    return p->java_layer->getOpenPictures();
#else
    return false;
#endif
}

void AsemanDevices::incoming_share(const QString &title, const QString &msg)
{
    emit incomingShare(title,msg);
}

void AsemanDevices::incoming_image(const QString &path)
{
    emit incomingImage(path);
}

void AsemanDevices::select_image_result(const QString &path)
{
    emit selectImageResult(path);
}

void AsemanDevices::activity_paused()
{
    emit activityPaused();
}

void AsemanDevices::activity_resumed()
{
    emit activityResumed();
}

void AsemanDevices::keyboard_changed()
{
    emit keyboardChanged();
}

void AsemanDevices::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->hide_keyboard_timer )
    {
        killTimer(p->hide_keyboard_timer);
        p->hide_keyboard_timer = 0;

        QGuiApplication::inputMethod()->hide();
        p->keyboard_stt = false;

        emit keyboardChanged();
    }
}

AsemanDevices::~AsemanDevices()
{
    delete p;
}
