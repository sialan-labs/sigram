#define FILE_PATH QString(QCoreApplication::applicationDirPath() + "/countries/countries.csv")
#define FLAGS_PATH QString(QCoreApplication::applicationDirPath() + "/countries/flags/")

#include "countries.h"

#include <QCoreApplication>
#include <QFile>
#include <QStringList>
#include <QHash>
#include <QDebug>

class CountriesPrivate
{
public:
    QHash<QString, QHash<QString,QString> > data;
    bool inited;
};

Countries::Countries(QObject *parent) :
    QObject(parent)
{
    p = new CountriesPrivate;
    p->inited = false;
}

QStringList Countries::countries()
{
    init_buff();
    QStringList res = p->data.keys();
    res.sort();
    return res;
}

QString Countries::phoneCode(const QString &country)
{
    init_buff();
    return p->data[country]["callingCode"];
}

QString Countries::countryFlag(const QString &country)
{
    init_buff();
    return FLAGS_PATH + p->data[country]["cca2"].toLower() + ".png";
}

void Countries::init_buff()
{
    if( p->inited )
        return;

    QFile file(FILE_PATH);
    if( !file.open(QFile::ReadOnly) )
        return;

    QString data = file.readAll();
    QStringList splits = data.split("\n",QString::SkipEmptyParts);
    if( splits.isEmpty() )
        return;

    QStringList heads = splits.takeFirst().split(";",QString::SkipEmptyParts);

    foreach( const QString & s, splits )
    {
        const QStringList & parts = s.split(";",QString::SkipEmptyParts);
        for( int i=0; i<parts.count(); i++ )
        {
            const QString & prt = parts.at(i);
            p->data[parts.first()][heads.at(i)] = prt;
        }
    }

    p->inited = true;
}

Countries::~Countries()
{
    delete p;
}
