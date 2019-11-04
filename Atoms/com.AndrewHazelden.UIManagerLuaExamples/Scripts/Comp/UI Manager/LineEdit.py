ui = fu.UIManager
disp = bmd.UIDispatcher(ui)

dlg = disp.AddWindow({ "WindowTitle": "My First Window", "ID": "MyWin", "Geometry": [ 100, 100, 400, 125 ], },
	[
		ui.VGroup({ "Spacing": 10, },
		[
			# Add your GUI elements here:
			ui.LineEdit({ "ID": "MyLineTxt", "Text": "Hello Fusioneers!", "PlaceholderText": "Please Enter a few words.", "Weight": 0.5}),
			ui.Button({ "ID": "PrintButton", "Text": "Print Text", "Weight": 0.5 }),
		]),
	])

itm = dlg.GetItems()

# The window was closed
def _func(ev):
	disp.ExitLoop()
dlg.On.MyWin.Close = _func

# Add your GUI element based event functions here:

def _func(ev):
	print(itm['MyLineTxt'].Text)
dlg.On.PrintButton.Clicked = _func

def _func(ev):
	print(itm['MyLineTxt'].Text)
dlg.On.MyLineTxt.TextChanged = _func

dlg.Show()
disp.RunLoop()
dlg.Hide()

