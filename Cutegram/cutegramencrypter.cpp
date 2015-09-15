#include "cutegramencrypter.h"

QVariant CutegramEncrypter::encrypt(const QString &text, bool encryptedMessage)
{
    Q_UNUSED(encryptedMessage)
    QByteArray result;
    AsemanSimpleQtCryptor::Encryptor enc( _key, AsemanSimpleQtCryptor::SERPENT_32, AsemanSimpleQtCryptor::ModeCFB, AsemanSimpleQtCryptor::NoChecksum );
    if(enc.encrypt( text.toUtf8(), result, true ) == AsemanSimpleQtCryptor::NoError)
        return result;
    else
        return text;
}

QString CutegramEncrypter::decrypt(const QVariant &data)
{
    if(data.type() == QVariant::String)
        return data.toString();

    QByteArray result;
    AsemanSimpleQtCryptor::Decryptor dec( _key, AsemanSimpleQtCryptor::SERPENT_32, AsemanSimpleQtCryptor::ModeCFB );
    if(dec.decrypt( data.toByteArray(), result, true ) == AsemanSimpleQtCryptor::NoError)
        return result;
    else
        return QString("Can't decrypt data. The key is lost!");
}

void CutegramEncrypter::setKey(const QString &key)
{
    _key = QSharedPointer<AsemanSimpleQtCryptor::Key>(new AsemanSimpleQtCryptor::Key(key));
}

