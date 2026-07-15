cmake_minimum_required(VERSION 3.16)
project(FlyBoard-Gui VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Zed editörünün (clangd) Qt sınıflarını tanıması için bu satır şarttır
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick SerialPort QuickControls2 Svg Location Positioning)

qt_standard_project_setup()

# Derlenecek C++ dosyaları
qt_add_executable(FlyBoard_Gui
    main.cpp
    Telemetry.h
    SerialManager.h
    SerialManager.cpp
)

# Arayüz (QML) modülü tanımı
qt_add_qml_module(FlyBoard_Gui
    URI GCSApp
    VERSION 1.0
    QML_FILES main.qml
)

# Kütüphane bağlantıları
target_link_libraries(FlyBoard_Gui PRIVATE
    Qt6::Svg
    Qt6::Core
    Qt6::Quick
    Qt6::Location
    Qt6::SerialPort
    Qt6::Positioning
    Qt6::QuickControls2
)
