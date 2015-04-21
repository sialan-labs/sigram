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

#include "asemantools.h"

#include <QMetaMethod>
#include <QMetaObject>
#include <QCryptographicHash>
#include <QCoreApplication>
#include <QColor>
#include <QTimer>
#include <QFile>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QTextDocument>
#include <QProcess>
#include <QUuid>

QString aseman_tools_numtranslate_0 = "0";
QString aseman_tools_numtranslate_1 = "1";
QString aseman_tools_numtranslate_2 = "2";
QString aseman_tools_numtranslate_3 = "3";
QString aseman_tools_numtranslate_4 = "4";
QString aseman_tools_numtranslate_5 = "5";
QString aseman_tools_numtranslate_6 = "6";
QString aseman_tools_numtranslate_7 = "7";
QString aseman_tools_numtranslate_8 = "8";
QString aseman_tools_numtranslate_9 = "9";


class AsemanToolsPrivate
{
public:
};

AsemanTools::AsemanTools(QObject *parent) :
    QObject(parent)
{
    p = new AsemanToolsPrivate;

    aseman_tools_numtranslate_0 = AsemanTools::tr("0");
    aseman_tools_numtranslate_1 = AsemanTools::tr("1");
    aseman_tools_numtranslate_2 = AsemanTools::tr("2");
    aseman_tools_numtranslate_3 = AsemanTools::tr("3");
    aseman_tools_numtranslate_4 = AsemanTools::tr("4");
    aseman_tools_numtranslate_5 = AsemanTools::tr("5");
    aseman_tools_numtranslate_6 = AsemanTools::tr("6");
    aseman_tools_numtranslate_7 = AsemanTools::tr("7");
    aseman_tools_numtranslate_8 = AsemanTools::tr("8");
    aseman_tools_numtranslate_9 = AsemanTools::tr("9");
}

void AsemanTools::debug(const QVariant &var)
{
    qDebug() << var;
}

QDateTime AsemanTools::currentDate()
{
    return QDateTime::currentDateTime();
}

QString AsemanTools::dateToMSec(const QDateTime &dt)
{
    return QString::number(dt.toMSecsSinceEpoch());
}

QDateTime AsemanTools::mSecToDate(const QString &ms)
{
    return QDateTime::fromMSecsSinceEpoch(ms.toLongLong());
}

QString AsemanTools::dateToString(const QDateTime &dt, const QString & format)
{
    if(format.isEmpty())
        return dt.toString();
    else
        return dt.toString(format);
}

QString AsemanTools::fileName(const QString &path)
{
    return QFileInfo(path).baseName();
}

QString AsemanTools::fileSuffix(const QString &path)
{
    return QFileInfo(path).suffix().toLower();
}

QString AsemanTools::readText(const QString &path)
{
    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return QString();

    QString res = QString::fromUtf8(file.readAll());
    return res;
}

QStringList AsemanTools::stringLinks(const QString &str)
{
    QStringList links;
    QRegExp links_rxp("((?:(?:\\w\\S*\\/\\S*|\\/\\S+|\\:\\/)(?:\\/\\S*\\w|\\w))|(?:\\w+\\.(?:com|org|co|net)))");
    int pos = 0;
    while ((pos = links_rxp.indexIn(str, pos)) != -1)
    {
        QString link = links_rxp.cap(1);
        if(link.indexOf(QRegExp("\\w+\\:\\/\\/")) == -1)
            link = "http://" + link;

        links << link;
        pos += links_rxp.matchedLength();
    }

    return links;
}

QUrl AsemanTools::stringToUrl(const QString &path)
{
    return QUrl(path);
}

QString AsemanTools::qtVersion()
{
    return qVersion();
}

QString AsemanTools::aboutAseman()
{
    return tr("Aseman is a not-for-profit research and software development team launched in February 2014 focusing on development of products, technologies and solutions in order to publish them as open-source projects accessible to all people in the universe. Currently, we are focusing on design and development of software applications and tools which have direct connection with end users.") + "\n\n" +
           tr("By enabling innovative projects and distributing software to millions of users globally, the lab is working to accelerate the growth of high-impact open source software projects and promote an open source culture of accessibility and increased productivity around the world. The lab partners with industry leaders and policy makers to bring open source technologies to new sectors, including education, health and government.");
}

void AsemanTools::deleteItemDelay(QObject *o, int ms)
{
    QTimer::singleShot( ms, o, SLOT(deleteLater()) );
}

qreal AsemanTools::colorHue(const QColor &clr)
{
    return clr.hue()/255.0;
}

qreal AsemanTools::colorLightness(const QColor &clr)
{
    return 2*clr.lightness()/255.0 - 1;
}

