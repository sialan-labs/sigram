/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "emojis.h"
#include "telegram_macros.h"

#include <QHash>
#include <QFile>
#include <QDebug>

class EmojisPrivate
{
public:
    QHash<QString,QString> emojis;
    QStringList keys;
    QString theme;
};

Emojis::Emojis(QObject *parent) :
    QObject(parent)
{
    p = new EmojisPrivate;
    setCurrentTheme("apple");
}

void Emojis::setCurrentTheme(const QString &theme)
{
    QString path = EMOJIS_PATH + theme + "/";
    QString conf = path + "theme";

    QFile cfile(conf);
    if( !cfile.open(QFile::ReadOnly) )
        return;

    p->theme = theme;
    p->emojis.clear();
    p->keys.clear();

    const QString data = cfile.readAll();
    const QStringList & list = data.split("\n",QString::SkipEmptyParts);
    foreach( const QString & l, list )
    {
        const QStringList & parts = l.split("\t",QString::SkipEmptyParts);
        if( parts.count() < 2 )
            continue;

        QString epath = path + parts.at(0);
        QString ecode = parts.at(1);

        p->emojis[ecode] = epath;
        p->keys << ecode;
    }

    emit currentThemeChanged();
}

QString Emojis::currentTheme() const
{
    return p->theme;
}

QString Emojis::textToEmojiText(const QString &txt)
{
    QString res = txt.toHtmlEscaped();

    QRegExp links_rxp("((?:\\w\\S*\\/\\S*|\\/\\S+|\\:\\/)(?:\\/\\S*\\w|\\w\\/))");
    int pos = 0;
    while ((pos = links_rxp.indexIn(res, pos)) != -1)
    {
        QString link = links_rxp.cap(1);
        QString atag = QString("<a href='%1'>%2</a>").arg(link,link);
        res.replace( pos, link.length(), atag );
        pos += atag.size();
    }

    for( int i=0; i<res.size(); i++ )
    {
        for( int j=1; j<5; j++ )
        {
            QString emoji = res.mid(i,j);
            if( !p->emojis.contains(emoji) )
                continue;

            QString path = p->emojis.value(emoji);
            QString in_txt = QString("<img align=\"top\" height=\"18\" width=\"18\" src=\"file://%1\" />").arg(path);
            res.replace(i,j,in_txt);
            i += in_txt.size()-1;
            break;
        }
    }

    if( res.contains("<img") )
        res = "<font size=\"1\">.</font>" + res;


    res = "<html><body>" + res.replace("\n","<br />") + "</body></html>";
    return res;
}

QList<QString> Emojis::keys() const
{
    return p->keys;
}

QString Emojis::pathOf(const QString &key) const
{
    return p->emojis.value(key);
}

Emojis::~Emojis()
{
    delete p;
}
