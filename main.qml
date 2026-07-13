import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    width: 1280
    height: 720
    visible: true
    title: "FlyBoard Yer Kontrol İstasyonu"
    color: "#11111b"

    property bool isConnected: false

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

            TabBar {
                id: navBar
                background: Rectangle { color: "transparent" }

                TabButton {
                    text: "UÇUŞ VERİSİ"
                    font.bold: true
                    implicitWidth: contentItem.implicitWidth + 40
                }
                TabButton {
                    text: "GÖREV PLANI"
                    font.bold: true
                    implicitWidth: contentItem.implicitWidth + 40
                }
                TabButton {
                    text: "AYARLAR"
                    font.bold: true
                    implicitWidth: contentItem.implicitWidth + 40
                }
            }

            Item { Layout.fillWidth: true }

            Text { text: "PORT:"; color: "#a6adc8"; font.bold: true }
            ComboBox {
                id: portInput

                // Menüye her tıklandığında listeyi baştan günceller (Cihaz tak/çıkar algılaması için)
                onPressedChanged: {
                    if (pressed) {
                        model = serialManager.getAvailablePorts()
                    }
                }

                // İlk açılışta portları listelemesi için
                Component.onCompleted: model = serialManager.getAvailablePorts()

                // Aşağı doğru açılan menünün tasarımı (Görünmez yazıları engeller)
                delegate: ItemDelegate {
                    width: portInput.width
                    contentItem: Text {
                        text: modelData
                        color: "#cdd6f4"
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: hovered ? "#45475a" : "#1e1e2e" }
                }

                // Kutu kapalıyken görünen seçili öğenin tasarımı
                contentItem: Text {
                    text: portInput.currentText
                    color: "#cdd6f4"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                background: Rectangle { color: "#313244"; radius: 4; implicitWidth: 150; implicitHeight: parent.height }
            }

            Text { text: "BAUD:"; color: "#a6adc8"; font.bold: true }
            ComboBox {
                id: baudInput
                model: ["9600", "57600", "115200", "460800", "921600"]
                currentIndex: 2

                // Menü açıkken listelenen öğelerin tasarımı (Görünmeme sorunu çözümü)
                delegate: ItemDelegate {
                    width: baudInput.width
                    contentItem: Text {
                        text: modelData
                        color: "#cdd6f4"
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: hovered ? "#45475a" : "#1e1e2e" }
                }

                // Seçili öğenin dışarıdaki tasarımı
                contentItem: Text {
                    text: baudInput.currentText
                    color: "#cdd6f4"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                background: Rectangle { color: "#313244"; radius: 4; implicitWidth: 100; implicitHeight: parent.height }
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

            Rectangle {
                width: 16; height: 16; radius: 8
                color: mainWindow.isConnected ? "#a6e3a1" : "#f38ba8"
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // ==========================================
    // ANA EKRAN: SOL (%35) ve SAĞ (%65) SÜTUNLAR
    // ==========================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // ---------------- SOL SÜTUN ----------------
        ColumnLayout {
            Layout.preferredWidth: parent.width * 0.35
            Layout.fillHeight: true
            spacing: 10

            // YAPAY UFUK (PFD)
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2
                clip: true

                Rectangle {
                    width: parent.width * 2
                    height: parent.height * 2
                    anchors.centerIn: parent
                    rotation: -serialManager.roll
                    y: (parent.height / 2) + (serialManager.pitch * 6) - (height / 2)

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#89b4fa" }
                        GradientStop { position: 0.5; color: "#89b4fa" }
                        GradientStop { position: 0.505; color: "#a6e3a1" }
                        GradientStop { position: 1.0; color: "#a6e3a1" }
                    }
                }

                Rectangle { width: 60; height: 3; color: "#f38ba8"; anchors.centerIn: parent }
                Rectangle { width: 3; height: 20; color: "#f38ba8"; anchors.centerIn: parent }

                Text {
                    text: "YAPAY UFUK (PFD)"; color: "#ffffff"; font.bold: true;
                    anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: 10
                }
            }

            // SAYISAL VERİLER
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2

                GridLayout {
                    anchors.fill: parent; anchors.margins: 10
                    columns: 2; rows: 2

                    Column {
                        Layout.fillWidth: true; Layout.fillHeight: true; anchors.margins: 5
                        Text { text: "ROLL"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: serialManager.roll.toFixed(2) + "°"; color: "#f38ba8"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    Column {
                        Layout.fillWidth: true; Layout.fillHeight: true; anchors.margins: 5
                        Text { text: "PITCH"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: serialManager.pitch.toFixed(2) + "°"; color: "#a6e3a1"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    Column {
                        Layout.fillWidth: true; Layout.fillHeight: true; anchors.margins: 5
                        Text { text: "YAW"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: serialManager.yaw.toFixed(2) + "°"; color: "#89b4fa"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    Column {
                        Layout.fillWidth: true; Layout.fillHeight: true; anchors.margins: 5
                        Text { text: "İRTİFA"; color: "#a6adc8"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: serialManager.altitude.toFixed(1) + " m"; color: "#f9e2af"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }
        }

        // ---------------- SAĞ SÜTUN ----------------
        ColumnLayout {
            Layout.preferredWidth: parent.width * 0.65
            Layout.fillHeight: true
            spacing: 10

            // HARİTA
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

            // AKAN LOG
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#11111b"; radius: 8; border.color: "#313244"; border.width: 2

                Text {
                    text: "SİSTEM LOGLARI"; color: "#a6adc8"; font.bold: true
                    anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 10
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.topMargin: 35
                    anchors.margins: 10

                    TextArea {
                        id: logArea
                        readOnly: true
                        color: "#cdd6f4"
                        font.family: "Monospace"
                        font.pixelSize: 13
                        text: "[Sistem] GCS Arayüzü Başlatıldı...\n"
                        background: null
                    }
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
    }
}
