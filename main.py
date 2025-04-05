import serial
import serial.tools.list_ports
import wx
import threading

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
        exit_menu =  file_menu.Append(wx.ID_EXIT, "&Çıkış")                          ## "Çıkış" İsimli Seçeneğin Eklenmesi

        menu_serial = wx.Menu()                                                      ## "Dosya" İsimli Menünün Yanına UART Ayarları İçin Yeni Menü Eklenmesi
        com_menu    = wx.Menu()                                                      ## "com_menu" Adında Bir Alt Menü Oluşturulması (Com Port Seçmek İçin)
        uart_menu   = wx.Menu()                                                      ## "uart_menu" Adında Bir Alt Menü Oluşturulması (baudrate Seçmek İçin)

        self.baud_rates = {                                                          ## "baud_rates" İsimli Bir Sözlük (Dictionary) Oluşturulması
            "4800":   wx.NewIdRef(),                                                 ## Baud Rate Değerleri ve Yeni ID Değerlerini Tutuyor
            "9600":   wx.NewIdRef(),
            "14400":  wx.NewIdRef(),
            "19200":  wx.NewIdRef(),
            "38400":  wx.NewIdRef(),
            "57600":  wx.NewIdRef(),
            "115200": wx.NewIdRef()
        }
        
        for rate, rate_id in self.baud_rates.items():                                ## "rate" ve "rate_id" Değerlerini "baud_rates" Sözlüğünden Okuyan Döngü
            uart_menu.Append(rate_id, rate, "UART Baudrate Ayarla")                  ## Okunan "rate" Değerlerini "uart_menü" Alt Menüsüne Eklenmesi
            self.Bind(wx.EVT_MENU, self.uart_baud_select, id=rate_id)                ## Herbir Seçeneği "uart_baud_select" Fonksiyonuna Bağlanması

        ports = serial.tools.list_ports.comports()                                   ## Aktif Tüm COM Portların "ports" Değişkenine Aktarılması
        self.port_choices = [port.device for port in ports]                          ## Yalnızca Port İsimlerinin "port_choices" İçine Aktarılması

        self.com_ports = {}                                                          ## "com_ports" İsminde Boş Sözlük Oluşturulması
        for n in self.port_choices:                                                  ## Port İsimlerini Alt Menüye Eklemek İçin Döngü
            self.com_ports[n] = wx.NewIdRef()                                        ## Herbir Port İsmine Özel Yeni ID Atanması 
            com_menu.Append(self.com_ports[n], n, "COM Port Seç")                    ## Port İsimlerinin "com_menu" İsimli Alt Menüye Eklenmesi  
            self.Bind(wx.EVT_MENU, self.uart_com_select, id=self.com_ports[n])       ## Her Seçeneğin "uart_com_select" İsimli Fonksiyona Bağlanması

        menu_serial.AppendSubMenu(uart_menu, "&Baud Rate")                           ## "Baud Rate" İsimli Yeni Seçeneğin "Serial" Menüsü Altına Eklenmesi
        menu_serial.AppendSubMenu(com_menu,  "&COM Ports")                           ## "COM Ports" İsimli Yeni Seçeneğin "Serial" Menüsü Altına Eklenmesi

        menu_bar = wx.MenuBar()                                                      ## "menu_bar" İsimli Menü Satırının Oluşturulması
        menu_bar.Append(file_menu, "&Dosya")                                         ## Menü Satırına "Dosya" İsimli Başlığın Eklenmesi
        menu_bar.Append(menu_serial, "&Serial")                                      ## Menü Satırına "Serial" İsimli Başlığın Eklenmesi
        self.SetMenuBar(menu_bar)                                                    ## Menü Satırının Oluşturulması

        self.Bind(wx.EVT_MENU, self.on_exit, exit_menu)                              ## "Çıkış" İsimli Alt Menü Seçeneğinin Çıkış İşlemi İçin Olay Tanımlanması
        self.button.Bind(wx.EVT_BUTTON, self.on_button_click)                        ## Buton için Olay Tanımlanması

    def on_exit(self, event):                                                         ## "Çıkış" İsimli Seçeneğin Çağırdığı Fonksiyon 
        self.Close(True)                                                             ## Çıkış İşleminin Yapılması

    def on_button_click(self, event):                                                ## Butona Tıklanıldığında Çağrılan Fonksiyon 
        self.text.SetLabel("Sene 1340")                                              ## Metin Yazısının Güncellenmesi
        self.button.SetLabel("Buralar Orman")                                        ## Buton Üzerindeki Yazının Güncellenmesi
        self.button.SetSize(100,100)                                                 ## Butonun Ölçülerinin Değiştirilmesi
        self.Layout()                                                                ## Değişen Ölçülere Göre Tekrar Düzen Oluşturulması
    
    def uart_baud_select(self, event):
        uart_baud_id = event.GetId()
        for rate, rate_id in self.baud_rates.items():
            if uart_baud_id == rate_id:
                print(f"Seçilen baud rate: {rate} bps")
    
    def uart_com_select(self, event):
        uart_com_id = event.GetId()
        for com_port, com_id in self.com_ports.items():
            if uart_com_id == com_id:
                print(f"Seçilen com port: {com_port}")

class MyApp(wx.App):
    def OnInit(self):
        frame = FlyBoard()
        frame.Show()
        return True

if __name__ == "__main__":
    app = MyApp()
    app.MainLoop()
