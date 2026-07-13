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

    // Global Değişkenler
    property bool isConnected: false
    property bool showTimestamp: true
    property bool autoScroll: true

    // Gelişmiş Log Ekleme Fonksiyonu
    function appendLog(message) {
        let prefix = "";
        if (showTimestamp) {
            let date = new Date();
            prefix = "[" + date.toLocaleTimeString() + "] ";
        }

        logArea.append(prefix + message);

        // Eğer otomatik kaydırma açıksa scroll barı en alta zorla
        if (autoScroll) {
            logScrollView.ScrollBar.vertical.position = 1.0;
        }
    }

    // ==========================================
    // ÜST MENÜ BAR (HEADER)
    // ==========================================
    header: ToolBar {
        background: Rectangle {
            color: "#181825"
            Rectangle { width: parent.width; height: 2; color: "#313244"; anchors.bottom: parent.bottom }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 15

            TabBar {
                id: navBar
                background: Rectangle { color: "transparent" }
                TabButton { text: "UÇUŞ VERİSİ"; font.bold: true; implicitWidth: contentItem.implicitWidth + 40 }
                TabButton { text: "GÖREV PLANI"; font.bold: true; implicitWidth: contentItem.implicitWidth + 40 }
                TabButton { text: "AYARLAR"; font.bold: true; implicitWidth: contentItem.implicitWidth + 40 }
            }

            Item { Layout.fillWidth: true }

            Text { text: "PORT:"; color: "#a6adc8"; font.bold: true }
            ComboBox {
                id: portInput
                onPressedChanged: { if (pressed) { model = serialManager.getAvailablePorts() } }
                Component.onCompleted: model = serialManager.getAvailablePorts()

                delegate: ItemDelegate {
                    width: portInput.width
                    contentItem: Text { text: modelData; color: "#cdd6f4"; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: hovered ? "#45475a" : "#1e1e2e" }
                }
                contentItem: Text { text: portInput.currentText; color: "#cdd6f4"; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                background: Rectangle { color: "#313244"; radius: 4; implicitWidth: 150; implicitHeight: parent.height }
            }

            Text { text: "BAUD:"; color: "#a6adc8"; font.bold: true }
            ComboBox {
                id: baudInput
                model: ["9600", "57600", "115200", "460800", "921600"]
                currentIndex: 2
                delegate: ItemDelegate {
                    width: baudInput.width
                    contentItem: Text { text: modelData; color: "#cdd6f4"; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: hovered ? "#45475a" : "#1e1e2e" }
                }
                contentItem: Text { text: baudInput.currentText; color: "#cdd6f4"; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                background: Rectangle { color: "#313244"; radius: 4; implicitWidth: 100; implicitHeight: parent.height }
            }

            Button {
                text: "BAĞLAN"; highlighted: true; enabled: !mainWindow.isConnected
                onClicked: serialManager.connectPort(portInput.currentText, parseInt(baudInput.currentText))
            }
            Button {
                text: "KAPAT"; enabled: mainWindow.isConnected
                onClicked: serialManager.disconnectPort()
            }
            Rectangle { width: 16; height: 16; radius: 8; color: mainWindow.isConnected ? "#a6e3a1" : "#f38ba8"; Layout.alignment: Qt.AlignVCenter }
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
                color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2; clip: true

                Rectangle {
                    width: parent.width * 2; height: parent.height * 2; anchors.centerIn: parent
                    rotation: -serialManager.roll; y: (parent.height / 2) + (serialManager.pitch * 6) - (height / 2)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#89b4fa" }
                        GradientStop { position: 0.5; color: "#89b4fa" }
                        GradientStop { position: 0.505; color: "#a6e3a1" }
                        GradientStop { position: 1.0; color: "#a6e3a1" }
                    }
                }
                Rectangle { width: 60; height: 3; color: "#f38ba8"; anchors.centerIn: parent }
                Rectangle { width: 3; height: 20; color: "#f38ba8"; anchors.centerIn: parent }
                Text { text: "YAPAY UFUK (PFD)"; color: "#ffffff"; font.bold: true; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: 10 }
            }

            // SAYISAL VERİLER
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#1e1e2e"; radius: 8; border.color: "#313244"; border.width: 2

                GridLayout {
                    anchors.fill: parent; anchors.margins: 10; columns: 2; rows: 2

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
                Text { text: "HARİTA MODÜLÜ\n\n(Çevrimdışı Harita Altlıkları Buraya Yüklenecek)"; color: "#a6adc8"; font.pixelSize: 18; font.bold: true; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent }
            }

            // GELİŞMİŞ SİSTEM LOGLARI VE TERMİNAL
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#11111b"; radius: 8; border.color: "#313244"; border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    // Başlık ve Kontrol Butonları
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "SİSTEM LOGLARI & TERMİNAL"; color: "#a6adc8"; font.bold: true; Layout.fillWidth: true }

                        // Saat (Timestamp) Butonu
                        Button {
                            implicitWidth: 32; implicitHeight: 32
                            background: Rectangle { color: mainWindow.showTimestamp ? "#45475a" : "transparent"; radius: 4 }
                            contentItem: Image {
                                source: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNhNmFkYzgiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCI+PC9jaXJjbGU+PHBvbHlsaW5lIHBvaW50cz0iMTIgNiAxMiAxMiAxNiAxNCI+PC9wb2x5bGluZT48L3N2Zz4="
                                fillMode: Image.PreserveAspectFit
                                anchors.margins: 6
                                anchors.fill: parent
                            }
                            onClicked: mainWindow.showTimestamp = !mainWindow.showTimestamp
                        }

                        // Kaydırma (Autoscroll) Butonu
                        Button {
                            implicitWidth: 32; implicitHeight: 32
                            background: Rectangle { color: mainWindow.autoScroll ? "#45475a" : "transparent"; radius: 4 }
                            contentItem: Image {
                                source: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNhNmFkYzgiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48bGluZSB4MT0iMTIiIHkxPSI1IiB4Mj0iMTIiIHkyPSIxOSI+PC9saW5lPjxwb2x5bGluZSBwb2ludHM9IjE5IDEyIDEyIDE5IDUgMTIiPjwvcG9seWxpbmU+PC9zdmc+"
                                fillMode: Image.PreserveAspectFit
                                anchors.margins: 6
                                anchors.fill: parent
                            }
                            onClicked: mainWindow.autoScroll = !mainWindow.autoScroll
                        }
                    }

                    // Akan Log Ekranı
                    ScrollView {
                        id: logScrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        TextArea {
                            id: logArea
                            readOnly: true
                            color: "#cdd6f4"
                            font.family: "Monospace"
                            font.pixelSize: 13
                            background: null
                            text: "[Sistem] GCS Arayüzü Başlatıldı...\n"
                        }
                    }

                    // Komut Gönderme (Tx) Alanı
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        TextField {
                            id: cmdInput
                            Layout.fillWidth: true
                            placeholderText: "Gönderilecek komut (Örn: CALIBRATE_GYRO veya P=1.5)"
                            color: "#cdd6f4"
                            font.family: "Monospace"
                            background: Rectangle { color: "#313244"; radius: 4 }
                            onAccepted: sendBtn.clicked()
                        }

                        Button {
                            id: sendBtn
                            implicitWidth: 40; implicitHeight: 40
                            background: Rectangle { color: "#313244"; radius: 4 }
                            contentItem: Image {
                                source: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNhNmUzYTEiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48bGluZSB4MT0iMjIiIHkxPSIyIiB4Mj0iMTEiIHkyPSIxMyI+PC9saW5lPjxwb2x5Z29uIHBvaW50cz0iMjIgMiAxNSAyMiAxMSAxMyAyIDkgMjIgMiI+PC9wb2x5Z29uPjwvc3ZnPg=="
                                fillMode: Image.PreserveAspectFit
                                anchors.margins: 10
                                anchors.fill: parent
                            }
                            onClicked: {
                                if(cmdInput.text !== "") {
                                    serialManager.sendCommand(cmdInput.text)
                                    appendLog("-> Gönderildi: " + cmdInput.text)
                                    cmdInput.text = ""
                                }
                            }
                        }
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
