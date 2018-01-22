-- Tool Color - v1.0 2017-09-18

-- Overview:
-- The Tool Color script allows you to customize the Tile Color and Text Color settings for nodes. 
-- As long as the Tool Color window is visible all new nodes added to the composite will inherit these color settings.

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 450,150
win = disp:AddWindow({
	ID = 'ColorWin',
	WindowTitle = 'Tool Color',
	WindowFlags = {Window = true, WindowStaysOnTopHint = true},
	Geometry = {200, 200, width, height},

	ui:VGroup{		
		ID = 'root',
		-- Add your GUI elements here:
		
		-- Use a horizontal layout for the two color pickers
		ui:HGroup{
		
		-- Tile Color Controls
		ui:HGroup{
			Weight = 0,
			ui:Label{ID = 'TileLabel', Text = 'Tile Color', Alignment = {AlignHCenter = true, AlignTop = true}},
		},
		ui:ColorPicker{ID = 'TileCol', Color = {R = 0.314, G = 0.314, B = 0.314, A = 1}},
		
		-- Text Color Controls
		ui:HGroup{
			Weight = 0,
			ui:Label{ID = 'TextLabel', Text = 'Text Color', Alignment = {AlignHCenter = true, AlignTop = true}},
		},
		ui:ColorPicker{ID = "TextCol", Color = {R = 0.753, G = 0.753, B = 0.753, A = 1}},
		
		},
	}
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.ColorWin.Close(ev)
	disp:ExitLoop()
end

-- While the "Tool Color" window is visible ui:AddNotify() will track each time a new node is added to the current comp
notify = ui:AddNotify('AddTool', comp)

-- As new tools are added to the comp the node's Tile Color and Text Color will be updated automatically
function disp.On.AddTool(ev)
	ev.Rets.tool.TileColor = itm.TileCol.Color
	ev.Rets.tool.TextColor = itm.TextCol.Color
end

win:Show()
disp:RunLoop()
win:Hide()
