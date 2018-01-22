--[[--
UI Manager Error Window - v1.0 2018-01-07
by Andrew Hazelden <andrew@andrewhazelden.com>

A Fusion 9 Lua module that creates a UI Manager based error dialog that shows an error string.

## Installation ##

Step 1. Copy the "ErrorWin.lua" script to the Fusion user prefs "Modules:/Lua/" folder.

## Usage ##

You can test the error window out by adding the following code to your Lua script:

-- Load the Lua Module
require "ErrorWin"

-- Show the error window dialog
ErrorWin("Job Complete", "The render job finished successfully.")

## Notes ##

If you want to keep the dialog code in your script but have support for suppressing the dialog window from displaying in a batch script you can set the following variable to "true" somewhere in you code before the ErrorWin() function is run:

ERROR_WINDOW_CONSOLE_MODE = true

--]]--


-- Show an error message dialog
-- Example: ErrorWin("Job Complete", "The render job finished successfully.")
function ErrorWin(title, text)
	-- Check if the Fusion GUI is running
	if fusion == nil then 
		print("[Fusion Error] Please open up the Fusion GUI before running this tool.\n")
		return
	else
		-- Check what version of Fusion is active
		local fuVersion = math.floor(tonumber(eyeon._VERSION))
		if fuVersion < 9 then
			-- Fusion 7 or 8 was detected
			print("[UI Manager Error] Fusion 9.0.1 or higher is required. Detected Fusion " .. tostring(eyeon._VERSION) .. "\n")
			return
		else
			-- Fusion 9+ is running
			
			-- Print the error message to the Console tab
			if comp ~= nil then
				comp:Print("\n[" .. tostring(title) .. "] " .. tostring(text) .. "\n")
			end
			
			-- Check if the console mode variable is inactive
			if ERROR_WINDOW_CONSOLE_MODE ~= true then
				-- Check if UI Manager has been loaded
				if not ui then
					ui = app.UIManager
					disp = bmd.UIDispatcher(ui)
				end

				-- Create the window
				local win = disp:AddWindow({
					ID = "errWin",
					Target = "errWin",
					WindowTitle = tostring(title),
					Geometry = {450, 300, 500, 150},

					ui:VGroup{
						ui:Label{
							ID = "Title",
							Text = tostring(title),
							Alignment = {
								AlignHCenter = true,
								AlignVCenter = true,
							},
							Font = ui:Font{
								PixelSize = 18,
							},
						},

						ui:Label{
							ID = "Message",
							Text = tostring(text),
							Alignment = {
								AlignHCenter = true,
								AlignVCenter = true,
							},
							WordWrap = true,
						},

						ui:HGroup{
							Weight = 0,

							-- Add a horizontal spacer
							ui:HGap(0, 2.0),

							-- OK Button
							ui:Button{
								ID = "OkButton",
								Text = "Ok",
							},
						},
			
					}
				})

				-- Add your GUI element based event functions here:
				itm = win:GetItems()

				-- The window was closed
				function win.On.errWin.Close(ev)
					disp:ExitLoop()
				end

				-- The OK Button was clicked
				function win.On.OkButton.Clicked(ev)
					disp:ExitLoop()
				end

				-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
				app:AddConfig("errWin", {
					Target {
						ID = "errWin",
					},

					Hotkeys {
						Target = "errWin",
						Defaults = true,

						CONTROL_W = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
						CONTROL_F4 = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
					},
				})

				win:Show()
				disp:RunLoop()
				win:Hide()
			end
		end
	end
end
