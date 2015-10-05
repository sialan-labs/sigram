#ifndef CUTEGRAMENCRYPTER_H
#define CUTEGRAMENCRYPTER_H

#include "asemantools/asemansimpleqtcryptor.h"
#include <databaseabstractencryptor.h>

class CutegramEncrypter: public DatabaseAbstractEncryptor
{
public:
    CutegramEncrypter(){}
    ~CutegramEncrypter(){}

    QVariant encrypt(const QString &text, bool encryptedMessage);
    QString decrypt(const QVariant &data);

    void setKey(const QString &key);

private:
    QSharedPointer<AsemanSimpleQtCryptor::Key> _key;
};

#endif // CUTEGRAMENCRYPTER_H
