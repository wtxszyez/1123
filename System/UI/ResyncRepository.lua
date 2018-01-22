_VERSION = [[Version 1.0 - December 22, 2018]]
--[[
==============================================================================
Resync Repository.lua - v1.0 2018-01-22 
==============================================================================
The "Resync Repository" script is used to reset the Reactor sync reference point. This action will redownload the main Reactor repository files.\n\n A resync operation may take up to 1 minute to complete.

==============================================================================
Overview
==============================================================================
This script creates a "Resync Repository" AskUser confirmation dialog.	Then it will clear out the Reactor.cfg file's PrevCommitID entries.

It is called from the Config:/Reactor.fu file based "Reactor > Advanced > Resync Repository" menu item entry.

==============================================================================
Installation
==============================================================================
This script is deployed automatically by Reactor's installer and saved to:
Reactor:/System/UI/Resync Repository.lua

==============================================================================
Usage
==============================================================================
Step 1. Install Reactor. 

Step 2. Restart Fusion then open the "Reactor > Open Reactor..." menu item once.

Step 3. Run this script by selecting the "Reactor > Advanced > Resync Repository" menu item.
]]


-- The Main function
function Main()
	-- Display the "Resync Reactor" confirmation dialog
	msg = "Would you like to reset the Reactor sync reference point? This action will redownload the main Reactor repository files.\n\n A resync operation may take up to 1 minute to complete."

	dlgTable = { 
		{"Msg", Name = "Warning", "Text", ReadOnly = true, Lines = 6, Wrap = true, Default = msg},
	}

	dialog = comp:AskUser("Resync Reactor", dlgTable)
	if dialog == nil then
		print("[Resync Repository] You cancelled the dialog!")
		-- Exit the script
		return
	else
		print("[Resync Repository] Started")
		-- Opens the Reactor.cfg file and clears out the previous "PrevCommitID" entries.
		local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
		local reactorCfGFile = app:MapPath(tostring(reactor_pathmap) .. "Reactor/System/Reactor.cfg")
		local cfgTable = bmd.readfile(reactorCfGFile)
		if type(cfgTable) == "table" then
			-- print("\n\n[Initial Reactor.cfg] " .. reactorCfGFile)
			-- dump(cfgTable)

			-- Clear out the PrevCommitID strings
			print("\n\n[Reactor.cfg] Clearing PrevCommitID Entries")
			for k,v in pairs(cfgTable.Settings) do
				-- print("\t[" .. k .. ".PrevCommitID] ",	 cfgTable.Settings[k]["PrevCommitID"])
				cfgTable.Settings[k].PrevCommitID = nil
			end

			-- Write the edited table back to the Reactor.cfg file
			bmd.writefile(reactorCfGFile, cfgTable)
			cfgTable = bmd.readfile(reactorCfGFile)
			-- print("\n\n[Edited Reactor.cfg] " .. reactorCfGFile)
			-- dump(cfgTable)
		end

		-- Display the Reactor Window to auto refresh the atom files
		local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
		local reactorScript = app:MapPath(tostring(reactor_pathmap) .. "Reactor/System/") .. "Reactor.lua"
		if bmd.fileexists(reactorScript) == false then
			print("\n\n[Reactor Error] Open the Reactor window once to download the missing file: " .. reactorScript)
		else
			print("\n\n[Reactor] Opening Reactor Window")
			ldofile(reactorScript)
		end
	end
end


Main()
print("[Done]")
