#ifndef QMLSTATICOBJECTHANDLER_H
#define QMLSTATICOBJECTHANDLER_H

#include <QObject>

class QmlStaticObjectHandlerPrivate;
class QmlStaticObjectHandler : public QObject
{
    Q_PROPERTY(QString createMethod READ createMethod WRITE setCreateMethod NOTIFY createMethodChanged)
    Q_PROPERTY(QObject* createObject READ createObject WRITE setCreateObject NOTIFY createObjectChanged)
    Q_OBJECT
public:
    QmlStaticObjectHandler(QObject *parent = 0);
    ~QmlStaticObjectHandler();

    void setCreateMethod( const QString & m );
    QString createMethod() const;

    void setCreateObject( QObject *obj );
    QObject *createObject() const;

public slots:
    QObject *newObject();
    void freeObject( QObject *obj );

signals:
    void createMethodChanged();
    void createObjectChanged();

private slots:
    void object_destroyed( QObject *obj );

private:
    QmlStaticObjectHandlerPrivate *p;
};

#endif // QMLSTATICOBJECTHANDLER_H
