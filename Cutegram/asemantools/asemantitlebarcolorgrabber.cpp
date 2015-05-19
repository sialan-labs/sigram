#include "asemantitlebarcolorgrabber.h"

#include <QScreen>
#include <QPointer>
#include <QTimer>
#include <QDebug>
#include <QGuiApplication>

class AsemanTitleBarColorGrabberPrivate
{
public:
    QPointer<QWindow> window;
    QColor color;
    bool autoRefresh;
    int firstAttemps;

    QTimer *normalTimer;
    QTimer *activeTimer;
};

AsemanTitleBarColorGrabber::AsemanTitleBarColorGrabber(QObject *parent) :
    QObject(parent)
{
    p = new AsemanTitleBarColorGrabberPrivate;
    p->firstAttemps = 0;
    p->autoRefresh = false;

    p->normalTimer = new QTimer(this);
    p->normalTimer->setSingleShot(false);
    p->normalTimer->setInterval(10000);

    p->activeTimer = new QTimer(this);
    p->activeTimer->setSingleShot(true);
    p->activeTimer->setInterval(500);

    connect(p->normalTimer, SIGNAL(timeout()), SLOT(refresh()));
    connect(p->activeTimer, SIGNAL(timeout()), SLOT(refresh()));
}

void AsemanTitleBarColorGrabber::setWindow(QWindow *win)
{
    if(p->window == win)
        return;
    if(p->window)
        disconnect(win, SIGNAL(activeChanged()), this, SLOT(activeChanged()));

    p->window = win;
    if(p->window)
        connect(win, SIGNAL(activeChanged()), this, SLOT(activeChanged()));

    emit windowChanged();

    p->color = QColor();
    emit colorChanged();

    p->firstAttemps = 0;
    refresh();
}

QWindow *AsemanTitleBarColorGrabber::window() const
{
    return p->window;
}

void AsemanTitleBarColorGrabber::setAutoRefresh(bool stt)
{
    if(p->autoRefresh == stt)
        return;

    p->autoRefresh = stt;
    if(p->autoRefresh)
        p->normalTimer->start();
    else
        p->normalTimer->stop();

    emit autoRefreshChanged();
}

bool AsemanTitleBarColorGrabber::autoRefresh() const
{
    return p->autoRefresh;
}

QColor AsemanTitleBarColorGrabber::color() const
{
    return p->color;
}

void AsemanTitleBarColorGrabber::refresh()
{
    if(!p->window)
    {
        QColor color;
        if(p->color == color)
            return;

        p->color = color;
        emit colorChanged();
        return;
    }
    if(!p->window->isActive() || QGuiApplication::focusWindow() != p->window)
    {
        if(p->color == QColor())
            QTimer::singleShot(100, this, SLOT(refresh()));

        return;
    }
    p->firstAttemps++;
    if(p->firstAttemps < 6)
        QTimer::singleShot(300, this, SLOT(refresh()));

    QImage img = p->window->screen()->grabWindow(0, p->window->x()+100, p->window->y()-4, 1, 1).toImage();
    QColor color = img.pixel(0,0);
    if(p->color == color)
        return;

    p->color = color;
    emit colorChanged();
}

void AsemanTitleBarColorGrabber::activeChanged()
{
    p->activeTimer->stop();
    p->activeTimer->start();
}

AsemanTitleBarColorGrabber::~AsemanTitleBarColorGrabber()
{
    delete p;
}

