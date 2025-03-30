#!/bin/bash
# Linux (Ubuntu/Debian tabanli) icin wxPython bagimliliklarini yukleyin

echo "Sistem paketleri guncelleniyor..."
sudo apt update

echo "Gerekli sistem bagimliliklari kuruluyor..."
sudo apt install -y libgtk-3-dev libsdl2-dev libgstreamer1.0-dev

echo "Python sanal ortami olusturuluyor..."
python3 -m venv venv
source venv/bin/activate

echo "pip guncelleniyor..."
python3 -m pip install --upgrade pip

echo "Python paketleri yukleniyor..."
pip install -r requirements.txt

echo "Kurulum tamamlandi. Sanal ortam aktif durumda."
