#include <QApplication>
#include <QQmlApplicationEngine>

#include <QVariantMap>
#include <QDataStream>
#include <QDebug>
#include <QByteArray>

#include "core/asemancontributorsmodel.h"
#include "core/asemankeychain.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<AsemanKeychain>("Cutegram", 3, 0, "Keychain");
    qmlRegisterType<AsemanContributorsModel>("Cutegram", 3, 0, "ContributorsModel");

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/main.qml"));

    return app.exec();
}
