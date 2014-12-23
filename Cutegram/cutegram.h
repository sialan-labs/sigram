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

#ifndef CUTEGRAM_H
#define CUTEGRAM_H

#include <QObject>
#include <QSize>
#include <QVariantMap>
#include <QSystemTrayIcon>

class CutegramPrivate;
class Cutegram : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int sysTrayCounter READ sysTrayCounter WRITE setSysTrayCounter NOTIFY sysTrayCounterChanged)

public:
    Cutegram(QObject *parent = 0);
    ~Cutegram();

    Q_INVOKABLE QSize imageSize( const QString & path );
    Q_INVOKABLE qreal htmlWidth( const QString & txt );

    Q_INVOKABLE QString getTimeString( const QDateTime & dt );

    Q_INVOKABLE int showMenu( const QStringList & actions, QPoint point = QPoint() );

    void setSysTrayCounter( int count );
    int sysTrayCounter() const;

public slots:
    void start();
    void close();
    void quit();
    void incomingAppMessage( const QString & msg );
    void active();

signals:
    void backRequest();
    void sysTrayCounterChanged();

protected:
    bool eventFilter(QObject *o, QEvent *e);

private slots:
    void systray_action( QSystemTrayIcon::ActivationReason act );

private:
    void init_systray();
    void showContextMenu();
    QImage generateIcon( const QImage & img, int count );

private:
    CutegramPrivate *p;
};

#endif // CUTEGRAM_H
