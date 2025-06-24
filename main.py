import wx
import os
import folium
from wx.html2 import WebView
import threading
import time
import serial
import serial.tools.list_ports

# === Yapay Ufuk Paneli (Statik) ===
class ArtificialHorizonPanel(wx.Panel):
    def __init__(self, parent):
        super().__init__(parent, size=(400, 250))
        self.Bind(wx.EVT_PAINT, self.on_paint)

    def on_paint(self, event):
        dc = wx.BufferedPaintDC(self)
        w, h = self.GetSize()
        cx, cy = w // 2, h // 2

        dc.SetBrush(wx.Brush(wx.Colour(135, 206, 235)))
        dc.DrawRectangle(0, 0, w, h // 2)
        dc.SetBrush(wx.Brush(wx.Colour(0, 100, 0)))
        dc.DrawRectangle(0, h // 2, w, h // 2)

        dc.SetPen(wx.Pen("white", 1))
        dc.SetTextForeground("white")
        dc.SetFont(wx.Font(9, wx.DEFAULT, wx.NORMAL, wx.NORMAL))
        for angle in [-20, -10, 0, 10, 20]:
            y = cy - angle * 3
            dc.DrawLine(cx - 40, y, cx + 40, y)
            dc.DrawText(f"{angle:+}", cx + 50, y - 6)

        dc.SetPen(wx.Pen("red", 3))
        dc.DrawLine(cx - 25, cy, cx + 25, cy)
        dc.SetPen(wx.Pen("red", 1, style=wx.PENSTYLE_DOT))
        dc.DrawLine(cx, cy - 20, cx, cy + 20)

# === Giriş Ekranı ===
class GirisEkrani(wx.Frame):
    def __init__(self):
        super().__init__(None, title="FenrasTech Giriş", size=(500, 300))
        panel = wx.Panel(self)
        vbox = wx.BoxSizer(wx.VERTICAL)

        baslik = wx.StaticText(panel, label="FenrasTech Yer İstasyonu")
        baslik.SetFont(wx.Font(16, wx.DEFAULT, wx.NORMAL, wx.BOLD))
        vbox.Add(baslik, flag=wx.ALIGN_CENTER | wx.TOP, border=30)

        vbox.AddSpacer(20)
        vbox.Add(wx.StaticText(panel, label="Kullanıcı Adı:"), flag=wx.ALIGN_CENTER)
        self.user_input = wx.TextCtrl(panel)
        vbox.Add(self.user_input, flag=wx.ALIGN_CENTER | wx.ALL, border=10)

        btn = wx.Button(panel, label="GİRİŞ")
        btn.Bind(wx.EVT_BUTTON, self.on_enter)
        vbox.Add(btn, flag=wx.ALIGN_CENTER)

        panel.SetSizer(vbox)
        self.Centre()
        self.Show()

    def on_enter(self, event):
        if self.user_input.GetValue().strip().lower() == "fethi çelik":
            self.Hide()
            AnaPencere()
        else:
            wx.MessageBox("Yanlış kullanıcı adı!", "Hata", wx.ICON_ERROR)

# === Ana Pencere ===
class AnaPencere(wx.Frame):
    def __init__(self):
        super().__init__(None, title="FenrasTech Yer İstasyonu", size=(1200, 700))
        self.notebook = wx.Notebook(self)
        self.yer_istasyonu = YerIstasyonu(self.notebook)
        self.notebook.AddPage(self.yer_istasyonu, "Yer İstasyonu")
        self.notebook.AddPage(FlightPlan(self.notebook), "Flight Plan")
        self.notebook.AddPage(Help(self.notebook), "Help")
        self.notebook.AddPage(SerialSettings(self.notebook, self.yer_istasyonu), "Serial Bağlantı")
        self.Centre()
        self.Show()

# === Yer İstasyonu Sekmesi ===
class YerIstasyonu(wx.Panel):
    def __init__(self, parent):
        super().__init__(parent)
        self.horizon = ArtificialHorizonPanel(self)
        self.stats = {}
        self.veri_etiketleri = [
            "Yükseklik", "Hız", "Batarya", "GPS", "Volt", "Amper", "Basınç", "Sıcaklık", "Roll", "Pitch"
        ]
        veri_kutulari = []

        for etiket in self.veri_etiketleri:
            box = wx.StaticBox(self, label=etiket)
            sizer = wx.StaticBoxSizer(box, wx.VERTICAL)
            label = wx.StaticText(self, label="0" if etiket == "Hız" else ("40.739811, 30.334173" if etiket == "GPS" else "--"))
            label.SetFont(wx.Font(11, wx.DEFAULT, wx.NORMAL, wx.BOLD))
            sizer.Add(label, flag=wx.ALL, border=5)
            veri_kutulari.append(sizer)
            self.stats[etiket] = label

        grid = wx.GridSizer(rows=5, cols=2, hgap=10, vgap=10)
        for kutu in veri_kutulari:
            grid.Add(kutu, 1, wx.EXPAND)

        self.map_file = "yer_map.html"
        self.build_map()
        self.browser = WebView.New(self)
        self.browser.LoadURL("file:///" + os.path.abspath(self.map_file))

        left = wx.BoxSizer(wx.VERTICAL)
        left.Add(self.horizon, 0, wx.ALL | wx.ALIGN_CENTER, 5)
        left.Add(grid, 0, wx.EXPAND | wx.ALL, 10)

        right = wx.BoxSizer(wx.VERTICAL)
        right.Add(self.browser, 1, wx.EXPAND | wx.ALL, 5)

        main = wx.BoxSizer(wx.HORIZONTAL)
        main.Add(left, 0, wx.EXPAND | wx.ALL, 10)
        main.Add(right, 1, wx.EXPAND | wx.ALL, 10)
        self.SetSizer(main)

    def build_map(self):
        m = folium.Map(location=[40.739811, 30.334173], zoom_start=16)
        folium.Marker([40.739811, 30.334173], tooltip="Sakarya Üniversitesi").add_to(m)
        m.save(self.map_file)

    def update_stats(self, data):
        for k, v in data.items():
            if k in self.stats:
                self.stats[k].SetLabel(str(v))

# === Serial Bağlantı Sekmesi ===
class SerialSettings(wx.Panel):
    def __init__(self, parent, yer_istasyonu):
        super().__init__(parent)
        self.yer_istasyonu = yer_istasyonu
        self.ser = None

        self.baudrate_choice = wx.Choice(self, choices=["9600", "19200", "38400", "57600", "115200", "230400", "460800", "921600"])
        self.baudrate_choice.SetSelection(0)

        self.comport_choice = wx.Choice(self)
        self.refresh_ports()

        refresh_btn = wx.Button(self, label="Yenile")
        refresh_btn.Bind(wx.EVT_BUTTON, lambda e: self.refresh_ports())

        open_btn = wx.Button(self, label="Bağlan")
        open_btn.Bind(wx.EVT_BUTTON, self.on_connect)

        form = wx.BoxSizer(wx.VERTICAL)
        form.Add(wx.StaticText(self, label="Baudrate Seçin:"), flag=wx.TOP, border=10)
        form.Add(self.baudrate_choice, flag=wx.EXPAND | wx.ALL, border=5)
        form.Add(wx.StaticText(self, label="COM Port Seçin:"), flag=wx.TOP, border=10)
        form.Add(self.comport_choice, flag=wx.EXPAND | wx.ALL, border=5)
        form.Add(refresh_btn, flag=wx.ALIGN_CENTER | wx.ALL, border=5)
        form.Add(open_btn, flag=wx.ALIGN_CENTER | wx.TOP, border=20)
        self.SetSizer(form)

    def refresh_ports(self):
        ports = [port.device for port in serial.tools.list_ports.comports()]
        self.comport_choice.Clear()
        if ports:
            self.comport_choice.AppendItems(ports)
            self.comport_choice.SetSelection(0)
        else:
            self.comport_choice.Append("Port bulunamadı")
            self.comport_choice.SetSelection(0)

    def on_connect(self, event):
        baud = int(self.baudrate_choice.GetStringSelection())
        com = self.comport_choice.GetStringSelection()
        try:
            self.ser = serial.Serial(port=com, baudrate=baud, timeout=1)
            wx.MessageBox(f"{com} portu {baud} baud ile başarıyla açıldı!", "Bağlantı", wx.ICON_INFORMATION)
            threading.Thread(target=self.read_serial_data, daemon=True).start()
        except Exception as e:
            wx.MessageBox(f"Bağlantı hatası: {e}", "Hata", wx.ICON_ERROR)

    
    def read_serial_data(self):
     while True:
        try:
            if self.ser and self.ser.in_waiting:
                line = self.ser.readline().decode(errors='ignore').strip()
                if line:
                    parts = line.split('\t')
                    if len(parts) >= 7:
                        yukseklik = parts[0].replace('\x00', '').strip()  # 🛠️ Temizlik burada
                        volt = float(parts[1])
                        amper = parts[2]
                        basinc = parts[3]
                        sicaklik = parts[4]
                        roll = parts[5]
                        pitch = parts[6]
                        batarya_yuzde = min(100, round((volt / 12.6) * 100))
                        data = {
                            "Yükseklik": yukseklik,
                            "Volt": volt,
                            "Amper": amper,
                            "Basınç": basinc,
                            "Sıcaklık": sicaklik,
                            "Roll": roll,
                            "Pitch": pitch,
                            "Batarya": f"%{batarya_yuzde}",
                            "Hız": "0",
                            "GPS": "40.739811, 30.334173"
                        }
                    else:
                        data = {etiket: "--" for etiket in ["Yükseklik", "Volt", "Amper", "Basınç", "Sıcaklık", "Roll", "Pitch"]}
                        data.update({"Batarya": "--", "Hız": "0", "GPS": "40.739811, 30.334173"})
                    print("Gelen veri:", data)
                    wx.CallAfter(self.yer_istasyonu.update_stats, data)
            time.sleep(0.1)
        except Exception as e:
            print("Veri okuma hatası:", e)
            time.sleep(1)
            
# === Flight Plan Sekmesi ===
class FlightPlan(wx.Panel):
    def __init__(self, parent):
        super().__init__(parent)
        self.wp = []
        self.map_file = "fp_map.html"
        self.build_map()
        self.browser = WebView.New(self)
        self.browser.LoadURL("file:///" + os.path.abspath(self.map_file))

        lat_label = wx.StaticText(self, label="Lat: ")
        lon_label = wx.StaticText(self, label="Lon: ")
        self.lat_input = wx.TextCtrl(self)
        self.lon_input = wx.TextCtrl(self)
        btn_add = wx.Button(self, label="Waypoint Ekle")
        btn_add.Bind(wx.EVT_BUTTON, self.add_wp)

        form = wx.BoxSizer(wx.HORIZONTAL)
        form.AddMany([(lat_label, 0), (self.lat_input, 0),
                      (lon_label, 0), (self.lon_input, 0), (btn_add, 0)])

        layout = wx.BoxSizer(wx.VERTICAL)
        layout.Add(self.browser, 1, wx.EXPAND | wx.ALL, 5)
        layout.Add(form, 0, wx.ALIGN_CENTER | wx.ALL, 5)

        self.SetSizer(layout)

    def build_map(self):
        m = folium.Map(location=[40.7419, 30.3280], zoom_start=15)
        for idx, pt in enumerate(self.wp):
            folium.Marker(pt, tooltip=f"WP{idx+1}").add_to(m)
        if len(self.wp) > 1:
            folium.PolyLine(self.wp, color='blue').add_to(m)
        m.save(self.map_file)

    def add_wp(self, event):
        try:
            lat = float(self.lat_input.GetValue())
            lon = float(self.lon_input.GetValue())
            self.wp.append([lat, lon])
            self.build_map()
            self.browser.LoadURL("file:///" + os.path.abspath(self.map_file))
        except ValueError:
            wx.MessageBox("Geçerli koordinatlar girin.", "Hata", wx.ICON_ERROR)

# === Help Sekmesi ===
class Help(wx.Panel):
    def __init__(self, parent):
        super().__init__(parent)
        text = (
            "\U0001F4D8 FenrasTech Yer İstasyonu Yardım\n\n"
            "\U0001F539 Giriş: yazılımı başlatmak için geçerli kullanıcı adını girmeniz gerekmektedir.\n"
            "\U0001F539 Yer İstasyonu Ana ekranı: Sol panelde ufuk çizgisi ve uçuş verileri,\n"
            "    sağda harita bulunur. Veriler anlık olarak güncellenir.\n\n"
            "\U0001F539 Flight Plan: Haritada waypoint eklemek için lat/lon girin.\n"
            "    Noktalar arasında rota otomatik çizilir.\n\n"
            "\U0001F539 Help: Yazılımın açıklamasını ve kullanım yönergelerini içerir.\n\n"
            "\U0001F4E9 İletişim: destek@fenrastech.com\n"
        )
        box = wx.TextCtrl(self, value=text, style=wx.TE_MULTILINE | wx.TE_READONLY | wx.BORDER_NONE)
        box.SetFont(wx.Font(11, wx.DEFAULT, wx.NORMAL, wx.NORMAL))
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(box, 1, wx.EXPAND | wx.ALL, border=10)
        self.SetSizer(sizer)

# === Başlat ===
if __name__ == "__main__":
    app = wx.App()
    GirisEkrani()
    app.MainLoop()
