
--[[--
Fusion Credits v1.0 - 2018-05-27
By Andrew Hazelden <andrew@andrewhazelden.com>

Overview:
This script shows a Fusion Credits dialog that gives thanks to the developers who created Eyeon / Blackmagic Fusion.
--]]--

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

-- Find out the current Fusion host platform (Windows/Mac/Linux)
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Create a "Credits Window" dialog
function CreditsWindow()
	local URL = 'http://www.blackmagicdesign.com/'
		
	local width,height = 400,250
	win = disp:AddWindow({
		ID = 'CreditsWin',
		TargetID = 'CreditsWin',
		WindowTitle = 'Fusion Credits',
		WindowFlags = {Window = true, WindowStaysOnTopHint = true,},
		Geometry = {200, 200, width, height},

		ui:VGroup{
			ID = 'root',
			
			-- Add your GUI elements here:
			ui:Button{
				Weight = 0.01,
				ID = 'FusionButton',
				IconSize = {64, 64},
				MinimumSize = {64, 64},
				Icon = ui:Icon{
					File = fusion:MapPath('Scripts:/Comp/Resolve Essentials/fusion-logo.png'),
				},
				
				Flat = true,
			},
			
			ui:TextEdit{
				Weight = 1,
				ID = 'FusionText',
				ReadOnly = true,
				Alignment = {AlignHCenter = true, AlignTop = true},
				HTML = [[<h1>Fusion for ]] .. platform .. [[</h1>
<p>The WSL community would like to thank the people we know were involved in the creation of Fusion:</p>
<p>Stuart MacKinnon, Peter Loveday, Daniel Koch, Stephen Horwat, Jith Kumar, Leo Wong, Anastasio Garcia, Peter Urbanec, Vesa Peltonen, Srecko Zrillic, Raf Schoenmaekers, Mike Gibson, Swati Tulsian, Colin Hui and Steve Roberts.</p>]],
			},
		},
	})

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The window was closed
	function win.On.CreditsWin.Close(ev)
		disp:ExitLoop()
	end
	
	-- The "Fusion" icon was clicked
	function win.On.FusionButton.Clicked(ev)
		-- Open a webpage URL in the default web browser
		if bmd.openurl then
			url = 'https://www.blackmagicdesign.com/'
			bmd.openurl(url)
			print('[Opening URL] ' .. url .. '\n')
		end
	end
	
	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("CreditsWin", {
		Target {
			ID = "CreditsWin",
		},

		Hotkeys {
			Target = "CreditsWin",
			Defaults = true,

			CONTROL_W	 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
			CONTROL_F4 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
		},
	})

	win:Show()
	disp:RunLoop()
	win:Hide()

	return win,win:GetItems()
end


CreditsWindow()
