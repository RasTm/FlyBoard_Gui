@echo off
REM Windows icin wxPython ve pyserial kurulumu

echo Sanal ortam olusturuluyor...
python -m venv venv

echo Sanal ortam aktif ediliyor...
call venv\Scripts\activate

echo pip guncelleniyor...
python.exe -m pip install --upgrade pip

echo Python paketleri yukleniyor...
pip install -r requirements.txt

echo Kurulum tamamlandi. Sanal ortam aktif durumda.
pause
