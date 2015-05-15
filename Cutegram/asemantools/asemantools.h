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

#ifndef ASEMANTOOLS_H
#define ASEMANTOOLS_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>
#include <QDateTime>
#include <QSize>
#include <QStringList>
#include <QUrl>

class AsemanToolsPrivate;
class AsemanTools : public QObject
{
    Q_OBJECT
public:
    AsemanTools(QObject *parent = 0);
    ~AsemanTools();

public slots:
    static void debug( const QVariant & var );

    static QDateTime currentDate();
    static QString dateToMSec(const QDateTime &dt);
    static QDateTime mSecToDate(const QString &ms);
    static QString dateToString(const QDateTime &dt, const QString &format = QString());

    static QString fileName( const QString & path );
    static QString fileSuffix( const QString & path );
    static QString readText( const QString & path );
    static QStringList filesOf(const QString &path);

    static QStringList stringLinks(const QString &str);

    static QUrl stringToUrl(const QString &path);

    static QString qtVersion();
    static QString aboutAseman();

    static void deleteItemDelay( QObject *o, int ms );

    static qreal colorHue( const QColor & clr );
    static qreal colorLightness( const QColor & clr );
    static qreal colorSaturation( const QColor & clr );

    static void mkDir(const QString &dir);

    static QVariantMap colorHsl( const QColor & clr );

    static bool createVideoThumbnail(const QString &video, const QString &output, QString ffmpegPath = QString());

    static QString translateNumbers( QString input );
    static QString passToMd5( const QString & pass );
    static QString createUuid();

    static QString htmlToPlaintText(const QString &html);

    static void copyDirectory( const QString & src, const QString & dst );

    static void setProperty( QObject *obj, const QString & property, const QVariant & v );
    static QVariant property( QObject *obj, const QString & property );

    static Qt::LayoutDirection directionOf( const QString & str );
    static QVariant call( QObject *obj, const QString & member, Qt::ConnectionType type,
                                                                const QVariant & v0 = QVariant(),
                                                                const QVariant & v1 = QVariant(),
                                                                const QVariant & v2 = QVariant(),
                                                                const QVariant & v3 = QVariant(),
                                                                const QVariant & v4 = QVariant(),
                                                                const QVariant & v5 = QVariant(),
                                                                const QVariant & v6 = QVariant(),
                                                                const QVariant & v7 = QVariant(),
                                                                const QVariant & v8 = QVariant(),
                                                                const QVariant & v9 = QVariant() );

private:
    AsemanToolsPrivate *p;
};

#endif // ASEMANTOOLS_H
