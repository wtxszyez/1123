ui = fu.UIManager
disp = bmd.UIDispatcher(ui)

dlg = disp.AddWindow({ "WindowTitle": "My First Window", "ID": "MyWin", "Geometry": [ 100, 100, 400, 200 ], },
	[
		ui.VGroup({ "Spacing": 0, },
		[
			# Add your GUI elements here:
			ui.Label({ "ID": "Label", "Text": "This is a Label", }),
		]),
	])

itm = dlg.GetItems()

# The window was closed
def _func(ev):
	disp.ExitLoop()
dlg.On.MyWin.Close = _func

# Add your GUI element based event functions here:

dlg.Show()
disp.RunLoop()
dlg.Hide()

