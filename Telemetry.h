#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <cstdint>

// Derleyiciye bu struct elemanları arasına boşluk (padding) koymamasını emreder.
#pragma pack(push, 1)

struct TelemetryPacket {
    uint8_t start_marker1 = 0x5A; // 'Z' karakteri - Paket başlangıç doğrulaması
    uint8_t start_marker2 = 0xA5; // Sabit imza bitleri
    uint8_t packet_id;            // 1: Telemetri, 2: PID Ayarı, 3: Komut Sonucu vb.

    // Payload (Esas veri katmanı)
    float roll;
    float pitch;
    float yaw;
    float altitude;               // MS5611 veya GPS verisi
    float battery_voltage;

    uint16_t checksum;            // Veri bütünlüğü için CRC16 veya XOR toplamı
};

#pragma pack(pop)

#endif // TELEMETRY_H
