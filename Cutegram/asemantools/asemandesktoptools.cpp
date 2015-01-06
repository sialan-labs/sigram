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

#include "asemandesktoptools.h"

#include <QProcess>
#include <QStringList>
#include <QPalette>
#include <QEventLoop>
#include <QDebug>

#ifdef DESKTOP_DEVICE
#include <QColorDialog>
#include <QFileDialog>
#include <QMenu>
#include <QAction>
#endif

class AsemanDesktopToolsPrivate
{
public:
};

AsemanDesktopTools::AsemanDesktopTools(QObject *parent) :
    QObject(parent)
{
    p = new AsemanDesktopToolsPrivate;
}

int AsemanDesktopTools::desktopSession() const
{
    static int result = -1;
    if( result != -1 )
        return result;

#ifdef Q_OS_MAC
    result = AsemanDesktopTools::Mac;
#else
#ifdef Q_OS_WIN
    result = AsemanDesktopTools::Windows;
#else
    static QString *desktop_session = 0;
    if( !desktop_session )
        desktop_session = new QString( qgetenv("DESKTOP_SESSION") );

    if( desktop_session->contains("kde",Qt::CaseInsensitive) )
        result = AsemanDesktopTools::Kde;
    else
    if( desktop_session->contains("ubuntu",Qt::CaseInsensitive) )
        result = AsemanDesktopTools::Unity;
    else
    if( desktop_session->contains("gnome-fallback",Qt::CaseInsensitive) )
        result = AsemanDesktopTools::GnomeFallBack;
    else
        result = AsemanDesktopTools::Gnome;
#endif
#endif

    if( result == -1 )
        result = AsemanDesktopTools::Unknown;

    return result;
}

QColor AsemanDesktopTools::titleBarColor() const
{
    const int dsession = desktopSession();
    switch( dsession )
    {
    case AsemanDesktopTools::Mac:
        return QColor("#C8C8C8");
        break;

    case AsemanDesktopTools::Windows:
        return QColor("#E5E5E5");
        break;

    case AsemanDesktopTools::Kde:
        return QPalette().window().color();
        break;

    case AsemanDesktopTools::Unity:
    case AsemanDesktopTools::GnomeFallBack:
    case AsemanDesktopTools::Gnome:
    {
        static QColor *res = 0;
        if( !res )
        {
            QProcess prc;
            prc.start( "dconf", QStringList()<< "read"<< "/org/gnome/desktop/interface/gtk-theme" );
            prc.waitForStarted();
            prc.waitForFinished();
            QString sres = prc.readAll();
            sres.remove("\n").remove("'");
            sres = sres.toLower();

            if( sres == "ambiance" )
                res = new QColor("#403F3A");
            else
            if( sres == "radiance" )
                res = new QColor("#DFD7CF");
            else
            if( sres == "adwaita" )
                res = new QColor("#EDEDED");
            else
            if( dsession == AsemanDesktopTools::Unity )
                res = new QColor("#403F3A");
            else
                res = new QColor("#EDEDED");
        }

        return *res;
    }
        break;
    }

    return QColor("#EDEDED");
}

QColor AsemanDesktopTools::titleBarTransparentColor() const
{
    QColor color = titleBarColor();
    color.setAlpha(160);
    return color;
}

QColor AsemanDesktopTools::titleBarTextColor() const
{
    const int dsession = desktopSession();
    switch( dsession )
    {
    case AsemanDesktopTools::Mac:
        return QColor("#333333");
        break;

    case AsemanDesktopTools::Windows:
        return QColor("#333333");
        break;

    case AsemanDesktopTools::Kde:
        return QPalette().windowText().color();
        break;

    case AsemanDesktopTools::Unity:
    case AsemanDesktopTools::GnomeFallBack:
    case AsemanDesktopTools::Gnome:
    {
        static QColor *res = 0;
        if( !res )
        {
            QProcess prc;
            prc.start( "dconf", QStringList()<< "read"<< "/org/gnome/desktop/interface/gtk-theme" );
            prc.waitForStarted();
            prc.waitForFinished();
            QString sres = prc.readAll();
            sres.remove("\n").remove("'");
            sres = sres.toLower();

            if( sres == "ambiance" )
                res = new QColor("#eeeeee");
            else
            if( sres == "radiance" )
                res = new QColor("#333333");
            else
            if( sres == "adwaita" )
                res = new QColor("#333333");
            else
            if( dsession == AsemanDesktopTools::Unity )
                res = new QColor("#eeeeee");
            else
                res = new QColor("#333333");
        }

        return *res;
    }
        break;
    }

    return QColor("#333333");
}

bool AsemanDesktopTools::titleBarIsDark() const
{
    const QColor & clr = titleBarColor();
    qreal middle = (clr.green()+clr.red()+clr.blue())/3.0;
    if( middle>128 )
        return false;
    else
        return true;
}

