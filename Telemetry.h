#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <cstdint>

#pragma pack(push, 1)

struct TelemetryPacket {
    uint8_t start_marker1 = 0x5A;
    uint8_t start_marker2 = 0xA5;
    uint8_t packet_id = 0;

    // Değerlerin RAM'deki çöp verileri almasını engellemek için sıfırlıyoruz
    float roll = 0.0f;
    float pitch = 0.0f;
    float yaw = 0.0f;
    float altitude = 0.0f;
    float battery_voltage = 0.0f;

    uint16_t checksum = 0;
};

#pragma pack(pop)

#endif // TELEMETRY_H
