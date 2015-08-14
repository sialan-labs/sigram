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

#ifndef ASEMANDESKTOPTOOLS_H
#define ASEMANDESKTOPTOOLS_H

#include "aseman_macros.h"

#include <QObject>
#include <QColor>
#include <QDir>
#include <QFont>
#include <QWindow>
#include <QVariant>

class QAction;
class QMenu;
class AsemanDesktopToolsPrivate;
class AsemanDesktopTools : public QObject
{
    Q_PROPERTY(QColor titleBarColor READ titleBarColor NOTIFY titleBarColorChanged)
    Q_PROPERTY(QColor titleBarTransparentColor READ titleBarTransparentColor NOTIFY titleBarTransparentColorChanged)
    Q_PROPERTY(QColor titleBarTextColor READ titleBarTextColor NOTIFY titleBarTextColorChanged)
    Q_PROPERTY(bool titleBarIsDark READ titleBarIsDark NOTIFY titleBarIsDarkChanged)
    Q_PROPERTY(int desktopSession READ desktopSession NOTIFY desktopSessionChanged)
    Q_PROPERTY(QStringList fontFamilies READ fontFamilies NOTIFY fakeSignal)
    Q_PROPERTY(QString menuStyle READ menuStyle WRITE setMenuStyle NOTIFY menuStyleChanged)
    Q_PROPERTY(QObject* currentMenuObject READ currentMenuObject NOTIFY currentMenuObjectChanged)
    Q_PROPERTY(QString tooltip READ tooltip WRITE setTooltip NOTIFY tooltipChanged)

    Q_ENUMS(DesktopSession)
    Q_ENUMS(YesOrNoType)

    Q_OBJECT
public:
    AsemanDesktopTools(QObject *parent = 0);
    ~AsemanDesktopTools();

    enum DesktopSession {
        Unknown,
        Gnome,
        GnomeFallBack,
        Unity,
        Kde,
        Windows,
        Mac
    };

    enum YesOrNoType {
        Warning,
        Question,
        Information,
        Critical
    };

    static int desktopSession();

    QColor titleBarColor() const;
    QColor titleBarTransparentColor() const;
    QColor titleBarTextColor() const;
    bool titleBarIsDark() const;

    QStringList fontFamilies() const;

    void setMenuStyle(const QString &style);
    QString menuStyle() const;

    void setTooltip(const QString &txt);
    QString tooltip() const;

    QObject *currentMenuObject() const;

public slots:
    QString getOpenFileName(QWindow *window = 0, const QString &title = QString(), const QString &filter = QString(), const QString & startPath = QDir::homePath() );
    QString getSaveFileName(QWindow *window = 0, const QString &title = QString(), const QString &filter = QString(), const QString & startPath = QDir::homePath() );
    QString getExistingDirectory(QWindow *window = 0, const QString &title = QString(), const QString & startPath = QDir::homePath());
    QFont getFont(QWindow *window = 0, const QString &title = QString(), const QFont &font = QFont());
    QColor getColor(const QColor &color = QColor()) const;
    QString getText(QWindow *window = 0, const QString &title = QString(), const QString &text = QString(), const QString &defaultText = QString());
    int showMenu( const QVariantList & actions, QPoint point = QPoint() );
    bool yesOrNo(QWindow *window, const QString &title, const QString &text, int type = Warning);
    void showMessage(QWindow *window, const QString &title, const QString &text, int type = Information);

signals:
    void titleBarColorChanged();
    void titleBarTextColorChanged();
    void titleBarTransparentColorChanged();
    void titleBarIsDarkChanged();
    void desktopSessionChanged();
    void menuStyleChanged();
    void fakeSignal();
    void currentMenuObjectChanged();
    void tooltipChanged();

private:
    QMenu *menuOf(const QVariantList &list, QList<QAction*> *actions = 0, QMenu *parent = 0);

private:
    AsemanDesktopToolsPrivate *p;
};

#endif // ASEMANDESKTOPTOOLS_H
