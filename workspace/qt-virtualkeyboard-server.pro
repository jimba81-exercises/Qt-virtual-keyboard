QT += quick websockets
QTPLUGINS += qtvirtualkeyboardplugin

CONFIG += c++11

RESOURCES += qml/qml.qrc

SOURCES += \
        cpp/keyboard-server/keyboard-server.cpp \
        cpp/ws-server/ws-server.cpp \
        cpp/main.cpp

HEADERS += \
    cpp/common/common.h \
    cpp/common/util.h \
    cpp/keyboard-server/keyboard-server.h \
    cpp/ws-server/ws-server.h \

