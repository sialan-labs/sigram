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
#include <userdata.h>
#include "asemantools/asemandevices.h"
#include "asemantools/asemantools.h"

#define EMOJIS_PATH QString( AsemanDevices::resourcePath() + "/emojis/" )
#define EMOJIS_THEME_PATH(THEME) QString(EMOJIS_PATH + THEME + "/")

#include <QHash>
#include <QFile>
#include <QDebug>
#include <QPointer>

class EmojisPrivate
{
public:
    QHash<QString,QString> emojis;
    QStringList keys;
    QString theme;
    QPointer<UserData> userData;
    QVariantMap replacements;

    int minReplacementSize;
    int maxReplacementSize;

    bool autoEmojis;
};

Emojis::Emojis(QObject *parent) :
    QObject(parent)
{
    p = new EmojisPrivate;
    p->maxReplacementSize = 0;
    p->minReplacementSize = 0;
    p->autoEmojis = false;

    setCurrentTheme("twitter");
}

void Emojis::setCurrentTheme(const QString &theme)
{
    QString path = EMOJIS_THEME_PATH(theme);
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

        QString epath = parts.at(0);
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

UserData *Emojis::userData() const
{
    return p->userData;
}

void Emojis::setUserData(UserData *userData)
{
    if(p->userData == userData)
        return;

    p->userData = userData;
    emit userDataChanged();
}

void Emojis::setReplacements(const QVariantMap &map)
{
    if(p->replacements == map)
        return;

    p->replacements = map;
    p->maxReplacementSize = 0;
    p->minReplacementSize = 0;

    QMapIterator<QString,QVariant> i(p->replacements);
    while(i.hasNext())
    {
        i.next();
        const int length = i.key().length();

        if(!p->maxReplacementSize)
            p->maxReplacementSize = length;
        else
        if(length > p->maxReplacementSize)
            p->maxReplacementSize = length;

        if(!p->minReplacementSize)
            p->minReplacementSize = length;
        else
        if(length < p->minReplacementSize)
            p->minReplacementSize = length;
    }

    emit replacementsChanged();
}

QVariantMap Emojis::replacements() const
{
    return p->replacements;
}

bool Emojis::autoEmojis() const
{
    return p->autoEmojis;
}

void Emojis::setAutoEmojis(bool stt)
{
    if(p->autoEmojis == stt)
        return;

    p->autoEmojis = stt;
    emit autoEmojisChanged();
}

QString Emojis::convertSmiliesToEmoji(const QString &txt)
{
    QString res = txt;
    for(int i=0; i<res.length()-1; i++)
    {
        const QChar currentString = res[i];
        if(i!=0 && currentString != ' ' && currentString != '\n')
            continue;

        const int smileyPointer = i==0? i : i+1;
        for(int j=p->minReplacementSize; j<=p->maxReplacementSize; j++)
        {
            if(smileyPointer+j < res.length())
            {
                const QChar endChar = res[smileyPointer+j];
                if(endChar != ' ' && endChar != '\n')
                    continue;
            }

            const QString &selection = res.mid(smileyPointer, j).toLower();
            if(!p->replacements.contains(selection))
                continue;

            res.replace(smileyPointer, j, p->replacements.value(selection).toString());
            i = smileyPointer;
        }
    }

    return res;
}

QString Emojis::textToEmojiText(const QString &txt, int size, bool skipLinks, bool localLinks)
{
    QString res = p->autoEmojis? convertSmiliesToEmoji(txt) : txt;
    res = res.toHtmlEscaped();

    QString size_folder = QString::number(size);
    size_folder = size_folder + "x" + size_folder;

    QRegExp links_rxp("((?:(?:\\w\\S*\\/\\S*|\\/\\S+|\\:\\/)(?:\\/\\S*\\w|\\w|\\/))|(?:\\w+\\.(?:com|org|co|net)))");
    int pos = 0;
    while (!skipLinks && (pos = links_rxp.indexIn(res, pos)) != -1)
    {
        QString link = links_rxp.cap(1);
        QString href = link;
        if(href.indexOf(QRegExp("\\w+\\:\\/\\/")) == -1)
            href = "http://" + href;

        QString atag = QString("<a href=\"%1\">%2</a>").arg(href,link);
        res.replace( pos, link.length(), atag );
        pos += atag.size();
    }

    QRegExp tags_rxp("\\#(\\w+)");
    pos = 0;
    while (!skipLinks && (pos = tags_rxp.indexIn(res, pos)) != -1)
    {
        QString tag = tags_rxp.cap(1);
        if(p->userData)
            p->userData->addTag(tag);

        QString atag = QString("<a href='tag://%1'>%2</a>").arg(tag,"#"+tag);
        res.replace( pos, tag.length()+1, atag );
        pos += atag.size();
    }

    for( int i=0; i<res.size(); i++ )
    {
        for( int j=1; j<5; j++ )
        {
            QString emoji = res.mid(i,j);
            if( !p->emojis.contains(emoji) )
                continue;

            QString path = EMOJIS_THEME_PATH(p->theme) + size_folder + "/" + p->emojis.value(emoji);
            QString in_txt = QString(" <img align=absmiddle height=\"%2\" width=\"%3\" src=\"" + (localLinks?QString():AsemanDevices::localFilesPrePath()) +"%1\" /> ").arg(path).arg(size).arg(size);
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
    return EMOJIS_THEME_PATH(p->theme) + "36x36/" + p->emojis.value(key);
}

const QHash<QString, QString> &Emojis::emojis() const
{
    return p->emojis;
}

Emojis::~Emojis()
{
    delete p;
}
