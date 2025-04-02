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
        self.CreateStatusBar()                                                       ## Aşağıya Durum Çubuğu Konulması

        file_menu = wx.Menu()                                                        ## Programın Sol Üstündeki "Dosya" Menüsü Tanımlanması
        menu_about = file_menu.Append(wx.ID_ABOUT, "&Hakkında", "Fenrastech - FlyBoard Gui")    ## "Dosya" İsimli Menü İçine "Hakkında" Seçeneğinin Eklenmesi
        file_menu.AppendSeparator()                                                  ## Ayıraç Eklenmesi
        menu_exit =  file_menu.Append(wx.ID_EXIT, "&Çıkış", "")                      ## "Çıkış" İsimli Seçeneğin Eklenmesi

        uart_menu = wx.Menu()                                                        ## "Dosya" İsimli Menünün Yanına Uart İçin Yeni Menü Eklenmesi
        uart_menu.Append(wx.ID_ANY, "&Baud Rate", "")                                ## "Baud Rate" İsimli Yeni Seçeneğin Eklenmesi

        menu_bar = wx.MenuBar()                                                      ## "menu_bar" İsimli Menü Satırının Oluşturulması
        menu_bar.Append(file_menu, "&Dosya")                                         ## Menü Satırına "Dosya" İsimli Başlığın Eklenmesi
        menu_bar.Append(uart_menu, "&Serial")                                        ## Menü Satırına "Serial" İsimli Başlığın Eklenmesi
        self.SetMenuBar(menu_bar)                                                    ## Menü Satırının Oluşturulması

        self.Bind(wx.EVT_MENU, self.On_Exit, menu_exit)                              ## "Çıkış" İsimli Alt Menü Seçeneğinin Çıkış İşlemi İçin Olay Tanımlanması

        self.text = wx.StaticText(panel, label="FlyBoard Gui Alpha")
        vbox.Add(self.text, flag=wx.ALIGN_CENTER | wx.TOP, border=50)
        
        self.button = wx.Button(panel, label="Tıkla")
        vbox.Add(self.button, flag=wx.ALIGN_CENTER | wx.TOP, border=10)
        
        self.button.Bind(wx.EVT_BUTTON, self.on_button_click)
        
        panel.SetSizer(vbox)
        self.Centre()
    
    def On_Exit(self,e):                                                             ## "Çıkış" İsimli Seçeneğin Çağırdığı Fonksiyon 
        self.Close(True)                                                             ## Çıkış İşleminin Yapılması

    def on_button_click(self, event):
        self.text.SetLabel("anaskm")
        self.button.SetLabel("fetiyi sikm31")
        self.button.SetSize(100,100)
        self.Layout()   

class MyApp(wx.App):
    def OnInit(self):
        frame = FlyBoard()
        frame.Show()
        return True

if __name__ == "__main__":
    app = MyApp()
    app.MainLoop()
