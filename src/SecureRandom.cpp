#include "SecureRandom.h"

#include <QRandomGenerator>
#include <QtGlobal>

SecureRandom::SecureRandom(QObject *parent)
    : QObject(parent)
{
}

int SecureRandom::bounded(int maximum)
{
    if (maximum <= 0) {
        qWarning("SecureRandom: maximum must be positive");
        return -1;
    }

    return QRandomGenerator::system()->bounded(maximum);
}