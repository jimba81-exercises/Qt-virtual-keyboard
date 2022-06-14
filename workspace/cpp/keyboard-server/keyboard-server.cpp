#include "keyboard-server.h"
#include "cpp/common/common.h"

KeyboardServer::KeyboardServer(QObject *parent) :
    QObject(parent)
{
    wsServer = new WsServer(this);

    qml.context = new QQmlContext(qml.engine.rootContext());
    qml.engine.rootContext()->setContextProperty("cppKeyboard", this);
    qml.component = new QQmlComponent(&qml.engine, QUrl("qrc:/main.qml"));
    if (!qml.component->isReady())
    {
        qWarning() << "QML Init Failed: " << qml.component->errors();
        return;
    }
    qDebug() << "QML Init Completed: " << qml.component->errors();
    qml.object = qml.component->create(qml.context);
}

KeyboardServer::~KeyboardServer()
{
    wsServer->deleteLater();
}

void KeyboardServer::slotKeyboardTextChanged(QString text)
{
    this->wsServer->tx(text);
}

