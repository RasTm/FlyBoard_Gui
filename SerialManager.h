#ifndef SERIALMANAGER_H
#define SERIALMANAGER_H

#include <QObject>
#include <QSerialPort>
#include <QStringList>
#include "Telemetry.h"

class SerialManager : public QObject {
    Q_OBJECT
    // QML arayüzünden doğrudan erişebileceğimiz değişkenler
    Q_PROPERTY(float roll READ roll NOTIFY telemetryUpdated)
    Q_PROPERTY(float pitch READ pitch NOTIFY telemetryUpdated)
    Q_PROPERTY(float yaw READ yaw NOTIFY telemetryUpdated)
    Q_PROPERTY(float altitude READ altitude NOTIFY telemetryUpdated)

public:
    Q_INVOKABLE QStringList getAvailablePorts();
    explicit SerialManager(QObject *parent = nullptr);
    ~SerialManager();

    // QML'den butonlarla çağırabileceğimiz fonksiyonlar
    Q_INVOKABLE void connectPort(const QString &portName, int baudRate);
    Q_INVOKABLE void disconnectPort();

    // Okuma fonksiyonları
    float roll() const { return m_packet.roll; }
    float pitch() const { return m_packet.pitch; }
    float yaw() const { return m_packet.yaw; }
    float altitude() const { return m_packet.altitude; }

signals:
    // QML'e verinin veya bağlantı durumunun değiştiğini haber veren sinyaller
    void telemetryUpdated();
    void connectionStatusChanged(bool isConnected, const QString &message);

private slots:
    // Seri porttan yeni bayt geldiğinde tetiklenen donanım kesmesi (slot)
    void readData();

private:
    QSerialPort m_serial;
    TelemetryPacket m_packet;
    QByteArray m_buffer;
};

#endif // SERIALMANAGER_H
