#ifndef KEYBOARD_SERVER_H
#define KEYBOARD_SERVER_H

#include "cpp/common/common.h"
#include "cpp/ws-server/ws-server.h"
#include "QObject"

class KeyboardServer : public QObject
{
    Q_OBJECT
public:
    explicit KeyboardServer(QObject *parent = NULL);
    ~KeyboardServer();

    Q_INVOKABLE void slotKeyboardTextChanged(QString text);

private:
    WsServer *wsServer;
    QmlParams qml;

private slots:
};

#endif // KEYBOARD_SERVER_H
