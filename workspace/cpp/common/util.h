#ifndef UTIL_H
#define UTIL_H

#include <QJsonDocument>
#include <QVariant>

class Util
{
public:
    static QByteArray qVarientToJsonData(QVariant var, bool simplifyStr = true)
    {
        QJsonDocument doc = QJsonDocument::fromVariant(var);
        QString jsonStr = doc.toJson().replace("\\\\/", "\\/");

        jsonStr.replace("\"/Date(", "\"\\/Date(").replace(")/\"", ")\\/\"");

        if (simplifyStr)
        {
            return jsonStr.toLocal8Bit().simplified();
        }
        else
        {
            return jsonStr.toLocal8Bit();
        }
    }
};

#endif // UTIL_H
