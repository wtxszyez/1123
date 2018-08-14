ui = fu.UIManager
disp = bmd.UIDispatcher(ui)

dlg = disp.AddWindow({ "WindowTitle": "My First Window", "ID": "MyWin", "Geometry": [ 100, 100, 400, 200 ], },
	[
		ui.VGroup({ "Spacing": 0, },
		[
			# Add your GUI elements here:
			ui.Slider({ "ID": "MySlider", }),
			ui.Label({ "ID": "MyLabel", "Text": "Value:", }),
		]),
	])

itm = dlg.GetItems()

# The window was closed
def _func(ev):
	disp.ExitLoop()
dlg.On.MyWin.Close = _func

# Add your GUI element based event functions here:

itm['MySlider'].Value = 25
itm['MySlider'].Minimum = 0
itm['MySlider'].Maximum = 100

def _func(ev):
	itm['MyLabel'].Text = "Slider Value: " + str(ev['Value'])
dlg.On.MySlider.ValueChanged = _func


dlg.Show()
disp.RunLoop()
dlg.Hide()