qreal AsemanTools::colorSaturation(const QColor &clr)
{
    return clr.saturation()/255.0;
}

void AsemanTools::mkDir(const QString &dir)
{
    QDir().mkpath(dir);
}

QVariantMap AsemanTools::colorHsl(const QColor &clr)
{
    QVariantMap res;
    res["hue"] = colorHue(clr);
    res["lightness"] = colorLightness(clr);
    res["saturation"] = colorSaturation(clr);

    return res;
}

bool AsemanTools::createVideoThumbnail(const QString &video, const QString &output, QString ffmpegPath)
{
    if(ffmpegPath.isEmpty())
#ifdef Q_OS_WIN
        ffmpegPath = QCoreApplication::applicationDirPath() + "/ffmpeg.exe";
#else
#ifdef Q_OS_MAC
        ffmpegPath = QCoreApplication::applicationDirPath() + "/ffmpeg";
#else
    {
        if(QFileInfo::exists("/usr/bin/avconv"))
            ffmpegPath = "/usr/bin/avconv";
        else
            ffmpegPath = "ffmpeg";
    }
#endif
#endif

    QStringList args;
    args << "-itsoffset";
    args << "-4";
    args << "-i";
    args << video;
    args << "-vcodec";
    args << "mjpeg";
    args << "-vframes";
    args << "1";
    args << "-an";
    args << "-f";
    args << "rawvideo";
    args << output;
    args << "-y";

    QProcess prc;
    prc.start(ffmpegPath, args);
    prc.waitForStarted();
    prc.waitForFinished();

    return prc.exitCode() == 0;
}

QString AsemanTools::translateNumbers(QString input)
{
    input.replace("0",aseman_tools_numtranslate_0);
    input.replace("1",aseman_tools_numtranslate_1);
    input.replace("2",aseman_tools_numtranslate_2);
    input.replace("3",aseman_tools_numtranslate_3);
    input.replace("4",aseman_tools_numtranslate_4);
    input.replace("5",aseman_tools_numtranslate_5);
    input.replace("6",aseman_tools_numtranslate_6);
    input.replace("7",aseman_tools_numtranslate_7);
    input.replace("8",aseman_tools_numtranslate_8);
    input.replace("9",aseman_tools_numtranslate_9);
    return input;
}

QString AsemanTools::passToMd5(const QString &pass)
{
    if( pass.isEmpty() )
        return QString();

    return QCryptographicHash::hash( pass.toUtf8(), QCryptographicHash::Md5 ).toHex();
}

QString AsemanTools::createUuid()
{
    return QUuid::createUuid().toString();
}

QString AsemanTools::htmlToPlaintText(const QString &html)
{
    QTextDocument doc;
    doc.setHtml(html);
    return doc.toPlainText();
}

void AsemanTools::copyDirectory(const QString &src, const QString &dst)
{
    QDir().mkpath(dst);

    const QStringList & dirs = QDir(src).entryList(QDir::Dirs|QDir::NoDotAndDotDot);
    foreach( const QString & d, dirs )
        copyDirectory(src+"/"+d, dst+"/"+d);

    const QStringList & files = QDir(src).entryList(QDir::Files);
    foreach( const QString & f, files )
        QFile::copy(src+"/"+f, dst+"/"+f);
}

void AsemanTools::setProperty(QObject *obj, const QString &property, const QVariant &v)
{
    if( !obj || property.isEmpty() )
        return;

    obj->setProperty( property.toUtf8(), v );
}

QVariant AsemanTools::property(QObject *obj, const QString &property)
{
    if( !obj || property.isEmpty() )
        return QVariant();

    return obj->property(property.toUtf8());
}

Qt::LayoutDirection AsemanTools::directionOf(const QString &str)
{
    Qt::LayoutDirection res = Qt::LeftToRight;
    if( str.isEmpty() )
        return res;

    int ltr = 0;
    int rtl = 0;

    foreach( const QChar & ch, str )
    {
        QChar::Direction dir = ch.direction();
        switch( static_cast<int>(dir) )
        {
        case QChar::DirL:
        case QChar::DirLRE:
        case QChar::DirLRO:
        case QChar::DirEN:
            ltr++;
            break;

        case QChar::DirR:
        case QChar::DirRLE:
        case QChar::DirRLO:
        case QChar::DirAL:
            rtl++;
            break;
        }
    }

    if( ltr >= rtl )
        res = Qt::LeftToRight;
    else
        res = Qt::RightToLeft;

    return res;
}

