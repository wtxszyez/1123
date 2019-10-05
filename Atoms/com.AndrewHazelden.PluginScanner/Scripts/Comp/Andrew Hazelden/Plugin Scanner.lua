_VERSION = 'v3.14 2019-10-05'
--[[--
Plugin Scanner
By Andrew Hazelden

## Overview ##

The Plugin Scanner script creates a UI Manager tree view filled with the filename and filepath details for the Fusion .plugin files installed in your Fusion "Plugins:" PathMap folders.

The [x] Expand PathMaps checkbox at the top of the window allows you to see the filepath as a full absolute path, or as a relative PathMap location shortened down to a compact form. This is useful if you want to see in a quick glance if the plugin is coming from a certain "Plugins:" location.

The [x] Show Duplicate Plugin IDs checkbox at the top of the window filters the tree view contents so you only see plugins that have matching (duplicate) names. This makes it easy to see when you have multiple identical plugins installed regardless of what folder they are stored in on disk.

Single click on a row to copy the filepath to your clipboard. Double click on a row to open the containing folder. Scroll the Tree view horizontally to the right to see the extra columns.

## Installation ##

This script was created for use with the WSL Reactor package manager. You will find "Plugin Scanner" in Reactor's "Scripts/Reactor" Category.

The "Plugin Scanner.lua" script requires Fusion 9.0.1+.
--]]--

print('\n')
print('---------------------------------------------')
print('Plugin Scanner - ' .. tostring(_VERSION))
print('By Andrew Hazelden <andrew@andrewhazelden.com')
print('---------------------------------------------')
print('\n')

------------------------------------------------------------------------
-- Check what platform this script is running on
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Should a debugging mode be active that prints out details in the Console tab?
debugPrint = false

dprint = (debugPrint ~= true) and function() end or
-- function(fmt, ...)
--   print(fmt:format(...))
function(...)
  print(...)
end

ddump = (debugPrint ~= true) and function() end or
function(val)
  dump(val)
end

dopenfileexternal = (debugPrint ~= true) and function() end or
function(...)
  bmd.openfileexternal(...)
end

------------------------------------------------------------------------
-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(Dirname("/Users/Shared/file.txt"))
function Dirname(mediaDirName)
-- LUA Dirname command inspired by Stackoverflow code example:
-- http://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
  return mediaDirName:match('(.*' .. osSeparator .. ')')
end

