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

#ifndef ASEMANIMAGECOLORANALIZOR_H
#define ASEMANIMAGECOLORANALIZOR_H

#include <QObject>
#include <QColor>
#include <QHash>

class AsemanImageColorAnalizorPrivate;
class AsemanImageColorAnalizor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QColor color READ color NOTIFY colorChanged)
    Q_PROPERTY(int method READ method WRITE setMethod NOTIFY methodChanged)
    Q_ENUMS(Method)

public:
    enum Method {
        Normal,
        MoreSaturation
    };

    AsemanImageColorAnalizor(QObject *parent = 0);
    ~AsemanImageColorAnalizor();

    QString source() const;
    void setSource( const QString & source );

    int method() const;
    void setMethod( int m );

    QColor color() const;

signals:
    void sourceChanged();
    void colorChanged();
    void methodChanged();

private slots:
    void found(int method, const QString & path );
    void start();

private:
    AsemanImageColorAnalizorPrivate *p;
};


class AsemanImageColorAnalizorThreadPrivate;
class AsemanImageColorAnalizorThread: public QObject
{
    Q_OBJECT
public:
    AsemanImageColorAnalizorThread(QObject *parent = 0);
    ~AsemanImageColorAnalizorThread();

    const QHash<int, QHash<QString, QColor> > &results() const;

public slots:
    void analize(int method, const QString & path );

signals:
    void found( int method, const QString & path );

private slots:
    void found_slt(class AsemanImageColorAnalizorCore *core, int method, const QString & path , const QColor &color);

private:
    AsemanImageColorAnalizorCore *getCore();

private:
    AsemanImageColorAnalizorThreadPrivate *p;
};


class AsemanImageColorAnalizorCorePrivate;
class AsemanImageColorAnalizorCore: public QObject
{
    Q_OBJECT
public:
    AsemanImageColorAnalizorCore(QObject *parent = 0);
    ~AsemanImageColorAnalizorCore();

public slots:
    void analize( int method, const QString & path );

signals:
    void found(AsemanImageColorAnalizorCore *core, int method, const QString & path , const QColor &color);

private:
    AsemanImageColorAnalizorCorePrivate *p;
};

#endif // ASEMANIMAGECOLORANALIZOR_H
