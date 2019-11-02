local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,200

win = disp:AddWindow({
	ID = 'MyWin',
	WindowTitle = 'My First Window',
	Geometry = {100, 100, width, height},
	Spacing = 10,

	ui:VGroup{
		ID = 'root',
		Margin = 0,

		-- Add your GUI elements here:
		ui:CheckBox{
			ID = 'MyCheckbox',
			Text = 'The Checkbox Label',
		},
	},
})

-- The window was closed
function win.On.MyWin.Close(ev)
	disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

function win.On.MyCheckbox.Clicked(ev)
	print('[Checkbox] ' .. tostring(itm.MyCheckbox.Checked))
end

win:Show()
disp:RunLoop()
win:Hide()
