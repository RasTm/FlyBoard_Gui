import QtQuick
import QtQuick.Window

Window {
    width: 1920
    height: 1080
    visible: true
    title: "FlyBoard Gui v1.0"
    color: "#141419" // Koyu tema arka planı

    Text {
        anchors.centerIn: parent
        text: "FlyBoard Grafik Motoru Aktif"
        color: "#ffffff"
        font.pointSize: 20
        font.bold: true
    }
}