QVariant AsemanTools::call(QObject *obj, const QString &member, Qt::ConnectionType ctype, const QVariant &v0, const QVariant &v1, const QVariant &v2, const QVariant &v3, const QVariant &v4, const QVariant &v5, const QVariant &v6, const QVariant &v7, const QVariant &v8, const QVariant &v9)
{
    const QMetaObject *meta_obj = obj->metaObject();
    QMetaMethod meta_method;
    for( int i=0; i<meta_obj->methodCount(); i++ )
    {
        QMetaMethod mtd = meta_obj->method(i);
        if( mtd.name() == member )
            meta_method = mtd;
    }
    if( !meta_method.isValid() )
        return QVariant();

    QList<QByteArray> param_types = meta_method.parameterTypes();
    QList<QByteArray> param_names = meta_method.parameterNames();

    QString ret_type = meta_method.typeName();
    QList< QPair<QString,QString> > m_args;
    for( int i=0 ; i<param_types.count() ; i++ )
        m_args << QPair<QString,QString>( param_types.at(i) , param_names.at(i) );

    QVariantList vals;
        vals << v0 << v1 << v2 << v3 << v4 << v5 << v6 << v7 << v8 << v9;

    QVariantList tr_vals;

    QList< QPair<QString,const void*> > args;
    for( int i=0 ; i<vals.count() ; i++ )
    {
        if( i<m_args.count() )
        {
            QString type = m_args.at(i).first;

            if( type != vals.at(i).typeName() )
            {
                if( !vals[i].canConvert( QVariant::nameToType(type.toLatin1()) ) )
                    ;
                else
                    vals[i].convert( QVariant::nameToType(type.toLatin1()) );
            }

            args << QPair<QString,const void*>( type.toLatin1() , vals.at(i).data() );
            tr_vals << vals[i];
        }
        else
        {
            args << QPair<QString,const void*>( vals.at(i).typeName() , vals.at(i).data() );
        }
    }

    int type = QMetaType::type(ret_type.toLatin1());
    void *res = QMetaType::create( type );
    bool is_pointer = ret_type.contains('*');

    bool done;
    switch( static_cast<int>(ctype) )
    {
    case Qt::QueuedConnection:
        done = QMetaObject::invokeMethod( obj , member.toLatin1() , Qt::QueuedConnection ,
                                  QGenericArgument( args.at(0).first.toLatin1() , args.at(0).second ) ,
                                  QGenericArgument( args.at(1).first.toLatin1() , args.at(1).second ) ,
                                  QGenericArgument( args.at(2).first.toLatin1() , args.at(2).second ) ,
                                  QGenericArgument( args.at(3).first.toLatin1() , args.at(3).second ) ,
                                  QGenericArgument( args.at(4).first.toLatin1() , args.at(4).second ) ,
                                  QGenericArgument( args.at(5).first.toLatin1() , args.at(5).second ) ,
                                  QGenericArgument( args.at(6).first.toLatin1() , args.at(6).second ) ,
                                  QGenericArgument( args.at(7).first.toLatin1() , args.at(7).second ) ,
                                  QGenericArgument( args.at(8).first.toLatin1() , args.at(8).second ) ,
                                  QGenericArgument( args.at(9).first.toLatin1() , args.at(9).second ) );
        return QVariant();
        break;

    default:
        done = QMetaObject::invokeMethod( obj , member.toLatin1() , ctype, QGenericReturnArgument( ret_type.toLatin1() , (is_pointer)? &res : res ) ,
                                  QGenericArgument( args.at(0).first.toLatin1() , args.at(0).second ) ,
                                  QGenericArgument( args.at(1).first.toLatin1() , args.at(1).second ) ,
                                  QGenericArgument( args.at(2).first.toLatin1() , args.at(2).second ) ,
                                  QGenericArgument( args.at(3).first.toLatin1() , args.at(3).second ) ,
                                  QGenericArgument( args.at(4).first.toLatin1() , args.at(4).second ) ,
                                  QGenericArgument( args.at(5).first.toLatin1() , args.at(5).second ) ,
                                  QGenericArgument( args.at(6).first.toLatin1() , args.at(6).second ) ,
                                  QGenericArgument( args.at(7).first.toLatin1() , args.at(7).second ) ,
                                  QGenericArgument( args.at(8).first.toLatin1() , args.at(8).second ) ,
                                  QGenericArgument( args.at(9).first.toLatin1() , args.at(9).second ) );
        break;
    }

    QVariant result;
    if( !done )
        return result;

    if( type == QMetaType::Void )
        result = QVariant();
    else
    if( is_pointer )
        result = QVariant( type , &res );
    else
        result = QVariant( type , res );

    if( type == QMetaType::type("QVariant") )
        return result.value<QVariant>();
    else
        return result;
}

AsemanTools::~AsemanTools()
{
    delete p;
}
