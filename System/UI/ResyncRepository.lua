_VERSION = [[Version 3 - May 23, 2019]]
--[[
==============================================================================
Resync Repository.lua - v3 2019-05-23
==============================================================================
The "Resync Repository" script is used to reset the Reactor sync reference point. This action will redownload the main Reactor repository files. A resync operation may take up to 1 minute to complete.

==============================================================================
Overview
==============================================================================
This script creates a "Resync Repository" confirmation dialog. Then it will clear out the Reactor.cfg file's PrevCommitID entries.

It is called from the Config:/Reactor.fu file based "Reactor > Tools > Resync Repository" menu item entry.

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

Step 3. Run this script by selecting the "Reactor > Tools > Resync Repository" menu item.
]]

-- AskOK Confirmation Dialog
-- Example: ok = AskOK('The Window Title', 'Write your message here')
function AskOK(title, description)
	local ok = false
	ui = fu.UIManager
	disp = bmd.UIDispatcher(ui)

	------------------------------------------------------------------------
	-- Add the platform specific folder slash character
	osSeparator = package.config:sub(1,1)

	------------------------------------------------------------------------
	-- Find the Reactor icon images
	iconsDir = fusion:MapPath('Reactor:/System/UI/Images/') .. 'icons.zip' .. osSeparator
	large = 32
	iconsMedium = {large,large}

	------------------------------------------------------------------------
	-- Create the new window
	local okwin = disp:AddWindow({
		ID = 'okwin',
		TargetID = 'okwin',
		WindowTitle = title,
		Geometry = {200,100,380,165},
		MinimumSize = {380, 165},
		-- Spacing = 10,
		-- Margin = 20,

		ui:VGroup{
			ID = 'root',

			-- Atom Working Directory
			ui:HGroup{
				ui:TextEdit{
					ID = 'DescriptionLabel',
					Weight = 1,
					ReadOnly = true,
					Text = description,
				},
			},

			ui:VGap(5, 0),

			ui:HGroup{
				Weight = 0,
				ui:Button{
					ID = 'CancelButton',
					Text = 'Cancel',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},

				ui:HGap(150),

				ui:Button{
					ID = 'ContinueButton',
					Text = 'Continue',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'create.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
			},
		}
	})

	-- The window was closed
	function okwin.On.okwin.Close(ev)
		ok = false
		disp:ExitLoop()
	end

	function okwin.On.CancelButton.Clicked(ev)
		ok = false
		disp:ExitLoop()
	end

	function okwin.On.ContinueButton.Clicked(ev)
		ok = true
		disp:ExitLoop()
	end

	app:AddConfig('okwin', {
		Target{ID = 'okwin'},
		Hotkeys{
			Target = 'okwin',
			Defaults = true,

			CONTROL_W = 'Execute{cmd = [[ app.UIManager:QueueEvent(obj, "Close", {}) ]]}',
			CONTROL_F4 = 'Execute{cmd = [[ app.UIManager:QueueEvent(obj, "Close", {}) ]]}',
		},
	})

	okwin:Show()
	disp:RunLoop()
	okwin:Hide()
	app:RemoveConfig('okwin')

	-- Report the status
	-- print('[' .. tostring(title) .. '] ' .. tostring(ok))

	return ok, okwin,okwin:GetItems()
end

-- The Main function
function Main()
	-- Display the "Resync Reactor" confirmation dialog
	ok = AskOK('Resync Reactor', 'Would you like to reset the Reactor sync reference point? This action will redownload the main Reactor repository files.\n\n A resync operation may take up to 1 minute to complete.')
	if ok == true then
		print('[Resync Repository] Started')

		-- Opens the Reactor.cfg file and clears out the previous "PrevCommitID" entries.
		local separator = package.config:sub(1,1)
		-- Check for a pre-existing PathMap preference
		local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
		if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
			-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
			reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. separator .. "$", "")
		end

		local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
		local reactorCfgFile = app:MapPath(tostring(reactor_pathmap) .. 'Reactor/System/Reactor.cfg')
		local cfgTable = bmd.readfile(reactorCfgFile)
		if type(cfgTable) == 'table' then
			print('\n\n[Initial Reactor.cfg] ' .. reactorCfgFile)
			dump(cfgTable)

			-- Clear out the PrevCommitID strings
			print('\n\n[Reactor.cfg] Clearing PrevCommitID Entries')
			for k,v in pairs(cfgTable.Repos) do
				print('\t[' .. k .. '.PrevCommitID] ', cfgTable.Repos[k]['PrevCommitID'])
				cfgTable.Repos[k].PrevCommitID = nil
			end

			-- Write the edited table back to the Reactor.cfg file
			bmd.writefile(reactorCfgFile, cfgTable)
			cfgTable = bmd.readfile(reactorCfgFile)
			print('\n\n[Edited Reactor.cfg] ' .. reactorCfgFile)
			dump(cfgTable)
		end

		-- Display the Reactor Window to auto refresh the atom files
		local reactorScript = app:MapPath(tostring(reactor_pathmap) .. 'Reactor/System/') .. 'Reactor.lua'
		if bmd.fileexists(reactorScript) == false then
			print('\n\n[Reactor Error] Open the Reactor window once to download the missing file: ' .. reactorScript)
		else
			print('\n\n[Reactor] Opening Reactor Window')
			ldofile(reactorScript)
		end
	else
		print('[Resync Repository] You cancelled the dialog!')

		-- Exit the script
		return
	end
end


Main()
print('[Done]')
