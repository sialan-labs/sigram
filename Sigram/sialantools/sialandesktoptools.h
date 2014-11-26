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

#ifndef SIALANDESKTOPTOOLS_H
#define SIALANDESKTOPTOOLS_H

#include "sialan_macros.h"

#include <QObject>
#include <QColor>
#include <QDir>
#include <QWindow>

class SialanDesktopToolsPrivate;
class SialanDesktopTools : public QObject
{
    Q_PROPERTY(QColor titleBarColor READ titleBarColor NOTIFY titleBarColorChanged)
    Q_PROPERTY(QColor titleBarTransparentColor READ titleBarTransparentColor NOTIFY titleBarTransparentColorChanged)
    Q_PROPERTY(QColor titleBarTextColor READ titleBarTextColor NOTIFY titleBarTextColorChanged)
    Q_PROPERTY(bool titleBarIsDark READ titleBarIsDark NOTIFY titleBarIsDarkChanged)
    Q_PROPERTY(int desktopSession READ desktopSession NOTIFY desktopSessionChanged)
    Q_ENUMS(DesktopSession)

    Q_OBJECT
public:
    SialanDesktopTools(QObject *parent = 0);
    ~SialanDesktopTools();

    enum DesktopSession {
        Unknown,
        Gnome,
        GnomeFallBack,
        Unity,
        Kde,
        Windows,
        Mac
    };

    int desktopSession() const;

    QColor titleBarColor() const;
    QColor titleBarTransparentColor() const;
    QColor titleBarTextColor() const;
    bool titleBarIsDark() const;

public slots:
#ifdef DESKTOP_DEVICE
    QString getOpenFileName(QWindow *window = 0, const QString &title = QString(), const QString &filter = QString(), const QString & startPath = QDir::homePath() );
    QString getSaveFileName(QWindow *window = 0, const QString &title = QString(), const QString &filter = QString(), const QString & startPath = QDir::homePath() );
    QString getExistingDirectory(QWindow *window = 0, const QString &title = QString(), const QString & startPath = QDir::homePath());
#endif

signals:
    void titleBarColorChanged();
    void titleBarTextColorChanged();
    void titleBarTransparentColorChanged();
    void titleBarIsDarkChanged();
    void desktopSessionChanged();

private:
    SialanDesktopToolsPrivate *p;
};

#endif // SIALANDESKTOPTOOLS_H
