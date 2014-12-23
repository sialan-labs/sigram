/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Cutegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Cutegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef EMOJIS_H
#define EMOJIS_H

#include <QObject>
#include <QList>

class EmojisPrivate;
class Emojis : public QObject
{
    Q_PROPERTY( QString currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY currentThemeChanged)
    Q_OBJECT
public:
    Emojis(QObject *parent = 0);
    ~Emojis();

    void setCurrentTheme( const QString & theme );
    QString currentTheme() const;

    Q_INVOKABLE QString textToEmojiText( const QString & txt );
    Q_INVOKABLE QString bodyTextToEmojiText( const QString & txt );

    Q_INVOKABLE QList<QString> keys() const;
    Q_INVOKABLE QString pathOf( const QString & key ) const;

signals:
    void currentThemeChanged();

private:
    EmojisPrivate *p;
};

#endif // EMOJIS_H