QString AsemanDesktopTools::getOpenFileName(QWindow *window, const QString & title, const QString &filter, const QString &startPath)
{
#ifdef DESKTOP_DEVICE
    const int dsession = desktopSession();
    switch( dsession )
    {
    case AsemanDesktopTools::Kde:
        if( QFileInfo::exists("/usr/bin/kdialog") )
        {
            QStringList args = QStringList()<< "--title" << title << "--getopenfilename"
                                            << startPath << filter;
            if( window )
                args << "--attach" << QString::number(window->winId());

            QProcess process;
            QEventLoop loop;
            connect(&process, SIGNAL(finished(int)), &loop, SLOT(quit()), Qt::QueuedConnection );

            process.start("/usr/bin/kdialog", args );
            loop.exec(QEventLoop::ExcludeUserInputEvents);

            if( process.exitStatus() == QProcess::NormalExit )
                return QString(process.readAll()).remove("\n");
            else
                return QFileDialog::getOpenFileName(0, title, startPath, filter);
        }
        else
        {
            return QFileDialog::getOpenFileName(0, title, startPath, filter);
        }
        break;

    case AsemanDesktopTools::Mac:
    case AsemanDesktopTools::Windows:
    case AsemanDesktopTools::Unity:
    case AsemanDesktopTools::GnomeFallBack:
    case AsemanDesktopTools::Gnome:
        return QFileDialog::getOpenFileName(0, title, startPath, filter);
        break;
    }

    return QString();
#else
    Q_UNUSED(window)
    Q_UNUSED(title)
    Q_UNUSED(filter)
    Q_UNUSED(startPath)
    return QString();
#endif
}

QString AsemanDesktopTools::getSaveFileName(QWindow *window, const QString &title, const QString &filter, const QString &startPath)
{
#ifdef DESKTOP_DEVICE
    const int dsession = desktopSession();
    switch( dsession )
    {
    case AsemanDesktopTools::Kde:
        if( QFileInfo::exists("/usr/bin/kdialog") )
        {
            QStringList args = QStringList()<< "--title" << title << "--getsavefilename"
                                            << startPath << filter;
            if( window )
                args << "--attach" << QString::number(window->winId());

            QProcess process;
            QEventLoop loop;
            connect(&process, SIGNAL(finished(int)), &loop, SLOT(quit()), Qt::QueuedConnection );

            process.start("/usr/bin/kdialog", args );
            loop.exec(QEventLoop::ExcludeUserInputEvents);

            if( process.exitStatus() == QProcess::NormalExit )
                return QString(process.readAll()).remove("\n");
            else
                return QFileDialog::getSaveFileName(0, title, startPath, filter);
        }
        else
        {
            return QFileDialog::getSaveFileName(0, title, startPath, filter);
        }
        break;

    case AsemanDesktopTools::Mac:
    case AsemanDesktopTools::Windows:
    case AsemanDesktopTools::Unity:
    case AsemanDesktopTools::GnomeFallBack:
    case AsemanDesktopTools::Gnome:
        return QFileDialog::getSaveFileName(0, title, startPath, filter);
        break;
    }

    return QString();
#else
    Q_UNUSED(window)
    Q_UNUSED(title)
    Q_UNUSED(filter)
    Q_UNUSED(startPath)
    return QString();
#endif
}

QString AsemanDesktopTools::getExistingDirectory(QWindow *window, const QString &title, const QString &startPath)
{
#ifdef DESKTOP_DEVICE
    const int dsession = desktopSession();
    switch( dsession )
    {
    case AsemanDesktopTools::Kde:
        if( QFileInfo::exists("/usr/bin/kdialog") )
        {
            QStringList args = QStringList()<< "--title" << title << "--getexistingdirectory"
                                            << startPath;
            if( window )
                args << "--attach" << QString::number(window->winId());

            QProcess process;
            QEventLoop loop;
            connect(&process, SIGNAL(finished(int)), &loop, SLOT(quit()), Qt::QueuedConnection );

            process.start("/usr/bin/kdialog", args );
            loop.exec(QEventLoop::ExcludeUserInputEvents);

            if( process.exitStatus() == QProcess::NormalExit )
                return QString(process.readAll()).remove("\n");
            else
                return QFileDialog::getExistingDirectory(0, title, startPath);
        }
        else
        {
            return QFileDialog::getExistingDirectory(0, title, startPath);
        }
        break;

    case AsemanDesktopTools::Mac:
    case AsemanDesktopTools::Windows:
    case AsemanDesktopTools::Unity:
    case AsemanDesktopTools::GnomeFallBack:
    case AsemanDesktopTools::Gnome:
        return QFileDialog::getExistingDirectory(0, title, startPath);
        break;
    }

    return QString();
#else
    Q_UNUSED(window)
    Q_UNUSED(title)
    Q_UNUSED(startPath)
    return QString();
#endif
}

QColor AsemanDesktopTools::getColor(const QColor &color) const
{
#ifdef DESKTOP_DEVICE
    return QColorDialog::getColor(color);
#else
    return color;
#endif
}

int AsemanDesktopTools::showMenu(const QStringList &actions, QPoint point)
{
#ifdef DESKTOP_DEVICE
    if( point.isNull() )
        point = QCursor::pos();

    QMenu menu;
    QList<QAction*> pointers;
    foreach(const QString &act, actions)
        pointers << (act.isEmpty()? menu.addSeparator() : menu.addAction(act));

    QAction *res = menu.exec(point);
    return pointers.indexOf(res);
#else
    return -1;
#endif
}

AsemanDesktopTools::~AsemanDesktopTools()
{
    delete p;
}
