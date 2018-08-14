local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 600,800

win = disp:AddWindow({
	ID = 'MyWin',
	WindowTitle = 'My First Window',
	Geometry = {100, 100, width, height},
	Spacing = 10,
	
	ui:VGroup{
		ID = 'root',
		Margin = 50,
		
		-- Add your GUI elements here:
		ui:TextEdit{
			ID='MyTxt', 
			Text = 'Hello', 
			PlaceholderText = 'Please Enter a few words.',
			Lexer = 'fusion',
		},
	},
})

-- The window was closed
function win.On.MyWin.Close(ev)
		disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

function win.On.MyTxt.TextChanged(ev)
	print(itm.MyTxt.PlainText)
end

win:Show()
disp:RunLoop()
win:Hide()
