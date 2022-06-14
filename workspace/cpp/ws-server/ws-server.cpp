#include "ws-server.h"
#include "cpp/common/common.h"
#include "cpp/common/util.h"

WsServer::WsServer(QObject *parent) :
    QObject(parent)
{
    server = new QWebSocketServer("IMR WebSocket Server", QWebSocketServer::NonSecureMode, this);

    connect(server, &QWebSocketServer::newConnection, this, &WsServer::slotClientConnected);
    connect(server, &QWebSocketServer::closed, this, &WsServer::slotClosed);

    start();

    // TESTING
    /*connect(&tmrTest, &QTimer::timeout, this, [=] {
        this->tx("hey I'm Qt");
    });
    tmrTest.start(2000);*/
}

WsServer::~WsServer()
{
    stop();
    qDeleteAll(clients.begin(), clients.end());
}

void WsServer::start()
{
    stop();

    if (server->listen(QHostAddress::Any, WS_SERVER_PORT))
    {
        qDebug("Server listening on port %d...\n", WS_SERVER_PORT);
    }
    else
    {
        qErrnoWarning("Server listening on port %d failed: %s\n", WS_SERVER_PORT, server->errorString().CSTR());
    }
}

void WsServer::stop()
{
    if (server->isListening())
    {
        // Close connection first. When closed, start() will be called
        server->close();
    }
}

void WsServer::slotClosed()
{
    /*if (env->state == EnvGlobal::STATE_EXITING)
    {
        return;
    }

    LOG_INFO("Server Closed.\n");

    if (env->ds.capabilities->getGeneral_WebApplicationEnabled().value.toBool())
    {
        LOG_INFO("Server closed unexpectedly. Starting server again..\n");
        start();
    }*/
}

void WsServer::slotClientConnected()
{
    QWebSocket *pSocket = server->nextPendingConnection();

    // check if client already connected
    foreach (QWebSocket *pClient, clients)
    {
        if (pClient != NULL)
        {
            if ( (pClient->peerAddress() == pSocket->peerAddress()) &&
                 (pClient->peerPort() == pSocket->peerPort()) )
            {
                // client already connected, ignore
                return;
            }
        }
    }

    connect(pSocket, &QWebSocket::textMessageReceived, this, &WsServer::slotRxMessage);
    connect(pSocket, &QWebSocket::binaryMessageReceived, this, &WsServer::slotRxBinMessage);
    connect(pSocket, &QWebSocket::disconnected, this, &WsServer::socketDisconnected);

    clients << pSocket;

    qDebug("New Connection[%d]: %s%s:%u\n",
           clients.length() - 1,
           pSocket->peerName().CSTR(),
           pSocket->peerAddress().toString().CSTR(),
           pSocket->peerPort());
}

void WsServer::tx(QString msg)
{
    QVariantMap messageMap;
    messageMap.insert("from", "KeyboardServer");
    messageMap.insert("data", msg);
    QString payload = Util::qVarientToJsonData(messageMap);

    foreach (QWebSocket *pClient, clients)
    {
        if (pClient != NULL)
        {
            pClient->sendTextMessage(payload);
        }
    }
}

void WsServer::slotRxMessage(QString message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    qDebug("Message received: %s\n", message.CSTR());

    if (pClient) {
        pClient->sendTextMessage(message);
    }
}

void WsServer::slotRxBinMessage(QByteArray message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());

    qDebug("Binary Message received: %s\n", message.toHex().CSTR());

    if (pClient) {
        pClient->sendBinaryMessage(message);
    }
}

void WsServer::socketDisconnected()
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());

    if (pClient)
    {
        clients.removeAll(pClient);
        pClient->deleteLater();
        qDebug("Socket Disconnected[%d]: %s%s:%u\n",
                  clients.length(),
                  pClient->peerName().CSTR(),
                  pClient->peerAddress().toString().CSTR(),
                  pClient->peerPort());
    }
}
