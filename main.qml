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
    property double currentPos

    function appendLog(message) {
        let prefix = "";
        if (showTimestamp) {
            let date = new Date();
            prefix = "[" + date.toLocaleTimeString() + "] ";
        }

        let flickable = logScrollView.contentItem;
        let oldContentY = flickable.contentY;

        logArea.append(prefix + message);

        Qt.callLater(function() {
            if (autoScroll) {
                if (flickable.contentHeight > flickable.height) {
                    flickable.contentY = flickable.contentHeight - flickable.height;
                }
            } else {
                flickable.contentY = oldContentY;
            }
        });
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

                        // Saat (Timestamp) Butonu (Canvas)
                        Button {
                            implicitWidth: 32; implicitHeight: 32
                            background: Rectangle { color: mainWindow.showTimestamp ? "#45475a" : "transparent"; radius: 4 }
                            contentItem: Canvas {
                                anchors.fill: parent; anchors.margins: 5
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset(); ctx.strokeStyle = "#a6adc8"; ctx.lineWidth = 2;
                                    ctx.beginPath();
                                    ctx.arc(width/2, height/2, width/2 - 1, 0, Math.PI * 2);
                                    ctx.moveTo(width/2, height/4); ctx.lineTo(width/2, height/2);
                                    ctx.lineTo(width*0.75, height/2);
                                    ctx.stroke();
                                }
                            }
                            onClicked: mainWindow.showTimestamp = !mainWindow.showTimestamp
                        }

                        // Kaydırma (Autoscroll) Butonu (Canvas)
                        Button {
                            implicitWidth: 32; implicitHeight: 32
                            background: Rectangle { color: mainWindow.autoScroll ? "#45475a" : "transparent"; radius: 4 }
                            contentItem: Canvas {
                                anchors.fill: parent; anchors.margins: 7
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset(); ctx.strokeStyle = "#a6adc8"; ctx.lineWidth = 2;
                                    ctx.beginPath();
                                    ctx.moveTo(width/2, 0); ctx.lineTo(width/2, height);
                                    ctx.moveTo(width/4, height*0.6); ctx.lineTo(width/2, height);
                                    ctx.lineTo(width*0.75, height*0.6);
                                    ctx.stroke();
                                }
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
                            text: "[Sistem] FlyBoard Arayüzü Başlatıldı...\n"
                        }
                    }

                    // Komut Gönderme (Tx) Alanı
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        TextField {
                            id: cmdInput
                            Layout.fillWidth: true
                            placeholderText: "Gönderilecek komut..."
                            color: "#cdd6f4"
                            font.family: "Monospace"
                            background: Rectangle { color: "#313244"; radius: 4; implicitHeight: 32}
                            onAccepted: sendBtn.clicked()
                        }

                        // Gönder Butonu (Canvas)
                        Button {
                            id: sendBtn
                            implicitWidth: 40; implicitHeight: 32
                            background: Rectangle { color: sendBtn.pressed ? "#1565C0" : "#313244"; radius: 4 }
                            contentItem: Canvas {
                                anchors.fill: parent; anchors.margins: 8
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset(); ctx.fillStyle = "#a6e3a1";
                                    ctx.beginPath();
                                    ctx.moveTo(0, height/4); ctx.lineTo(width, height/2);
                                    ctx.lineTo(0, height*0.75); ctx.lineTo(width/4, height/2);
                                    ctx.closePath(); ctx.fill();
                                }
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
