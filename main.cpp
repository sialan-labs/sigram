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
    engine.load(QUrl::fromLocalFile(PROJECT_PATH"/main.qml"));

    return app.exec();
}
