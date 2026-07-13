import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    width: 800
    height: 600
    visible: true
    title: "Yer Kontrol İstasyonu v1.0"
    color: "#1e1e2e" // Koyu modern tema

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // ÜST BAR: Bağlantı Kontrolleri
        RowLayout {
            spacing: 15

            TextField {
                id: portInput
                placeholderText: "/dev/ttyUSB0"
                text: "/dev/ttyUSB0" // Windows'ta burayı "COM3" gibi değiştirebilirsin
                color: "#cdd6f4"
                background: Rectangle { color: "#313244"; radius: 5 }
            }

            TextField {
                id: baudInput
                placeholderText: "Baudrate"
                text: "115200"
                color: "#cdd6f4"
                background: Rectangle { color: "#313244"; radius: 5 }
            }

            Button {
                text: "Bağlan"
                onClicked: serialManager.connectPort(portInput.text, parseInt(baudInput.text))
            }

            Button {
                text: "Kapat"
                onClicked: serialManager.disconnectPort()
            }

            Text {
                id: statusText
                text: "Bağlantı Bekleniyor..."
                color: "#a6adc8"
                font.pixelSize: 14
                Layout.fillWidth: true
            }
        }

        // ALT KISIM: Telemetri Göstergeleri
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            rowSpacing: 20
            columnSpacing: 20

            // ROLL GÖSTERGESİ
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#313244"; radius: 10
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text { text: "ROLL"; color: "#a6adc8"; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text {
                        text: serialManager.roll.toFixed(2) + "°"
                        color: "#f38ba8"; font.pixelSize: 45; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // PITCH GÖSTERGESİ
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#313244"; radius: 10
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text { text: "PITCH"; color: "#a6adc8"; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text {
                        text: serialManager.pitch.toFixed(2) + "°"
                        color: "#a6e3a1"; font.pixelSize: 45; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // YAW GÖSTERGESİ
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#313244"; radius: 10
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text { text: "YAW"; color: "#a6adc8"; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text {
                        text: serialManager.yaw.toFixed(2) + "°"
                        color: "#89b4fa"; font.pixelSize: 45; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // İRTİFA (ALTITUDE) GÖSTERGESİ
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#313244"; radius: 10
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text { text: "İRTİFA"; color: "#a6adc8"; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text {
                        text: serialManager.altitude.toFixed(1) + " m"
                        color: "#f9e2af"; font.pixelSize: 45; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    // C++ Backend'den Gelen Sinyalleri Dinleme
    Connections {
        target: serialManager
        function onConnectionStatusChanged(isConnected, message) {
            statusText.text = message
            statusText.color = isConnected ? "#a6e3a1" : "#f38ba8"
        }
    }
}
