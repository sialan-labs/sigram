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

#include "emojis.h"
#include "cutegram.h"
#include "asemantools/asemandevices.h"
#include "asemantools/asemantools.h"

#define EMOJIS_PATH QString( AsemanDevices::resourcePath() + "/emojis/" )

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
    setCurrentTheme("twitter");
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

QString Emojis::textToEmojiText(const QString &txt, int size, bool skipLinks)
{
    QString res = txt.toHtmlEscaped();

    QRegExp links_rxp("((?:\\w\\S*\\/\\S*|\\/\\S+|\\:\\/)(?:\\/\\S*\\w|\\w\\/))");
    int pos = 0;
    while (!skipLinks && (pos = links_rxp.indexIn(res, pos)) != -1)
    {
        QString link = links_rxp.cap(1);
        QString href = link;
        if(href.indexOf(QRegExp("\\w+\\:\\/\\/")) == -1)
            href = "http://" + href;

        QString atag = QString("<a href='%1'>%2</a>").arg(href,link);
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
            QString in_txt = QString(" <img align=absmiddle height=\"%2\" width=\"%3\" src=\"file://%1\" /> ").arg(path).arg(size).arg(size);
            res.replace(i,j,in_txt);
            i += in_txt.size()-1;
            break;
        }
    }


    res = res.replace("\n","<br />");
    return res;
}

QString Emojis::bodyTextToEmojiText(const QString &txt)
{
    QString res;
    Qt::LayoutDirection dir = AsemanTools::directionOf(txt);

    QString dir_txt = dir==Qt::LeftToRight? "ltr" : "rtl";
    res = QString("<html><body><p dir='%1'>").arg(dir_txt) + textToEmojiText(txt, 18) + "</p></body></html>";
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
