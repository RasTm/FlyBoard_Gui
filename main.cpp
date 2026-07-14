#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "SerialManager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    
    QQuickStyle::setStyle("Fusion");
    
    QQmlApplicationEngine engine;

    // Sınıfı oluştur ve QML'e "serialManager" adıyla tanıt
    SerialManager serialManager;
    engine.rootContext()->setContextProperty("serialManager", &serialManager);

    const QUrl url(u"qrc:/GCSApp/main.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
