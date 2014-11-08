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

#ifndef SIALANIMAGECOLORANALIZOR_H
#define SIALANIMAGECOLORANALIZOR_H

#include <QObject>
#include <QColor>
#include <QHash>

class SialanImageColorAnalizorPrivate;
class SialanImageColorAnalizor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QColor color READ color NOTIFY colorChanged)

public:
    SialanImageColorAnalizor(QObject *parent = 0);
    ~SialanImageColorAnalizor();

    QString source() const;
    void setSource( const QString & source );

    QColor color() const;

signals:
    void sourceChanged();
    void colorChanged();

private slots:
    void found( const QString & path );

private:
    SialanImageColorAnalizorPrivate *p;
};


class SialanImageColorAnalizorThreadPrivate;
class SialanImageColorAnalizorThread: public QObject
{
    Q_OBJECT
public:
    SialanImageColorAnalizorThread(QObject *parent = 0);
    ~SialanImageColorAnalizorThread();

    const QHash<QString,QColor> & results() const;

public slots:
    void analize( const QString & path );

signals:
    void found( const QString & path );

private slots:
    void found_slt(class SialanImageColorAnalizorCore *core, const QString & path , const QColor &color);

private:
    SialanImageColorAnalizorCore *getCore();

private:
    SialanImageColorAnalizorThreadPrivate *p;
};


class SialanImageColorAnalizorCorePrivate;
class SialanImageColorAnalizorCore: public QObject
{
    Q_OBJECT
public:
    SialanImageColorAnalizorCore(QObject *parent = 0);
    ~SialanImageColorAnalizorCore();

public slots:
    void analize( const QString & path );

signals:
    void found_slt(SialanImageColorAnalizorCore *core, const QString & path , const QColor &color);

private:
    SialanImageColorAnalizorCorePrivate *p;
};

#endif // SIALANIMAGECOLORANALIZOR_H
