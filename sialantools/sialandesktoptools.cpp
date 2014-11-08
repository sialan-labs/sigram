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

#include "sialandesktoptools.h"

#include <QProcess>
#include <QStringList>
#include <QPalette>

class SialanDesktopToolsPrivate
{
public:
};

SialanDesktopTools::SialanDesktopTools(QObject *parent) :
    QObject(parent)
{
    p = new SialanDesktopToolsPrivate;
}

int SialanDesktopTools::desktopSession() const
{
    static int result = -1;
    if( result != -1 )
        return result;

#ifdef Q_OS_MAC
    result = SialanDesktopTools::Mac;
#else
#ifdef Q_OS_WIN
    result = SialanDesktopTools::Windows;
#else
    static QString *desktop_session = 0;
    if( !desktop_session )
        desktop_session = new QString( qgetenv("DESKTOP_SESSION") );

    if( desktop_session->contains("kde",Qt::CaseInsensitive) )
        result = SialanDesktopTools::Kde;
    else
    if( desktop_session->contains("ubuntu",Qt::CaseInsensitive) )
        result = SialanDesktopTools::Unity;
    else
    if( desktop_session->contains("gnome-fallback",Qt::CaseInsensitive) )
        result = SialanDesktopTools::GnomeFallBack;
    else
        result = SialanDesktopTools::Gnome;
#endif
#endif

    if( result == -1 )
        result = SialanDesktopTools::Unknown;

    return result;
}

QColor SialanDesktopTools::titleBarColor() const
{
    const int dsession = desktopSession();
    switch( dsession )
    {
    case SialanDesktopTools::Mac:
        return QColor("#C8C8C8");
        break;

    case SialanDesktopTools::Windows:
        return QColor("#E5E5E5");
        break;

    case SialanDesktopTools::Kde:
        return QPalette().window().color();
        break;

    case SialanDesktopTools::Unity:
    case SialanDesktopTools::GnomeFallBack:
    case SialanDesktopTools::Gnome:
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
            if( dsession == SialanDesktopTools::Unity )
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

QColor SialanDesktopTools::titleBarTransparentColor() const
{
    QColor color = titleBarColor();
    color.setAlpha(160);
    return color;
}

QColor SialanDesktopTools::titleBarTextColor() const
{
    const int dsession = desktopSession();
    switch( dsession )
    {
    case SialanDesktopTools::Mac:
        return QColor("#333333");
        break;

    case SialanDesktopTools::Windows:
        return QColor("#333333");
        break;

    case SialanDesktopTools::Kde:
        return QPalette().windowText().color();
        break;

    case SialanDesktopTools::Unity:
    case SialanDesktopTools::GnomeFallBack:
    case SialanDesktopTools::Gnome:
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
            if( dsession == SialanDesktopTools::Unity )
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

bool SialanDesktopTools::titleBarIsDark() const
{
    const QColor & clr = titleBarColor();
    qreal middle = (clr.green()+clr.red()+clr.blue())/3.0;
    if( middle>128 )
        return false;
    else
        return true;
}

SialanDesktopTools::~SialanDesktopTools()
{
    delete p;
}
