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

#ifndef ASEMANJAVALAYER_H
#define ASEMANJAVALAYER_H

#include <QObject>

class AsemanJavaLayerPrivate;
class AsemanJavaLayer : public QObject
{
    Q_OBJECT
private:
    AsemanJavaLayer();
    ~AsemanJavaLayer();

public:
    static AsemanJavaLayer *instance();

    bool sharePaper( const QString & title, const QString & msg );
    bool shareFile( const QString & path, const QString & type );
    bool openFile( const QString & path, const QString & type );
    bool startCamera( const QString & output );
    bool getOpenPictures();

    bool transparentStatusBar();
    bool transparentNavigationBar();

    int densityDpi();
    int getSizeName();
    bool isTablet();
    qreal density();

    QRect keyboardRect();

public slots:
    bool startService();
    bool stopService();

signals:
    void incomingShare( const QString & title, const QString & msg );
    void incomingImage( const QString & path );
    void selectImageResult( const QString & path );
    void activityPaused();
    void activityStopped();
    void activityResumed();
    void activityStarted();
    void activityRestarted();

private slots:
    void load_buffer();

private:
    AsemanJavaLayerPrivate *p;
};

#endif // ASEMANJAVALAYER_H
