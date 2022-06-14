#include <QGuiApplication>
#include "keyboard-server/keyboard-server.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setApplicationName("KeyboardServer");
    KeyboardServer keyboardServer(&app);

    return app.exec();
}
