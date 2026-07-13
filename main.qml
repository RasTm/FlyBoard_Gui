import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    width: 1280
    height: 720
    visible: true
    title: "FlyBoard Yer Kontrol İstasyonu"
    color: "#11111b" // Koyu arka plan (Mission Planner hissi için)

    // Bağlantı durumunu global olarak tutacağımız değişken
    property bool isConnected: false

    // Zaman damgalı Log ekleme fonksiyonu
    function appendLog(message) {
        let date = new Date();
        let timeString = date.toLocaleTimeString();
        logArea.append("[" + timeString + "] " + message);
    }

    // ==========================================
    // ÜST MENÜ BAR (HEADER)
    // ==========================================
    header: ToolBar {
        background: Rectangle {
            color: "#181825"

            // Alt çizgi efekti için
            Rectangle {
                width: parent.width
                height: 2
                color: "#313244"
                anchors.bottom: parent.bottom
            }
        }
        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 15

            // Sol Taraf: Navigasyon Sekmeleri (Şimdilik görsel)
            TabBar {
                id: navBar
                background: Rectangle { color: "transparent" }
                TabButton { text: "UÇUŞ VERİSİ"; font.bold: true }
                TabButton { text: "GÖREV PLANI"; font.bold: true }
                TabButton { text: "AYARLAR"; font.bold: true }
            }

            // Araya boşluk ekleyici
            Item { Layout.fillWidth: true }

            // Sağ Taraf: Bağlantı Kontrolleri
            Text { text: "PORT:"; color: "#a6adc8"; font.bold: true }
            TextField {
                id: portInput
                text: "/dev/ttyUSB0" // RPi için varsayılan
                color: "#cdd6f4"
                background: Rectangle { color: "#313244"; radius: 4 }
                implicitWidth: 130
            }

            Text { text: "BAUD:"; color: "#a6adc8"; font.bold: true }
            ComboBox {
                id: baudInput
                model: ["9600", "57600", "115200", "460800", "921600"]
                currentIndex: 2 // Varsayılan olarak 115200 seçili gelir
                background: Rectangle { color: "#313244"; radius: 4 }
            }

            Button {
                text: "BAĞLAN"
                highlighted: true
                enabled: !mainWindow.isConnected
                onClicked: serialManager.connectPort(portInput.text, parseInt(baudInput.currentText))
            }

            Button {
                text: "KAPAT"
                enabled: mainWindow.isConnected
                onClicked: serialManager.disconnectPort()
            }

            // Durum Ledi (Yuvarlak)
            Rectangle {
                width: 16; height: 16; radius: 8
                color: mainWindow.isConnected ? "#a6e3a1" : "#f38ba8"
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // ==========================================
    // ANA EKRAN: 4'LÜ IZGARA (QUADRANT LAYOUT)
    // ==========================================
    GridLayout {
        anchors.fill: parent
        anchors.margins: 10
        columns: 2
        rows: 2
        columnSpacing: 10
        rowSpacing: 10

        // 1. KADRAN (SOL ÜST): YAPAY UFUK (PFD)
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2
            clip: true // İçindeki nesnelerin dışarı taşmasını engeller

            // Ufuk Çizgisi Simülasyonu (Roll ve Pitch'e göre hareket eder)
            Rectangle {
                width: parent.width * 2
                height: parent.height * 2
                anchors.centerIn: parent
                // Sensörden gelen verilere göre anlık dönüş ve kayma hesaplamaları
                rotation: -serialManager.roll
                y: (parent.height / 2) + (serialManager.pitch * 6) - (height / 2)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#89b4fa" } // Gökyüzü Mavi
                    GradientStop { position: 0.5; color: "#89b4fa" }
                    GradientStop { position: 0.505; color: "#a6e3a1" } // Toprak Yeşil
                    GradientStop { position: 1.0; color: "#a6e3a1" }
                }
            }

            // Yapay Ufuk Merkez Sabit İmleci
            Rectangle { width: 60; height: 3; color: "#f38ba8"; anchors.centerIn: parent }
            Rectangle { width: 3; height: 20; color: "#f38ba8"; anchors.centerIn: parent }

            Text {
                text: "YAPAY UFUK (PFD)"; color: "#ffffff"; font.bold: true;
                anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: 10
            }
        }

        // 2. KADRAN (SAĞ ÜST): HARİTA
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2

            Text {
                text: "🗺️ HARİTA MODÜLÜ\n\n(Çevrimdışı Harita Altlıkları Buraya Yüklenecek)"
                color: "#a6adc8"; font.pixelSize: 18; font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
            }
        }

        // 3. KADRAN (SOL ALT): SAYISAL VERİLER
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2

            GridLayout {
                anchors.fill: parent; anchors.margins: 10
                columns: 2; rows: 2

                // Roll
                Column {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    anchors.margins: 10
                    Text { text: "ROLL"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: serialManager.roll.toFixed(2) + "°"; color: "#f38ba8"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                }
                // Pitch
                Column {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    anchors.margins: 10
                    Text { text: "PITCH"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: serialManager.pitch.toFixed(2) + "°"; color: "#a6e3a1"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                }
                // Yaw
                Column {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    anchors.margins: 10
                    Text { text: "YAW"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: serialManager.yaw.toFixed(2) + "°"; color: "#89b4fa"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                }
                // İrtifa
                Column {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    anchors.margins: 10
                    Text { text: "İRTİFA"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: serialManager.altitude.toFixed(1) + " m"; color: "#f9e2af"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }
        }

        // 4. KADRAN (SAĞ ALT): AKAN LOG VE SİSTEM MESAJLARI
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "#11111b"; radius: 8; border.color: "#313244"; border.width: 2

            Text {
                text: "SİSTEM LOGLARI"; color: "#a6adc8"; font.bold: true
                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 10
            }

            ScrollView {
                anchors.fill: parent
                anchors.topMargin: 35 // Başlığın altına al
                anchors.margins: 10

                TextArea {
                    id: logArea
                    readOnly: true
                    color: "#cdd6f4"
                    font.family: "Monospace"
                    font.pixelSize: 13
                    text: "[Sistem] GCS Arayüzü Başlatıldı...\n"
                    background: null // Arka planı şeffaf yap
                }
            }
        }
    }

    // ==========================================
    // C++ BACKEND BAĞLANTILARI
    // ==========================================
    Connections {
        target: serialManager

        function onConnectionStatusChanged(status, message) {
            mainWindow.isConnected = status;
            appendLog(message);
        }

        // Hata ayıklama veya ilk verinin geldiğini görmek istersen loga ekleyebiliriz
        // (Çok hızlı aktığı için normalde telemetri loga yazdırılmaz)
    }
}
