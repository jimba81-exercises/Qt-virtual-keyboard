#ifndef WS_SERVER_H
#define WS_SERVER_H

#define WS_SERVER_PORT          3000


#include "QtWebSockets/qwebsocketserver.h"
#include "QtWebSockets/qwebsocket.h"
#include "QTimer"

class WsServer : public QObject
{
    Q_OBJECT
public:
    explicit WsServer(QObject *parent = NULL);
    ~WsServer();

    void tx(QString msg);

private:
    QWebSocketServer *server;
    QList<QWebSocket *> clients;
    QTimer tmrTest;

    void start();
    void stop();
    QByteArray qVarientToJsonData(QVariant var, bool simplifyStr = true);

private slots:
    void slotClientConnected();
    void slotRxMessage(QString message);
    void slotRxBinMessage(QByteArray message);
    void socketDisconnected();
    void slotClosed();

};

#endif //WS_SERVER_H
