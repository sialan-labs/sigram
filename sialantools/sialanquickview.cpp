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

#include "sialanquickview.h"
#include "sialandesktoptools.h"
#include "sialanqtlogger.h"
#include "sialandevices.h"
#include "sialantools.h"
#include "sialanapplication.h"
#include "sialanhashobject.h"
#include "sialanlistobject.h"
#include "sialancalendarconverter.h"
#include "sialanimagecoloranalizor.h"
#include "sialanbackhandler.h"
#ifdef Q_OS_ANDROID
#include "sialanjavalayer.h"
#endif
#ifdef DESKTOP_LINUX
#include "sialanmimeapps.h"
#endif
#ifdef SIALAN_SENSORS
#include "sialansensors.h"
#endif
#ifdef SIALAN_NOTIFICATION
#include "sialannotification.h"
#endif

#include <QPointer>
#include <QSharedPointer>
#include <QtQml>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>

class SialanQuickViewPrivate
{
public:
    int options;

    SialanDesktopTools *desktop;
    SialanDevices *devices;
    SialanQtLogger *logger;
    SialanTools *tools;
#ifdef Q_OS_ANDROID
    SialanJavaLayer *java_layer;
#endif
    SialanCalendarConverter *calendar;
    SialanBackHandler *back_handler;

    QPointer<QQuickItem> root;
    QPointer<QQuickItem> focused_text;

    bool fullscreen;
    int layoutDirection;
};

SialanQuickView::SialanQuickView(int options, QWindow *parent) :
    QQuickView(parent)
{
    p = new SialanQuickViewPrivate;
    p->options = options;
    p->desktop = 0;
    p->devices = 0;
    p->logger = 0;
    p->tools = 0;
#ifdef Q_OS_ANDROID
    p->java_layer = 0;
#endif
    p->calendar = 0;
    p->back_handler = 0;
    p->fullscreen = false;
    p->layoutDirection = Qt::LeftToRight;

    engine()->rootContext()->setContextProperty( "SApp", SialanApplication::instance() );
    engine()->rootContext()->setContextProperty( "View", this );

    qmlRegisterType<SialanHashObject>("SialanTools", 1,0, "HashObject");
    qmlRegisterType<SialanListObject>("SialanTools", 1,0, "ListObject");
    qmlRegisterType<SialanImageColorAnalizor>("SialanTools", 1,0, "ImageColorAnalizor");
#ifdef DESKTOP_LINUX
    qmlRegisterType<SialanMimeApps>("SialanTools", 1,0, "MimeApps");
#endif
#ifdef SIALAN_SENSORS
    qmlRegisterType<SialanSensors>("SialanTools", 1,0, "SialanSensors");
#endif
#ifdef SIALAN_NOTIFICATION
    qmlRegisterType<SialanNotification>("SialanTools", 1,0, "SialanNotification");
#endif

    setResizeMode(QQuickView::SizeRootObjectToView);
    init_options();

    engine()->setImportPathList( QStringList()<< engine()->importPathList() << "qrc:///sialantools/qml" );

    engine()->rootContext()->setContextProperty("flickVelocity",
#ifdef DESKTOP_DEVICE
                                                2500
#else
                                                25000
#endif
                                                );
}

SialanDesktopTools *SialanQuickView::desktopTools() const
{
    return p->desktop;
}

SialanDevices *SialanQuickView::devices() const
{
    return p->devices;
}

SialanQtLogger *SialanQuickView::qtLogger() const
{
    return p->logger;
}

SialanTools *SialanQuickView::tools() const
{
    return p->tools;
}

#ifdef Q_OS_ANDROID
SialanJavaLayer *SialanQuickView::javaLayer() const
{
    return p->java_layer;
}
#endif

SialanCalendarConverter *SialanQuickView::calendar() const
{
    return p->calendar;
}

SialanBackHandler *SialanQuickView::backHandler() const
{
    return p->back_handler;
}

