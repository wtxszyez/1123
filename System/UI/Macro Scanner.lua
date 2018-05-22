VERSION = 'v2.0 2018-05-21'
--[[--
Macro Scanner
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

The Macro Scanner script creates a UI Manager tree view filled with details about all of the .setting files installed in your Fusion "Macros:" and "Templates:" PathMap folders.

The [x] Expand PathMaps checkbox at the top of the window allows you to see the filepath as a full absolute path, or as a relative PathMap location shortened down to a compact form. This is useful if you want to see in a quick glance if the macro is coming from a "Macros:" or "Templates:" location.

The [x] Show Duplicate checkbox at the top of the window filters the tree view contents so you only see macros that have matching (duplicate) filenames. This makes it easy to see when you have multiple macros installed that have the same base filename on disk.

Single click on a row to copy the filepath to your clipboard. Double click on a row to open the containing folder. Scroll the Tree view horizontally to the right to see the extra columns.

## Installation ##

This script was designed to be with the WSL Reactor package manager toolset. You will find "Macro Scanner" in Reactor's "Scripts/Reactor" Category.

The "Macro Scanner.lua" script requires Fusion 9.0.1+ or Resolve 15 to be used.

## Known Issues ##

--]]--

print('\n')
print('---------------------------------------------')
print('Macro Scanner - ' .. tostring(VERSION))
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
--	 print(fmt:format(...))
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

-- The main function for Macro Scanner
function Main()
	------------------------------------------------------------------------
	-- Create a table with the results
	searchResults = {
		filepath = {},
		filename = {},
		regsHelpPage = {},
		duplicate = {},
	}


	-- ------------------------------------------------------
	-- Scan the Macros: and Templates: multipath locations for all .setting files
	mp = MultiPath('Macros:;Templates:')
	mp:Map(comp:GetCompPathMap())
	files = mp:ReadDir("*.setting", true, true) -- (string pattern, boolean recursive, boolean flat)
	-- dump(files)

	c = 1
	-- Add the Macros: PathMap files to the searchResults table
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
	-- Search inside the setting files
	for i,val in ipairs(searchResults.filepath) do
		local regsHelpPage = nil

		-- Search inside of the setting file
		for oneLine in io.lines(val) do
			-- Display the macro file contents
			-- print(oneLine)

			-- Search for the HelpPage
			if string.match(oneLine, 'HelpPage%s*=%s*(.*)%s*,') then
				regsHelpPage = string.match(oneLine, 'HelpPage%s*=%s*(.*)%s*,')
				regsHelpPage = string.gsub(regsHelpPage, '["\'%[%]]', '')
			end

		end

		searchResults.regsHelpPage[i] = regsHelpPage
	end

	-- List the setting details
	-- dump(searchResults)

	-- ------------------------------------------------------
	-- Create the GUI
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 1920,600

	win = disp:AddWindow({
		ID = 'MacroScanner',
		TargetID = 'MacroScanner',
		WindowTitle = 'Macro Scanner',
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
					ID = 'ShowDuplicateCheckbox',
					Text = 'Show Duplicate Macros',
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
	function win.On.MacroScanner.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("MacroScanner", {
		Target {
			ID = "MacroScanner",
		},

		Hotkeys {
			Target = "MacroScanner",
			Defaults = true,

			CONTROL_W	 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
			CONTROL_F4 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
		},
	})


	-- Expand PathMap Checkbox Updated
	function win.On.ExpandPathMapCheckbox.Clicked(ev)
		UpdateTree()
	end

	-- Show Only Duplicates Checkbox Updated
	function win.On.ShowDuplicateCheckbox.Clicked(ev)
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


	-- Open up the folder where the Macro is located when a Tree view row is clicked on
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


	-- Search for duplicate macros
	function FindDuplicates()
		-- Clear the old duplicate table values
		for i,v in ipairs(searchResults.duplicate) do
			searchResults.duplicate[i] = nil
		end

		-- Find duplicates
		dprint('[Duplicate Name Matches]')
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
		ShowDuplicateCheckbox = itm.ShowDuplicateCheckbox.Checked

		-- Search for duplicate setting files
		FindDuplicates()

		-- Clean out the previous entries in the Tree view
		itm.Tree:Clear()

		-- Add the Tree headers:
		hdr = itm.Tree:NewItem()
		hdr.Text[0] = 'Filename'
		hdr.Text[1] = 'Filepath'
		hdr.Text[2] = 'Help'

		itm.Tree:SetHeaderItem(hdr)

		-- Number of columns in the Tree list
		-- itm.Tree.ColumnCount = 16

		-- Resize the header column widths
		itm.Tree.ColumnWidth[0] = 258

		-- Should a relative PathMap or absolute path be used
		if expandPathMapCheckbox == false then
			itm.Tree.ColumnWidth[1] = 580
		else
			itm.Tree.ColumnWidth[1] = 954
		end

		itm.Tree.ColumnWidth[2] = 510

		-- Pause the onscreen updating
		itm.Tree.UpdatesEnabled = false

		c = 1
		-- ------------------------------------------------------
		-- Add an new entry to the list
		dprint('[Listing Macro Files]')
		for i,val in ipairs(searchResults.filepath) do
			-- Filter the results in the tree view
			-- If the "Show Only Duplicates" checkbox is checked then filter the tree view to display show duplicate entries
			-- If the "Show Only Duplicates" checkbox is unchecked show all entries in the tree view
			if ((ShowDuplicateCheckbox == true) and (searchResults.duplicate[i] == true)) or (ShowDuplicateCheckbox == false) then
				itMacro = itm.Tree:NewItem()

				-- Should a relative PathMap or absolute path be used
				if expandPathMapCheckbox == false then
					if searchResults.filename[i] ~= nil then
						itMacro.Text[1] = comp:ReverseMapPath(searchResults.filepath[i])
					end
				else
					itMacro.Text[1] = searchResults.filepath[i]
				end

				itMacro.Text[0] = searchResults.filename[i]
				itMacro.Text[2] = searchResults.regsHelpPage[i]
				itm.Tree:AddTopLevelItem(itMacro)
				c = c + 1
			end
		end

		-- Refresh the tree view
		itm.Tree.SortingEnabled = true
		itm.Tree.UpdatesEnabled = true

		itm.Tree:SortByColumn(0, "AscendingOrder")
		-- itm.Tree:SortByColumn(0, "DescendingOrder")

		itm.MacroScanner.WindowTitle = 'Macro Scanner: ' .. c .. ' Files'
		dprint('[Macro Files Displayed] ' .. c)
		dprint('---------------------------------------------')
		dprint('---------------------------------------------')
	end

	-- Update the contents of the tree view
	UpdateTree()

	win:Show()
	disp:RunLoop()
	win:Hide()
	app:RemoveConfig('MacroScanner')
	collectgarbage()
end

-- Run the main function
Main()
print('[Done]')
