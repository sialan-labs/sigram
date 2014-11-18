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

#ifndef SIGRAM_H
#define SIGRAM_H

#include <QObject>
#include <QSize>

class SigramPrivate;
class Sigram : public QObject
{
    Q_OBJECT
public:
    Sigram(QObject *parent = 0);
    ~Sigram();

    Q_INVOKABLE QSize imageSize( const QString & path );
    Q_INVOKABLE qreal htmlWidth( const QString & txt );

    Q_INVOKABLE QString getTimeString( const QDateTime & dt );

public slots:
    void start();
    void close();
    void incomingAppMessage( const QString & msg );

signals:
    void backRequest();

protected:
    bool eventFilter(QObject *o, QEvent *e);

private:
    SigramPrivate *p;
};

#endif // SIGRAM_H
