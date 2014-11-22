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

#ifndef SIALANAPPLICATION_H
#define SIALANAPPLICATION_H

#include "sialan_macros.h"

#ifdef DESKTOP_DEVICE
#include "qtsingleapplication/qtsingleapplication.h"
class INHERIT_QAPP : public QtSingleApplication
{
public:
    INHERIT_QAPP(int &argc, char **argv): QtSingleApplication(argc, argv){}
};
#else
#include <QGuiApplication>
class INHERIT_QAPP : public QGuiApplication
{
public:
    INHERIT_QAPP(int &argc, char **argv): QGuiApplication(argc, argv){}
};
#endif

class QSettings;
class SialanApplicationPrivate;
class SialanApplication : public INHERIT_QAPP
{
    Q_OBJECT

    Q_PROPERTY(QString homePath     READ homePath     NOTIFY fakeSignal)
    Q_PROPERTY(QString appPath      READ appPath      NOTIFY fakeSignal)
    Q_PROPERTY(QString logPath      READ logPath      NOTIFY fakeSignal)
    Q_PROPERTY(QString confsPath    READ confsPath    NOTIFY fakeSignal)
    Q_PROPERTY(QString tempPath     READ tempPath     NOTIFY fakeSignal)
    Q_PROPERTY(QString backupsPath  READ backupsPath  NOTIFY fakeSignal)
    Q_PROPERTY(QString cameraPath   READ cameraPath   NOTIFY fakeSignal)

    Q_PROPERTY(QString globalFontFamily READ globalFontFamily WRITE setGlobalFontFamily NOTIFY globalFontFamilyChanged)
    Q_PROPERTY(QString globalMonoFontFamily READ globalMonoFontFamily WRITE setGlobalMonoFontFamily NOTIFY globalMonoFontFamilyChanged)

public:
    SialanApplication(int &argc, char **argv);
    ~SialanApplication();

    static QString homePath();
    static QString appPath();
    static QString logPath();
    static QString confsPath();
    static QString tempPath();
    static QString backupsPath();
    static QString cameraPath();

    static SialanApplication *instance();

    void setGlobalFontFamily( const QString & fontFamily );
    QString globalFontFamily() const;

    void setGlobalMonoFontFamily( const QString & fontFamily );
    QString globalMonoFontFamily() const;

    static QSettings *settings();

public slots:
    void refreshTranslations();
    void back();

    void setSetting( const QString & key, const QVariant & value );
    QVariant readSetting( const QString & key, const QVariant & defaultValue = QVariant() );

signals:
    void fakeSignal();
    void globalFontFamilyChanged();
    void globalMonoFontFamilyChanged();
    void languageUpdated();
    void backRequest();

private:
    SialanApplicationPrivate *p;
};

#endif // SIALANAPPLICATION_H
