import os
import sys
import subprocess
import shutil
import platform

def run_command(cmd):
    print(f"\n>>> Çalıştırılıyor: {cmd}")
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"HATA: Komut başarısız oldu (Hata Kodu: {e.returncode})")
        sys.exit(1)

def install_linux():
    print("Linux tabanlı sistem algılandı.")

    if shutil.which("pacman"):
        print("Paket Yöneticisi: pacman (Arch / CachyOS / Manjaro)")
        cmd = "sudo pacman -Syu --needed --noconfirm cmake ninja qt6-base qt6-declarative qt6-serialport qt6-wayland clang base-devel"
        run_command(cmd)

    elif shutil.which("apt"):
        print("Paket Yöneticisi: apt (Debian / Ubuntu / Raspberry Pi OS)")
        run_command("sudo apt update")
        cmd = "sudo apt install -y build-essential cmake ninja-build qt6-base-dev qt6-declarative-dev libqt6serialport6 qt6-wayland mesa-utils"
        run_command(cmd)

    elif shutil.which("dnf"):
        print("Paket Yöneticisi: dnf (Fedora / RHEL)")
        cmd = "sudo dnf install -y gcc-c++ cmake ninja-build qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtserialport-devel qt6-qtwayland-devel"
        run_command(cmd)

    else:
        print("Desteklenmeyen veya paket yöneticisi bulunamayan bir Linux dağıtımı kullanıyorsunuz.")
        sys.exit(1)

def install_windows():
    print("Windows işletim sistemi algılandı.")

    if not shutil.which("winget"):
        print("HATA: 'winget' (Windows Paket Yöneticisi) bulunamadı.")
        print("Lütfen Microsoft Store üzerinden 'Uygulama Yükleyicisi'ni (App Installer) güncelleyin.")
        sys.exit(1)

    print("Temel C++ araçları Winget ile kuruluyor...")
    run_command("winget install -e --id Kitware.CMake --accept-source-agreements --accept-package-agreements")
    run_command("winget install -e --id Ninja-build.Ninja --accept-source-agreements --accept-package-agreements")

    # Windows'ta C++ Qt6 için en stabil ortam MSYS2'dir (Pacman kullanır)
    print("\nMSYS2 (Linux benzeri geliştirme ortamı) kuruluyor...")
    run_command("winget install -e --id MSYS2.MSYS2 --accept-source-agreements --accept-package-agreements")

    print("\n" + "="*60)
    print("WINDOWS İÇİN ÖNEMLİ BİLGİLENDİRME:")
    print("Windows'ta g++ ve Qt6'nın en sorunsuz çalıştığı yer MSYS2 ortamıdır.")
    print("Winget şu an MSYS2'yi kurdu. Lütfen başlat menüsünden 'MSYS2 UCRT64' terminalini açın")
    print("ve aşağıdaki komutu kopyalayıp yapıştırarak Qt6 bileşenlerini indirin:")
    print("\npacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-qt6-base mingw-w64-ucrt-x86_64-qt6-declarative mingw-w64-ucrt-x86_64-qt6-serialport")
    print("="*60)

def main():
    os_name = platform.system()

    print(f"--- FlyBoard Geliştirme Ortamı Kurulum Aracı ---")

    if os_name == "Linux":
        install_linux()
    elif os_name == "Windows":
        install_windows()
    elif os_name == "Darwin":
        print("macOS algılandı. Homebrew kullanılıyor...")
        run_command("brew install cmake ninja qt6")
    else:
        print(f"Bilinmeyen işletim sistemi: {os_name}")
        sys.exit(1)

    print("\nKurulum işlemi tamamlandı! Kodlamaya başlayabilirsiniz.")

if __name__ == "__main__":
    main()
