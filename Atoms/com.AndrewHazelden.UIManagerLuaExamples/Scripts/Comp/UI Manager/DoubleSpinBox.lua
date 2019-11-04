local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,75

win = disp:AddWindow({
	ID = 'MyWin',
	WindowTitle = 'My First Window',
	Geometry = {100, 100, width, height},
	Spacing = 10,
	
	ui:VGroup{
		ID = 'root',

		-- Add your GUI elements here:
		ui:DoubleSpinBox{
			ID='MySpinner',
		},
	},
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.MyWin.Close(ev)
	disp:ExitLoop()
end

function win.On.MySpinner.ValueChanged(ev)
	print('[DoubleSpinBox Value] '.. itm.MySpinner.Value)
end

win:Show()
disp:RunLoop()
win:Hide()
