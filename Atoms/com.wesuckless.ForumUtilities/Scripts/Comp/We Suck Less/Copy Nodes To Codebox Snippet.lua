--[[--
Copy to Codebox - v1.4 Feb 8, 2018
by Pieter Van Houte

A quick code snippet that copies the flow view selection and formats it for easy inclusion on the WSL forum. This script also creates the codebox filename based on the OS' date and time.

Change log:
v1.4	- added tiny wait after comp:Copy(tools) to avoid occasional hiccups 
v1.3	- removed print string duplication (thanks once more Andrew!)
v1.2	- splitting into functions, more error handling and now capable of itself being posted inside of WSL Codebox tags :) (thanks again AndrewHazelden)
v1.1	- fixed comp:GetToolList(true) and some initial error handling (thanks AndrewHazelden)
v1.0	- initial release
--]]--

-- Display a UI Manager 3 second popup for notifications
function CodeboxDialog(title, msg)
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 400,50

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

	print("\n" .. title .. '\n' .. msg .. "\n")

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
	local opentag = "[" .. "Codebox=lua file=WSLsnippet-" .. os.date("%Y%b%d") .. "-" .. os.date("%H%M") .. ".setting" .. "]"
	local closetag = "[" .. "/Codebox" .. "]"

	-- Get the nodes in the comp
	local tools = fusion.CurrentComp:GetToolList(true)

	-- Check if any nodes were selected
	if #tools >= 1 then
		-- Copy the selected nodes from the flow area
		local err = comp:Copy(tools)
		bmd.wait(0.01)
		local nodes = bmd:getclipboard()
	
		-- Check if the copy command succeeded
		if err == true and nodes ~= nil then
			local snip = opentag .. tostring(nodes) .. closetag

			print("\n--------start of snippet--------\n")
			print(snip)
			print("\n--------end of snippet-------\n")

			-- Copy the codebox string to your clipboard buffer
			bmd.setclipboard(snip)

			CodeboxDialog("[Copied Codebox Snippet]", "Codebox Snippet copied to clipboard for use on We Suck Less")
		else
			CodeboxDialog("[Script Error]", "There was a problem copying the nodes.")
		end
	else
		CodeboxDialog("[Script Error]", "Please select nodes in the Fusion Flow area.")
	end
end


Main()
print("[Done]")