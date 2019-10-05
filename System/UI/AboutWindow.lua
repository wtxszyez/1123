_VERSION = [[Version 3.2 - October 5, 2019]]
--[[
==============================================================================
AboutWindow.lua - v3.2 2019-10-05
==============================================================================
Reactor is a package manager for Fusion and Resolve. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.

==============================================================================
Overview
==============================================================================
This script creates an "About Reactor" window using Fusion's UI Manager GUI building system.

It is called from the Config:/Reactor.fu file based "Reactor > About Reactor" menu item entry.

==============================================================================
Installation
==============================================================================
This script is deployed automatically by Reactor's installer and saved to:
Reactor:/System/UI/AboutWindow.lua

There is an associated ui:Icon resource named "reactorlarge.png" that is used in this GUI Window.

The icon is saved to:
Reactor:/System/Images/icons.zip/reactorlarge.png

==============================================================================
Usage
==============================================================================
Step 1. Install Reactor.

Step 2. Restart Fusion then open the "Reactor > Open Reactor..." menu item once.

Step 3. Run this script by selecting the "Reactor > About Reactor" menu item.
]]

-- Open a Webpage
-- Example: OpenURL("We Suck Less", "https://www.steakunderwater.com/")
function OpenURL(siteName, path)
	if platform == "Windows" then
		-- Running on Windows
		command = "explorer \"" .. path .. "\""
	elseif platform == "Mac" then
		-- Running on Mac
		command = "open \"" .. path .. "\" &"
	elseif platform == "Linux" then
		-- Running on Linux
		command = "xdg-open \"" .. path .. "\" &"
	else
		comp:Print("[Error] There is an invalid Fusion platform detected\n")
		return
	end

	os.execute(command)

	-- comp:Print("[Launch Command] " tostring(command) .. "\n")
	comp:Print("[Opening URL] " .. tostring(path) .. "\n")
end


-- Create the "About Reactor" UI Manager dialog
function AboutReactorWin()
	-- Configure the window Size
	local originX, originY, width, height = 200, 200, 546, 308

	-- Create the new UI Manager Window
	local win = disp:AddWindow({
		ID = "AboutReactorWin",
		TargetID = "AboutReactorWin",
		WindowTitle = "About Reactor",
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
			ID = "root",

			ui:HGroup{
				Weight = 0,
				ui:VGroup {
					Weight = 1,

					ui:Button{
						ID = 'ReactorIconButton',
						Weight = 0,
						IconSize = {68,68},
						Icon = ui:Icon{
							File = 'Reactor:/System/UI/Images/icons.zip/reactorlarge.png'
						},
						MinimumSize = {
							68,
							68,
						},
						Flat = true,
					},

					ui:Label {
						ID = "ReactorLabel",
						Weight = 0,

						Text = "Reactor",
						ReadOnly = true,
						Alignment = {
							AlignHCenter = true,
							AlignVCenter = true,
						},
						Font = ui:Font{
							PixelSize = 36,
						},
					},

					ui:Label {
						ID = "VersionLabel",
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
					ID = "AboutLabel",
					Text = [[Reactor is a package manager for Fusion and Resolve. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository. Now with 3x the magic!]],
					OpenExternalLinks = true,
					WordWrap = true,
					Alignment = {
						AlignHCenter = true,
						AlignVCenter = true,
					},
					Font = ui:Font{
						PixelSize = 14,
					},
				},

				ui:Button{
					ID = 'ReactorMagicButton',
					Weight = 0,
					IconSize = {112,29},
					Icon = ui:Icon{
						File = 'Reactor:/System/UI/Images/reactormagic.png'
					},
					MinimumSize = {
						112,
						29,
					},
					Flat = true,
				},

				ui:Label {
					ID = "URLLabel",
					Weight = 0,
					Text = [[Copyright © 2019 We Suck Less<br><a href="https://www.steakunderwater.com/wesuckless" style="color: rgb(139,155,216)">https://www.steakunderwater.com/wesuckless</a>]],
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
	function win.On.AboutReactorWin.Close(ev)
		disp:ExitLoop()
	end

	-- Open the We Suck Less webpage when the Reactor logo is clicked
	function win.On.ReactorIconButton.Clicked(ev)
		OpenURL("We Suck Less", "https://www.steakunderwater.com/wesuckless")
		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("AboutReactorWin", {
		Target {
			ID = "AboutReactorWin",
		},

		Hotkeys {
			Target = "AboutReactorWin",
			Defaults = true,

			CONTROL_W  = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
			CONTROL_F4 = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
		},
	})

	-- Init the window
	win:Show()
	disp:RunLoop()
	win:Hide()
	app:RemoveConfig('AboutReactorWin')
	collectgarbage()

	return win,win:GetItems()
end

-- The Main function
function Main()
	-- Find out the current Fusion host platform (Windows/Mac/Linux)
	platform = (FuPLATFORM_WINDOWS and "Windows") or (FuPLATFORM_MAC and "Mac") or (FuPLATFORM_LINUX and "Linux")

	-- Display the "About Reactor" dialog
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)
	AboutReactorWin()
end


Main()
print("[Done]")
