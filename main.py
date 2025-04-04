import serial
import serial.tools.list_ports
import wx

ser = None  #Global tanımlanmalı

def serial_ports():
    ports = serial.tools.list_ports.comports()
    print(ports)
    seri_port = []
    for p in ports:
        print(p.device)
        seri_port.append(p.device)
    print(seri_port)
    return seri_port

def serial_baglan():
    com_deger = value[0]
    baud_deger = value[1]
    print("Baud Deger", value[1])
    global ser
    ser = serial.Serial(com_deger, baud_deger, timeout=0, parity=serial.PARITY_NONE, stopbits = serial.STOPBITS_ONE , bytesize = serial.EIGHTBITS, rtscts=0)

class FlyBoard(wx.Frame):                                                            ## FlyBoard Sınıfının wx.Frame Sınıfının Mirasçısı Olarak Tanımlanması
    def __init__(self):                                                              ## FlyBoard Sınıfının Constructor Tanımlaması
        wx.Frame.__init__(self,None, title="FlyBoard Gui v1.0", size=(1000, 350))    ## Başlık ve Pencere Büyüklüğü Ayarlanması
        panel = wx.Panel(self)                                                       ## "panel" Objesinin Tanımlanması
        vbox = wx.BoxSizer(wx.VERTICAL)                                              ## Box Sizer Ayarlanması
        
        self.text = wx.StaticText(panel, label="FlyBoard Gui Alpha")                 ## "panel" İçine "FlyBoard Gui Alpha" Yazdırılması
        vbox.Add(self.text, flag=wx.ALIGN_CENTER | wx.TOP, border=50)                ## Ekranın Ortasına ve 50 piksel uzağa yerleştirilmesi 
        
        self.button = wx.Button(panel, label="Tıkla")                                ## "panel" İçine "Tıkla" Yazan Buton oluşturulması
        vbox.Add(self.button, flag=wx.ALIGN_CENTER | wx.TOP, border=10)              ## Ekranın Ortasına ve 60 piksel uzağa yerleştirilmesi 

        panel.SetSizer(vbox)                                                         ## "panel" Boyutlandırıcısı Olarak "vbox" objesinin kullanılması
        self.Centre()                                                                ## Bütün Pencerenin Monitöre Ortalanması

        self.CreateStatusBar()                                                       ## Aşağıya Durum Çubuğu Konulması

        file_menu = wx.Menu()                                                        ## Programın Sol Üstündeki "Dosya" Menüsü Tanımlanması
        menu_about = file_menu.Append(wx.ID_ABOUT, "&Hakkında", "Fenrastech - FlyBoard Gui")    ## "Dosya" İsimli Menü İçine "Hakkında" Seçeneğinin Eklenmesi
        file_menu.AppendSeparator()                                                  ## Ayıraç Eklenmesi
        menu_exit =  file_menu.Append(wx.ID_EXIT, "&Çıkış")                          ## "Çıkış" İsimli Seçeneğin Eklenmesi

        self.baud_rates = {
            "4800":   wx.NewIdRef(),
            "9600":   wx.NewIdRef(),
            "14400":  wx.NewIdRef(),
            "19200":  wx.NewIdRef(),
            "38400":  wx.NewIdRef(),
            "57600":  wx.NewIdRef(),
            "115200": wx.NewIdRef()
        }

        menu_serial = wx.Menu()                                                      ## "Dosya" İsimli Menünün Yanına UART Ayarları İçin Yeni Menü Eklenmesi
        uart_menu   = wx.Menu()                                                      ## "uart_menu" Adında Bir Alt Menü Oluşturulması (baudrate seçmek için)

        menu_serial.AppendSubMenu(uart_menu, "&Baud Rate")                           ## "Baud Rate" İsimli Yeni Seçeneğin "Serial" Menüsü Altına Eklenmesi

        menu_bar = wx.MenuBar()                                                      ## "menu_bar" İsimli Menü Satırının Oluşturulması
        menu_bar.Append(file_menu, "&Dosya")                                         ## Menü Satırına "Dosya" İsimli Başlığın Eklenmesi
        menu_bar.Append(menu_serial, "&Serial")                                      ## Menü Satırına "Serial" İsimli Başlığın Eklenmesi
        self.SetMenuBar(menu_bar)                                                    ## Menü Satırının Oluşturulması

        self.Bind(wx.EVT_MENU, self.on_exit, menu_exit)                              ## "Çıkış" İsimli Alt Menü Seçeneğinin Çıkış İşlemi İçin Olay Tanımlanması
        self.button.Bind(wx.EVT_BUTTON, self.on_button_click)                        ## Buton için Olay Tanımlanması

        for rate, rate_id in self.baud_rates.items():
            uart_menu.Append(rate_id, rate, "Set UART Baudrate")
            self.Bind(wx.EVT_MENU, self.uart_baud_select, id=rate_id)

    def on_exit(self,e):                                                             ## "Çıkış" İsimli Seçeneğin Çağırdığı Fonksiyon 
        self.Close(True)                                                             ## Çıkış İşleminin Yapılması

    def on_button_click(self, event):                                                ## Butona Tıklanıldığında Çağrılan Fonksiyon 
        self.text.SetLabel("Sene 1340")                                              ## Metin Yazısının Güncellenmesi
        self.button.SetLabel("Buralar Orman")                                        ## Buton Üzerindeki Yazının Güncellenmesi
        self.button.SetSize(100,100)                                                 ## Butonun Ölçülerinin Değiştirilmesi
        self.Layout()                                                                ## Değişen Ölçülere Göre Tekrar Düzen Oluşturulması
    
    def uart_baud_select(self, event):
        uart_menu_id = event.GetId()
        for rate, rate_id in self.baud_rates.items():
            if uart_menu_id == rate_id:
                print(f"Seçilen baud rate: {rate} bps")

class MyApp(wx.App):
    def OnInit(self):
        frame = FlyBoard()
        frame.Show()
        return True

if __name__ == "__main__":
    app = MyApp()
    app.MainLoop()
