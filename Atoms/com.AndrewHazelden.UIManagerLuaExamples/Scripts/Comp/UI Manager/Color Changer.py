ui = fu.UIManager
disp = bmd.UIDispatcher(ui)

dlg = disp.AddWindow({ "WindowTitle": "Tool Color Changer", "ID": "ToolColor", "Geometry": [ 100, 100, 480, 150 ], },
	[
		ui.VGroup({ "Spacing": 0, },
		[
			# Add your GUI elements here:
			ui.HGroup({ "Spacing": 20, "Weight": 0.0, },
			[
				ui.ColorPicker({ "ID": "BackColor", "Text": "Background Color" }),
				ui.ColorPicker({ "ID": "TextColor", "Text": "Text Color" }),
			]),
			ui.VGap(),
			ui.HGroup({ "Weight": 0.0, },
			[
				ui.Button({ "Text": "Reset", "ID": "Reset" }),
				ui.Button({ "Text": "Copy Active", "ID": "Copy" }),
			]),
		]),
	])

itm = dlg.GetItems()

toollist = comp.GetToolList(True)

back = None
text = None

def SetToolColors(bg, txt):
	for i, tool in toollist.items():
		if bg:
			tool.TileColor = bg
		
		if txt:
			tool.TextColor = txt

# The window was closed

def _func(ev):
	disp.ExitLoop()
dlg.On.ToolColor.Close = _func

# Add your GUI element based event functions here:

def _func(ev):
	for i, tool in toollist.items():
		tool.TileColor = None
		tool.TextColor = None
dlg.On.Reset.Clicked = _func

def _func(ev):
	if comp.ActiveTool:
		back = comp.ActiveTool.TileColor
		text = comp.ActiveTool.TextColor
		
		back['A'] = 1
		text['A'] = 1
dlg.On.Reset.Clicked = _func

def _func(ev):
		itm['TileColor'].Color = back
		itm['TextColor'].Color = text
dlg.On.Copy.Clicked = _func

def _func(ev):
	SetToolColors(None, ev['Color'])
dlg.On.TextColor.ColorChanged = _func

def _func(ev):
	SetToolColors(ev['Color'], None)
dlg.On.BackColor.ColorChanged = _func


dlg.Show()
disp.RunLoop()
dlg.Hide()