void SialanQuickView::setFullscreen(bool stt)
{
    if( p->fullscreen == stt )
        return;

    p->fullscreen = stt;

    if( p->fullscreen )
        showFullScreen();
    else
        showNormal();

    emit fullscreenChanged();
    emit navigationBarHeightChanged();
    emit statusBarHeightChanged();
}

bool SialanQuickView::fullscreen() const
{
    return p->fullscreen;
}

qreal SialanQuickView::statusBarHeight() const
{
    if( !p->devices )
        return 0;

    return p->devices->transparentStatusBar() && !fullscreen()? 20*p->devices->density() : 0;
}

qreal SialanQuickView::navigationBarHeight() const
{
    if( !p->devices )
        return 0;

    return p->devices->transparentNavigationBar() && !fullscreen()? 45*p->devices->density() : 0;
}

void SialanQuickView::setRoot(QQuickItem *root)
{
    if( p->root == root )
        return;

    p->root = root;
    emit rootChanged();
}

QQuickItem *SialanQuickView::root() const
{
    if( p->root )
        return p->root;

    return rootObject();
}

void SialanQuickView::setFocusedText(QQuickItem *item)
{
    if( p->focused_text == item )
        return;
    if( p->focused_text )
        disconnect( p->focused_text, SIGNAL(destroyed()), this, SIGNAL(focusedTextChanged()) );

    p->focused_text = item;
    if( item )
    {
        connect( item, SIGNAL(destroyed()), this, SIGNAL(focusedTextChanged()) );
        if( p->devices )
            p->devices->showKeyboard();
    }
    else
    {
        if( p->devices )
            p->devices->hideKeyboard();
    }

    emit focusedTextChanged();
}

QQuickItem *SialanQuickView::focusedText() const
{
    return p->focused_text;
}

int SialanQuickView::layoutDirection() const
{
    return p->layoutDirection;
}

void SialanQuickView::setLayoutDirection(int l)
{
    if( l == p->layoutDirection )
        return;

    p->layoutDirection = l;
    emit layoutDirectionChanged();
}

void SialanQuickView::discardFocusedText()
{
    setFocusedText(0);
}

void SialanQuickView::init_options()
{
    if( p->options & DesktopTools && !p->desktop )
    {
        p->desktop = new SialanDesktopTools(this);
        engine()->rootContext()->setContextProperty( "Desktop", p->desktop );
    }
    if( p->options & Devices && !p->devices )
    {
        p->devices = new SialanDevices(this);
        engine()->rootContext()->setContextProperty( "Devices", p->devices );

        engine()->rootContext()->setContextProperty( "physicalPlatformScale", p->devices->density());
        engine()->rootContext()->setContextProperty( "fontsScale", p->devices->fontDensity());
    }
    if( p->options & QtLogger && !p->logger )
    {
        p->logger = new SialanQtLogger(SialanApplication::logPath(),this);
        engine()->rootContext()->setContextProperty( "Logger", p->logger );
    }
    if( p->options & Tools && !p->tools )
    {
        p->tools = new SialanTools(this);
        engine()->rootContext()->setContextProperty( "Tools", p->tools );
    }
#ifdef Q_OS_ANDROID
    if( p->options & JavaLayer && !p->java_layer )
    {
        p->java_layer = SialanJavaLayer::instance();
        engine()->rootContext()->setContextProperty( "JavaLayer", p->java_layer );
    }
#endif
    if( p->options & Calendar && !p->calendar )
    {
        p->calendar = new SialanCalendarConverter(this);
        engine()->rootContext()->setContextProperty( "CalendarConv", p->calendar );
    }
    if( p->options & BackHandler && !p->back_handler )
    {
        p->back_handler = new SialanBackHandler(this);
        engine()->rootContext()->setContextProperty( "BackHandler", p->back_handler );
    }
}

SialanQuickView::~SialanQuickView()
{
    delete p;
}
