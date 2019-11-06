_VERSION = 'v4.2 - 2019-11-05'
--[[
==============================================================================
About KartaVR.lua
==============================================================================
"Karta" is the Swedish word for map. With KartaVR you can easily stitch, composite, retouch, and remap any kind of panoramic video: from any projection to any projection.

The KartaVR plug-in works inside of Blackmagic Design's powerful node based Fusion Standalone 9 and Resolve 15.2 software. It provides the essential tools for VR, panoramic 360° video stitching, and image editing workflows.

==============================================================================
Overview
==============================================================================
This script creates an "About KartaVR" window using Fusion's UI Manager GUI building system. 

It is called from the Config:/KartaVR.fu file based "KartaVR > About KartaVR" menu item entry.

==============================================================================
Installation
==============================================================================
Copy the "About KartaVR.lua" script into your Fusion user preferences "Scripts/Comp/KartaVR/" folder.

==============================================================================
Usage
==============================================================================
Step 1. In Fusion you can run the script by selecting the "Script > KartaVR > About KartaVR" menu item.

Step 2. A new "About KartaVR" window will appear. You can click on webpage and email links in this window and the external URLs will be loaded in your default webbrowser / email programs.
]]


-- Open a Webpage
-- Example: OpenURL('We Suck Less', 'https://www.steakunderwater.com/')
function OpenURL(siteName, path)
	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. path .. '"'
	elseif platform == "Mac" then
		-- Running on Mac
		command = 'open "' .. path .. '" &'
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'xdg-open "' .. path .. '" &'
	else
		comp:Print('[Error] There is an invalid Fusion platform detected\n')
		return
	end

	os.execute(command)
	-- comp:Print('[Launch Command] ' tostring(command) .. '\n')
	comp:Print('[Opening URL] [' .. tostring(siteName) .. '] ' .. tostring(path) .. '\n')
end


-- Create the "About KartaVR" UI Manager dialog
function AboutKartaVRWin()
	-- Configure the window Size
	local originX, originY, width, height = 200, 200, 775, 455

	-- Create the new UI Manager Window
	local win = disp:AddWindow({
		ID = 'AboutKartaVRWin',
		TargetID = 'AboutKartaVRWin',
		WindowTitle = 'About KartaVR ' .. tostring(_VERSION),
		WindowFlags = {
			Window = true,
			WindowStaysOnTopHint = true,
		},
		Geometry = {
			originX,
			originY,
			width,
			height,
		},
		ui:VGroup {
			ID = 'root',
			ui:HGroup{
				Weight = 0,
				ui:VGroup {
					Weight = 1,
					ui:Button{
						ID = 'KartaVRIconButton',
						Weight = 0,
						IconSize = {550,257},
						Icon = ui:Icon{
							File = 'Scripts:/Comp/KartaVR/KartaVR_Logo.png'
						},
						MinimumSize = {
							550,
							257,
						},
						Flat = true,
					},
					ui:Label {
						ID = 'VersionLabel',
						Weight = 1,
						Text = _VERSION,
						WordWrap = true,
						Alignment = {
							AlignHCenter = true,
							AlignVCenter = true,
						},
						Font = ui:Font{
							PixelSize = 12,
						},
					},
				},
			},
			ui:VGroup{
				ui:Label {
					ID = 'AboutLabel',
					Text = [["Karta" is the Swedish word for map. With KartaVR you can easily stitch, composite, retouch, and remap any kind of panoramic video: from any projection to any projection.

The KartaVR plug-in works inside of Blackmagic Design's powerful node based Fusion Standalone v9/16 and Resolve v15.2/16 software. It provides the essential tools for VR, panoramic 360° video stitching, and image editing workflows.]],
					OpenExternalLinks = true,
					WordWrap = true,
					Alignment = {
						-- AlignHCenter = true,
						AlignVCenter = true,
					},
					Font = ui:Font{
						PixelSize = 14,
					},
				},
				ui:Label {
					ID = 'URLLabel',
					Weight = 0,
					Text = [[Copyright © 2014-2019 Andrew Hazelden.<br><a href="http://www.andrewhazelden.com/blog/"  style="color: rgb(139,155,216)">http://www.andrewhazelden.com/blog/</a>]],
					OpenExternalLinks = true,
					WordWrap = true,
					Alignment = {
						AlignHCenter = true,
					},
					Font = ui:Font{
						PixelSize = 12,
					},
				},
			},
		},
	})

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The window was closed
	function win.On.AboutKartaVRWin.Close(ev)
		disp:ExitLoop()
	end

	-- Open the We Suck Less webpage when the KartaVR logo is clicked
	function win.On.KartaVRIconButton.Clicked(ev)
		OpenURL('Andrew Hazelden Blog', 'http://www.andrewhazelden.com/blog/')
		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('AboutKartaVRWin', {
		Target {
			ID = 'AboutKartaVRWin',
		},
		Hotkeys {
			Target = 'AboutKartaVRWin',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[ app.UIManager:QueueEvent(obj, "Close", {}) ]] }',
			CONTROL_F4 = 'Execute{ cmd = [[ app.UIManager:QueueEvent(obj, "Close", {}) ]] }',
		},
	})

	-- Init the window
	win:Show()
	disp:RunLoop()
	win:Hide()
	return win,win:GetItems()
end


-- The Main function
function Main()
	-- Find out the current Fusion host platform (Windows/Mac/Linux)
	platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

	-- Display the "About KartaVR" dialog
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)
	AboutKartaVRWin()
	print('[Done]')
end


Main()
