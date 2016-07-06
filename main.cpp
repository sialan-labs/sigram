#include <QApplication>
#include <QQmlApplicationEngine>

#include <QVariantMap>
#include <QDataStream>
#include <QDebug>
#include <QByteArray>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/main.qml"));

    return app.exec();
}
