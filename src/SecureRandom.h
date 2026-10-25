#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class SecureRandom : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit SecureRandom(QObject *parent = nullptr);

    Q_INVOKABLE int bounded(int maximum);
};