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

class FlyBoard(wx.Frame):
    def __init__(self):
        super().__init__(None, title="FlyBoard Gui v1.0", size=(1000, 250))
        panel = wx.Panel(self)
        vbox = wx.BoxSizer(wx.VERTICAL)
        
        self.text = wx.StaticText(panel, label="FlyBoard Gui Alpha")
        vbox.Add(self.text, flag=wx.ALIGN_CENTER | wx.TOP, border=50)
        
        self.button = wx.Button(panel, label="Tıkla")
        vbox.Add(self.button, flag=wx.ALIGN_CENTER | wx.TOP, border=10)
        
        self.button.Bind(wx.EVT_BUTTON, self.on_button_click)
        
        panel.SetSizer(vbox)
        self.Centre()
    
    def on_button_click(self, event):
        self.text.SetLabel("anaskm")
        self.button.SetLabel("fetiyi sikm31")
        self.button.SetSize(200,100)
        self.Layout()

class MyApp(wx.App):
    def OnInit(self):
        frame = FlyBoard()
        frame.Show()
        return True

if __name__ == "__main__":
    app = MyApp()
    app.MainLoop()
