#ifndef SETOBJECT_H
#define SETOBJECT_H

#include <QObject>
#include <QStringList>

class SetObjectPrivate;
class SetObject : public QObject
{
    Q_OBJECT
public:
    SetObject(QObject *parent = 0);
    ~SetObject();

public slots:
    void insert(const QString &str );
    void remove(const QString &str );
    bool contains(const QString &str );

    QStringList exportData() const;
    QList<int> exportIntData() const;
    void importData(const QStringList & data);
    void appendData(const QStringList & data);

private:
    SetObjectPrivate *p;
};

#endif // SETOBJECT_H
