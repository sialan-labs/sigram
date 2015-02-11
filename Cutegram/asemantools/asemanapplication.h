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

#ifndef ASEMANAPPLICATION_H
#define ASEMANAPPLICATION_H

#include "aseman_macros.h"

#include <QFont>
#include <QVariant>

#ifdef ASEMAN_QML_PLUGIN
#include <QObject>
class INHERIT_QAPP : public QObject
{
public:
    INHERIT_QAPP(QObject *parent = 0): QObject(parent){}
};
#else
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
#endif

class QSettings;
class AsemanApplicationPrivate;
class AsemanApplication : public INHERIT_QAPP
{
    Q_OBJECT

    Q_PROPERTY(QString homePath     READ homePath     NOTIFY fakeSignal)
    Q_PROPERTY(QString appPath      READ appPath      NOTIFY fakeSignal)
    Q_PROPERTY(QString appFilePath  READ appFilePath  NOTIFY fakeSignal)
    Q_PROPERTY(QString logPath      READ logPath      NOTIFY fakeSignal)
    Q_PROPERTY(QString confsPath    READ confsPath    NOTIFY fakeSignal)
    Q_PROPERTY(QString tempPath     READ tempPath     NOTIFY fakeSignal)
    Q_PROPERTY(QString backupsPath  READ backupsPath  NOTIFY fakeSignal)
    Q_PROPERTY(QString cameraPath   READ cameraPath   NOTIFY fakeSignal)

    Q_PROPERTY(QFont globalFont READ globalFont WRITE setGlobalFont NOTIFY globalFontChanged)

public:
#ifdef ASEMAN_QML_PLUGIN
    AsemanApplication();
#else
    AsemanApplication(int &argc, char **argv);
#endif
    ~AsemanApplication();

    static QString homePath();
    static QString appPath();
    static QString appFilePath();
    static QString logPath();
    static QString confsPath();
    static QString tempPath();
    static QString backupsPath();
    static QString cameraPath();

    static AsemanApplication *instance();

    void setGlobalFont(const QFont &font);
    QFont globalFont() const;

    static QSettings *settings();

public slots:
    void refreshTranslations();
    void back();

    void sleep(quint64 ms);

    void setSetting( const QString & key, const QVariant & value );
    QVariant readSetting( const QString & key, const QVariant & defaultValue = QVariant() );

signals:
    void fakeSignal();
    void globalFontFamilyChanged();
    void globalMonoFontFamilyChanged();
    void globalFontChanged();
    void languageUpdated();
    void backRequest();
    void clickedOnDock();

protected:
    bool event(QEvent *e);

private:
    AsemanApplicationPrivate *p;
};

#endif // ASEMANAPPLICATION_H
