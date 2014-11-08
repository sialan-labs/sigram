/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef SIALANJAVALAYER_H
#define SIALANJAVALAYER_H

#include <QObject>

class SialanJavaLayerPrivate;
class SialanJavaLayer : public QObject
{
    Q_OBJECT
private:
    SialanJavaLayer();
    ~SialanJavaLayer();

public:
    static SialanJavaLayer *instance();

    bool sharePaper( const QString & title, const QString & msg );
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
    SialanJavaLayerPrivate *p;
};

#endif // SIALANJAVALAYER_H
