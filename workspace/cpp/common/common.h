#ifndef COMMON_H
#define COMMON_H

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QElapsedTimer>

#define LOG_DEBUG(format, args...)      do { if (envLocal->log != NULL) { envLocal->log->writeDebug(QString().sprintf(format, ## args)); } \
                                             if (env->allLog != NULL) { env->allLog->writeDebug(QString().sprintf(format, ## args), (envLocal->log == NULL) ? "" : (envLocal->logPrefix + ": ")); } \
                                        }while(0)

#define LOG_INFO(format, args...)       do { if (envLocal->log != NULL) { envLocal->log->writeInfo(QString().sprintf(format, ## args)); } \
                                             if (env->allLog != NULL) { env->allLog->writeInfo(QString().sprintf(format, ## args), (envLocal->log == NULL) ? "" : (envLocal->logPrefix + ": ")); } \
                                         }while(0)

#define LOG_WARNING(format, args...)    do { if (envLocal->log != NULL) { envLocal->log->writeWarning(QString().sprintf(format, ## args)); } \
                                             if (env->errLog != NULL) { env->errLog->writeWarning(QString().sprintf(format, ## args), (envLocal->log == NULL) ? "" : (envLocal->logPrefix + ": ")); } \
                                             if (env->allLog != NULL) { env->allLog->writeWarning(QString().sprintf(format, ## args), (envLocal->log == NULL) ? "" : (envLocal->logPrefix + ": ")); } \
                                        }while(0)

#define LOG_ERROR(format, args...)      do { if (envLocal->log != NULL) { envLocal->log->writeError(QString().sprintf(format, ## args)); } \
                                             if (env->errLog != NULL) { env->errLog->writeError(QString().sprintf(format, ## args), (envLocal->log == NULL) ? "" : (envLocal->logPrefix + ": ")); } \
                                             if (env->allLog != NULL) { env->allLog->writeError(QString().sprintf(format, ## args), (envLocal->log == NULL) ? "" : (envLocal->logPrefix + ": ")); } \
                                        }while(0)

#define ARRAY_LEN(arr)                  (int)(sizeof(arr) / sizeof(arr[0]))
#define ARRAY_CMP(arr1, arr2)           (bool)((ARRAY_LEN(arr1) == ARRAY_LEN(arr2))&& (std::equal(std::begin(arr1), std::end(arr1), std::begin(arr2))))

#define _L(str)                         QLatin1String(str)
#define CSTR()                          toStdString().c_str()

struct QmlParams
{
    QQmlApplicationEngine engine;
    QQmlComponent *component;
    QObject *object;
    QQmlContext *context;
};

#endif // COMMON_H
