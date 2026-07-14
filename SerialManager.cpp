#include "SerialManager.h"
#include <QDebug>
#include <QSerialPortInfo>

SerialManager::SerialManager(QObject *parent) : QObject(parent) {
    // Seri porta yeni veri geldiğinde readData fonksiyonunu tetikle
    connect(&m_serial, &QSerialPort::readyRead, this, &SerialManager::readData);
}

SerialManager::~SerialManager() {
    if (m_serial.isOpen()) m_serial.close();
}

void SerialManager::connectPort(const QString &portName, int baudRate) {
    m_serial.setPortName(portName);
    m_serial.setBaudRate(baudRate);

    if (m_serial.open(QIODevice::ReadWrite)) {
        emit connectionStatusChanged(true, "Bağlantı Başarılı: " + portName);
    } else {
        emit connectionStatusChanged(false, "Hata: " + m_serial.errorString());
    }
}

void SerialManager::disconnectPort() {
    if (m_serial.isOpen()) {
        m_serial.close();
        emit connectionStatusChanged(false, "Bağlantı Kapatıldı");
    }
}

void SerialManager::readData() {
    m_buffer.append(m_serial.readAll());

    int packetSize = sizeof(TelemetryPacket);

    // Buffer'da en az 1 paketlik veri olduğu sürece dön
    while (m_buffer.size() >= packetSize) {

        // Başlangıç baytlarımızı (0x5A 0xA5) ara
        int startIndex = m_buffer.indexOf(QByteArrayLiteral("\x5A\xA5"));

        if (startIndex == -1) {
            // Geçerli bir paket başlangıcı yoksa buffer'ı temizle (çöp veriyi at)
            m_buffer.clear();
            break;
        }

        if (startIndex > 0) {
            // Başlangıç baytından önceki hatalı/kopuk verileri at
            m_buffer.remove(0, startIndex);
        }

        // Temizlemeden sonra paket boyutu yeterli değilse yeni veriyi bekle
        if (m_buffer.size() < packetSize) {
            break;
        }

        // 1 Tam paketi al
        QByteArray rawData = m_buffer.left(packetSize);

        // İŞTE EKSİK OLAN CHECKSUM KONTROLÜ
        // Son 2 bayt (checksum'ın kendisi) hariç tüm baytları topla
        uint16_t calculated_checksum = 0;
        for (int i = 0; i < packetSize - 2; ++i) {
            calculated_checksum += static_cast<uint8_t>(rawData[i]);
        }

        // Ham veriyi Struct yapısına dönüştür
        m_packet = *reinterpret_cast<const TelemetryPacket*>(rawData.constData());

        // Gelen paket ile bizim hesapladığımız değer aynıysa arayüzü güncelle
        if (m_packet.checksum == calculated_checksum) {
            emit telemetryUpdated();
        } else {
            // İstersen buraya log yazdırabilirsin, hatalı paketler sessizce yoksayılır
            qDebug() << "Hatalı paket reddedildi! Gelen:" << m_packet.checksum << " Hesaplanan:" << calculated_checksum;
        }

        // İşlenen/Atılan paketi buffer'dan çıkar ki bir sonraki pakete geçsin
        m_buffer.remove(0, packetSize);
    }
}

QStringList SerialManager::getAvailablePorts() {
    QStringList portList;
    const auto ports = QSerialPortInfo::availablePorts();

    for (const QSerialPortInfo &port : ports) {

        // Eğer port "ttyS" (veya Windows'ta sanal COM) ile başlıyorsa
        // ve cihazın sistemde hiçbir donanım açıklaması yoksa bu bir "Hayalet Port"tur.
        bool isGhostPort = port.portName().startsWith("ttyS") && port.description().isEmpty();

        if (!isGhostPort) {
            // Sadece gerçek donanımları (ttyUSB, ttyACM, ttyAMA) listeye ekle
            portList.append(port.systemLocation());
        }
    }

    return portList;
}

void SerialManager::sendCommand(const QString &command) {
    if (m_serial.isOpen()) {
        // Gelen metni byte dizisine çevir ve sonuna satır sonu (\n) ekle
        QByteArray data = command.toUtf8() + "\n";
        m_serial.write(data);
        m_serial.flush(); // İşletim sistemini beklemeden anında gönder
    }
}
