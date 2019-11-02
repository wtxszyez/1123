--[[--
Ping Tester v2 2019-11-02 
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

Overview:
This script is a simple Fusion lua based ping utility that runs the "ping" terminal program from the lua io.popen() command.

This script is intended primarily as a UI Manager GUI example that shows how to make a new window, add a text field for user input, and then display output in another text field.

Installation:
Copy this script to your Fusion user preferences "Scripts/Comp/" folder.

--]]--

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

win = disp:AddWindow({
	ID = 'PingTester',
	TargetID = 'PingTester',
	WindowTitle = 'Ping Tester',
	Geometry = {100,100,400,300},
	Composition = comp,

	ui:VGroup{
		ID = 'root',

		-- Add your GUI elements here:
		ui:HGroup{
			Weight = 0,

			ui:Button{
				ID = 'Ping',
				Text = 'Ping'
			},
			ui:HGap(5),
			ui:LineEdit{
				ID = 'HostName',
				PlaceholderText = 'Enter a Hostname or IP Address',
				Text = 'localhost',
				Weight = 1.5,
				MinimumSize = {250, 24},
			},
			ui:HGap(0, 2),
		},

		ui:HGroup{
			Weight = 1,
			ui:TextEdit{
				ID='Result',
				Text = '',
			},
		},
	},
})

-- The window was closed
function win.On.PingTester.Close(ev)
	disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

function win.On.Ping.Clicked(ev)
	ping(tostring(itm.HostName.Text))
end

function win.On.OK.Clicked(ev)
	disp:ExitLoop()
end


-- Ping a server address
-- Example: ping('localhost')
function ping(ipaddress)
	if ipaddress ~= nil then
		local handler = io.popen('ping -c 3 -i 0.5 ' .. ipaddress)
		local response = handler:read('*a')
		itm.Result.PlainText = tostring(response)
		-- print(response)
		print(itm.Result.PlainText)
	else
		print('Warning: The Hostname text is a nil value.')
	end
end

-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
app:AddConfig('PingTester', {
	Target {
		ID = 'PingTester',
	},

	Hotkeys {
		Target = 'PingTester',
		Defaults = true,

		CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
	},
})

win:Show()
disp:RunLoop()
win:Hide()

app:RemoveConfig('PingTester')
collectgarbage()