-- The main function for Plugin Scanner
function Main()
	------------------------------------------------------------------------
	-- Create a table with the results
	searchResults = {
		filepath = {},
		filename = {},
		duplicate = {},
	}

	-- ------------------------------------------------------
	-- Scan the Plugins: multipath locations for all .plugin files
	mp = MultiPath('Plugins:')
	mp:Map(comp:GetCompPathMap())
	files = mp:ReadDir("*.plugin", true, true) -- (string pattern, boolean recursive, boolean flat)
	-- dump(files)

	c = 1
	-- Add the Plugins: PathMap files to the searchResults table
	for i,val in ipairs(files) do
		if val.IsDir == false then
			-- The fulle absolute filepath
			searchResults.filepath[c] = val.FullPath

			-- The base filename
			searchResults.filename[c] = val.Name
			c = c + 1
		end
	end
	-- dump(searchResults)

	-- ------------------------------------------------------
	-- Create the GUI
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 1024,500

	win = disp:AddWindow({
		ID = 'PluginScannerWin',
		TargetID = 'PluginScannerWin',
		WindowTitle = 'Plugin Scanner',
		WindowFlags = {
			Window = true,
			WindowStaysOnTopHint = false,
		},
		Geometry = {0, 0, width, height},
		Spacing = 0,

		ui:VGroup{
			ID = 'root',

			-- Tree View Controls
			ui:HGroup{
				Weight = 0,

				-- Add some space
				ui:HGap(),

				ui:Label{
					Weight = 0,
					ID = 'ViewControlsLabel',
					Text = 'Tree View Controls: ',
				},
				ui:CheckBox{
					Weight = 0,
					ID = 'ExpandPathMapCheckbox',
					Text = 'Expand PathMaps',
					Checked = true,
				},
				ui:CheckBox{
					Weight = 0,
					ID = 'ShowDuplicateIDsCheckbox',
					Text = 'Show Duplicate Plugin IDs',
					Checked = false,
				},

				-- Add some space
				ui:HGap(),
			},

			ui:Tree{
				ID = 'Tree',
				SortingEnabled = true,
				Events = {
					ItemDoubleClicked = true,
					ItemClicked = true
				},
			},

			ui:HGroup{
				Weight = 0,
				-- Add your GUI elements here:
				ui:Label{
					ID = 'CommentLabel',
					Text = 'Single click on a row to copy the filepath to your clipboard. Double click on a row to open the containing folder. Scroll the Tree view horizontally to the right to see the extra columns.',
					Alignment = {
						AlignHCenter = true,
						AlignTop = true
					},
				},
			},

		},
	})

	-- The window was closed
	function win.On.PluginScannerWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("PluginScanner", {
		Target {
			ID = "PluginScannerWin",
		},

		Hotkeys {
			Target = "PluginScannerWin",
			Defaults = true,

			CONTROL_W  = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
			CONTROL_F4 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
		},
	})


	-- Expand PathMap Checkbox Updated
	function win.On.ExpandPathMapCheckbox.Clicked(ev)
		UpdateTree()
	end

	-- Show Only Duplicates Checkbox Updated
	function win.On.ShowDuplicateIDsCheckbox.Clicked(ev)
		UpdateTree()
	end

	-- Copy the filepath to the clipboard when a Tree view row is clicked on
	function win.On.Tree.ItemClicked(ev)
		-- Column 1 = Filepath
		sourceFile = ev.item.Text[1]

		-- Copy the filepath to the clipboard
		bmd.setclipboard(sourceFile)
		print('[Clipboard Copy] ' .. sourceFile .. '\n')
	end

	-- Open up the folder where the plugin is located when a Tree view row is clicked on
	function win.On.Tree.ItemDoubleClicked(ev)
		-- Column 1 = Filepath
		sourceFile = ev.item.Text[1]

		-- Open up the folder where the media is located
		sourceFolder = Dirname(sourceFile)
		if bmd.fileexists(comp:MapPath(sourceFolder)) then
			bmd.openfileexternal('Open', comp:MapPath(sourceFolder))
			print('[Opening Folder] ' .. sourceFile .. '\n')
		end
	end

	-- Search for duplicate plugins
	function FindDuplicates()
		-- Clear the old duplicate table values
		for i,v in ipairs(searchResults.duplicate) do
			searchResults.duplicate[i] = nil
		end

		-- Find duplicates
		dprint('[Duplicate ID Matches]')
		for i,valSource in ipairs(searchResults.filename) do
			for j,valDest in ipairs(searchResults.filename) do
				if (i ~= j) and (valSource == valDest) then
				searchResults.duplicate[i] = true
				searchResults.duplicate[j] = true
				dprint('\t' .. tostring(valSource) .. ' == ' .. tostring(valDest))
			end
		 end
		end

		dprint('---------------------------------------------')
	end


	-- Update the contents of the tree view
	function UpdateTree()
		-----------------------------------------------------------
		-- Read the current settings from the GUI
		expandPathMapCheckbox = itm.ExpandPathMapCheckbox.Checked
		ShowDuplicateIDsCheckbox = itm.ShowDuplicateIDsCheckbox.Checked

		-- Search for duplicate plugins
		FindDuplicates()

		-- Clean out the previous entries in the Tree view
		itm.Tree:Clear()

		-- Add the Tree headers:
		hdr = itm.Tree:NewItem()
		hdr.Text[0] = 'Filename'
		hdr.Text[1] = 'Filepath'

		itm.Tree:SetHeaderItem(hdr)

		-- Resize the header column widths
		itm.Tree.ColumnWidth[0] = 180

		-- Should a relative PathMap or absolute path be used
		if expandPathMapCheckbox == false then
			itm.Tree.ColumnWidth[1] = 275
		else
			itm.Tree.ColumnWidth[1] = 635
		end

		-- Pause the onscreen updating
		itm.Tree.UpdatesEnabled = false

		c = 1
		-- ------------------------------------------------------
		-- Add an new entry to the list
		dprint('[Listing Plugin Files]')
		for i,val in ipairs(searchResults.filepath) do
			-- Filter the results in the tree view
			-- If the "Show Only Duplicates" checkbox is checked then filter the tree view to display show duplicate entries
			-- If the "Show Only Duplicates" checkbox is unchecked show all entries in the tree view
			if ((ShowDuplicateIDsCheckbox == true) and (searchResults.duplicate[i] == true)) or (ShowDuplicateIDsCheckbox == false) then
				itPlugin = itm.Tree:NewItem()
				itPlugin.Text[0] = searchResults.filename[i]

				-- Should a relative PathMap or absolute path be used
				if expandPathMapCheckbox == false then
					if searchResults.filename[i] ~= nil then
						itPlugin.Text[1] = comp:ReverseMapPath(searchResults.filepath[i])
					end
				else
					itPlugin.Text[1] = searchResults.filepath[i]
				end

				itm.Tree:AddTopLevelItem(itPlugin)

				c = c + 1
			end
		end

		-- Refresh the tree view
		itm.Tree.SortingEnabled = true
		itm.Tree.UpdatesEnabled = true

		itm.Tree:SortByColumn(0, "AscendingOrder")
		-- itm.Tree:SortByColumn(0, "DescendingOrder")

		itm.PluginScannerWin.WindowTitle = 'Plugin Scanner: ' .. c .. ' Files'
		dprint('[Plugin Files Displayed] ' .. c)
		dprint('---------------------------------------------')
		dprint('---------------------------------------------')
	end

	-- Update the contents of the tree view
	UpdateTree()

	win:Show()
	disp:RunLoop()
	win:Hide()
	app:RemoveConfig('PluginScanner')
	collectgarbage()
end

-- Run the main function
Main()
print('[Done]')
