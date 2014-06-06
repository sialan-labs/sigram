#ifndef COUNTRIES_H
#define COUNTRIES_H

#include <QObject>
#include <QStringList>

class CountriesPrivate;
class Countries : public QObject
{
    Q_OBJECT
public:
    Countries(QObject *parent = 0);
    ~Countries();

public slots:
    QStringList countries();
    QString phoneCode( const QString & country );
    QString countryFlag( const QString & country );

private:
    void init_buff();

private:
    CountriesPrivate *p;
};

#endif // COUNTRIES_H
