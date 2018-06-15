--[[--
Copy to Codebox - v1.7 June 13, 2018
by Pieter Van Houte and Andrew Hazelden
 
A quick code snippet that copies the flow view selection and formats it for easy inclusion on the WSL forum. This script also creates the codebox filename based on the OS' date and time.
 
Change log:
v1.7    - Adjusted the codebox filename to add a more accurate timestamp with seconds: WSLsnippet-YYYY-MM-DD--HH.MM.SS.setting
v1.6    - Used an alternative approach to solve the missing closing bracket issue
v1.5    - Added workaround for bmd.getclipboard() apparently losing the last line containing the closing bracket on MacOS
v1.4    - Added tiny wait after comp:Copy(tools) to avoid occasional hiccups
v1.3    - Removed print string duplication (thanks once more Andrew!)
v1.2    - Splitting into functions, more error handling and now capable of itself being posted inside of WSL Codebox tags :) (thanks again AndrewHazelden)
v1.1    - Fixed comp:GetToolList(true) and some initial error handling (thanks AndrewHazelden)
v1.0    - Initial release
--]]--
 
-- Display a UI Manager 3 second popup for notifications
function CodeboxDialog(title, msg)
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 450,50
   
	win = disp:AddWindow({
		ID = "codeboxWin",
		WindowTitle = title,
		Geometry = {100, 100, width, height},
		Spacing = 10,
 
		ui:HGroup{
			ID = "root",
			ui:Label{
				ID = "AboutText",
				Text = msg,
				ReadOnly = true,
				Alignment = {
					AlignHCenter = true,
					AlignTop = true
				},
			},
		},
	})
   
	print("\n" .. tostring(title) .. '\n' .. tostring(msg) .. "\n")
   
	-- The window was closed
	function win.On.MyWin.Close(ev)
			disp:ExitLoop()
	end
   
	win:Show()
	bmd.wait(3)
	win:Hide()
end
 
-- The main function
function Main()
	-- local opentag = "[" .. "Codebox=lua file=WSLsnippet-" .. os.date("%Y%b%d") .. "-" .. os.date("%H%M") .. ".setting" .. "]"
	local opentag = "[" .. "Codebox=lua file=WSLsnippet-" .. os.date('%Y-%m-%d--%H.%M.%S') .. ".setting" .. "]"
	local closetag = "[" .. "/Codebox" .. "]"
   
	-- Get the current foreground composite
	cmp = fusion.CurrentComp
   
	-- Copy the selected nodes from the flow area and then turn that Lua table into a string
	local nodes = bmd.writestring(cmp:CopySettings())
   
	-- Count how many nodes are selected
	-- (The # character put before a Lua table name will returns the number of items present in the table)
	local selected = #cmp:GetToolList(true)
   
	-- Check if any nodes were selected, and the CopySettings() command succeeded
	if (selected > 0) and nodes then
		local snip = opentag .. tostring(nodes) .. closetag
 
		print("\n--------start of snippet--------\n")
		print(snip)
		print("\n--------end of snippet-------\n")
 
		-- Copy the codebox string to your clipboard buffer
		bmd.setclipboard(snip)
	   
		-- Show a success status message
		CodeboxDialog("[Copied Codebox Snippet]", "Codebox Snippet copied to clipboard for use on We Suck Less")
	else
		-- No nodes were selected in the flow, or the copied nodes string is nil
		CodeboxDialog("[Script Error]", "Please select nodes in the Fusion Flow area and then run this script again.")
	end
end
 
 
Main()
print("[Done]")