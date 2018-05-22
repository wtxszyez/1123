VERSION = 'v2 2018-05-21'
--[[--
Fuse Scanner
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

The Fuse Scanner script creates a UI Manager tree view filled with details about all of the .fuse files installed in your Fusion "Fuses:" and "LUTs:" PathMap folders.

The [x] Expand PathMaps checkbox at the top of the window allows you to see the filepath as a full absolute path, or as a relative PathMap location shortened down to a compact form. This is useful if you want to see in a quick glance if the fuse is coming from a "LUTs:" or "Fuses:" location.

The [x] Show Duplicate Fuse IDs checkbox at the top of the window filters the tree view contents so you only see Fuses that have matching (duplicate) Fuse ID values. This makes it easy to see when you have multiple fuses installed that have the same internal name to Fusion regardless of what the filename on disk is.

Single click on a row to copy the filepath to your clipboard. Double click on a row to open the containing folder. Scroll the Tree view horizontally to the right to see the extra columns.

This Tree view has information sourced from the fuse FuRegisterClass function settings like:

	FuRegisterClass (fuseID), (regClass)
	REGS_Name
	REG_Version
	REGS_Category
	REGS_OpIconString
	REGS_OpDescription
	REGS_Company
	REGS_URL
	REGS_HelpTopic
	REG_TimeVariant
	REG_SupportsDoD
	REG_NoMotionBlurCtrls
	REG_NoObjMatCtrls
	REG_NoBlendCtrls
	REG_OpNoMask

## Installation ##

This script was designed to be with the WSL Reactor package manager toolset. You will find "Fuse Scanner" in Reactor's "Scripts/Reactor" Category.

The "Fuse Scanner.lua" script requires Fusion 9.0.1+ or Resolve 15 to be used.

## Known Issues ##

Fuses that use a variable to supply values to REGS_Name and REG_Version, etc.. will not report their data correctly in this script as the fuse would need to be evaluated by Lua to generate those values.

Example:
FUSE_NAME = "Cryptomatte"
REGS_Name = FUSE_NAME,
--]]--

print('\n')
print('---------------------------------------------')
print('Fuse Scanner - ' .. tostring(VERSION))
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

-- The main function for Fuse Scanner
function Main()
	------------------------------------------------------------------------
	-- Create a table with the results
	searchResults = {
		filepath = {},
		filename = {},
		regsName = {},
		regVersion = {},
		fuseID = {},
		regClass = {},
		regsCategory = {},
		regsOpIconString = {},
		regsOpDescription = {},
		regsCompany = {},
		regsURL = {},
		regsHelpTopic = {},
		regTimeVariant = {},
		regSupportsDoD = {},
		regNoMotionBlurCtrls = {},
		regNoObjMatCtrls = {},
		regNoBlendCtrls = {},
		regOpNoMask = {},
		duplicate = {},
	}


	-- ------------------------------------------------------
	-- Scan the Fuses: and LUTs: multipath locations for all .fuse files
	mp = MultiPath('Fuses:;LUTs:')
	mp:Map(comp:GetCompPathMap())
	files = mp:ReadDir("*.fuse", true, true) -- (string pattern, boolean recursive, boolean flat)
	-- dump(files)

	c = 1
	-- Add the Fuses: PathMap files to the searchResults table
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
	-- Search inside the fuse files
	for i,val in ipairs(searchResults.filepath) do
		local regsName = nil
		local regVersion = nil
		local fuseID = nil
		local regClass = nil
		local regsCategory = nil
		local regsOpIconString = nil
		local regsOpDescription = nil
		local regsCompany = nil
		local regsURL = nil
		local regsHelpTopic = nil
		local regTimeVariant = nil
		local regSupportsDoD = nil
		local regNoMotionBlurCtrls = nil
		local regNoObjMatCtrls = nil
		local regNoBlendCtrls = nil
		local regOpNoMask = nil

		-- Search inside of the fuse file
		for oneLine in io.lines(val) do
			-- Display the fuse file contents
			-- print(oneLine)

			-- Search for REGS_Name
			if string.match(oneLine, 'REGS_Name%s*=%s*(.*)%s*,') then
				regsName = string.match(oneLine, 'REGS_Name%s*=%s*(.*)%s*,')
				regsName = string.gsub(regsName, '["\'%[%]]', '')
			end

			-- Search for REG_Version
			if string.match(oneLine, 'REG_Version%s*=%s*(.*)%s*,') then
				regVersion = string.match(oneLine, 'REG_Version%s*=%s*(.*)%s*,')
				regVersion = string.gsub(regVersion, '["\'%[%]]', '')
			end

			-- Search for FuRegisterClass
			if string.match(oneLine, 'FuRegisterClass[(]%s*(.*)%s*,%s*(.*)%s*,%s*{') then
				fuseID, regClass = string.match(oneLine,'FuRegisterClass[(]%s*(.*)%s*,%s*(.*)%s*,%s*{')
				fuseID = string.gsub(fuseID, '["\'%[%]]', '')
				regClass = string.gsub(regClass, '["\'%[%]]', '')
			end

			-- Search for REGS_Category
			if string.match(oneLine, 'REGS_Category%s*=%s*(.*)%s*,') then
				regsCategory = string.match(oneLine, 'REGS_Category%s*=%s*(.*)%s*,')
				regsCategory = string.gsub(regsCategory, '["\'%[%]]', '')
			end

			-- Search for REGS_OpIconString
			if string.match(oneLine, 'REGS_OpIconString%s*=%s*(.*)%s*,') then
				regsOpIconString = string.match(oneLine, 'REGS_OpIconString%s*=%s*(.*)%s*,')
				regsOpIconString = string.gsub(regsOpIconString, '["\'%[%]]', '')
			end

			-- Search for REGS_OpDescription
			if string.match(oneLine, 'REGS_OpDescription%s*=%s*(.*)%s*,') then
				regsOpDescription = string.match(oneLine, 'REGS_OpDescription%s*=%s*(.*)%s*,')
				regsOpDescription = string.gsub(regsOpDescription, '["\'%[%]]', '')
			end

			-- Search for REGS_Company
			if string.match(oneLine, 'REGS_Company%s*=%s*(.*)%s*,') then
				regsCompany = string.match(oneLine, 'REGS_Company%s*=%s*(.*)%s*,')
				regsCompany = string.gsub(regsCompany, '["\'%[%]]', '')
			end

			-- Search for REGS_URL
			if string.match(oneLine, 'REGS_URL%s*=%s*(.*)%s*,') then
				regsURL = string.match(oneLine, 'REGS_URL%s*=%s*(.*)%s*,')
				regsURL = string.gsub(regsURL, '["\'%[%]]', '')
			end

			-- Search for REGS_HelpTopic
			if string.match(oneLine, 'REGS_HelpTopic%s*=%s*(.*)%s*,') then
				regsHelpTopic = string.match(oneLine, 'REGS_HelpTopic%s*=%s*(.*)%s*,')
				regsHelpTopic = string.gsub(regsHelpTopic, '["\'%[%]]', '')
			end

			-- Search for REG_TimeVariant
			if string.match(oneLine, 'REG_TimeVariant%s*=%s*(.*)%s*,') then
				regTimeVariant = string.match(oneLine, 'REG_TimeVariant%s*=%s*(.*)%s*,')
				regTimeVariant = string.gsub(regTimeVariant, '["\'%[%]]', '')
			end

			-- Search for REG_SupportsDoD
			if string.match(oneLine, 'REG_SupportsDoD%s*=%s*(.*)%s*,') then
				regSupportsDoD = string.match(oneLine, 'REG_SupportsDoD%s*=%s*(.*)%s*,')
				regSupportsDoD = string.gsub(regSupportsDoD, '["\'%[%]]', '')
			end

			-- Search for REG_NoMotionBlurCtrls
			if string.match(oneLine, 'REG_NoMotionBlurCtrls%s*=%s*(.*)%s*,') then
				regNoMotionBlurCtrls = string.match(oneLine, 'REG_NoMotionBlurCtrls%s*=%s*(.*)%s*,')
				regNoMotionBlurCtrls = string.gsub(regNoMotionBlurCtrls, '["\'%[%]]', '')
			end

			-- Search for REG_NoObjMatCtrls
			if string.match(oneLine, 'REG_NoObjMatCtrls%s*=%s*(.*)%s*,') then
				regNoObjMatCtrls = string.match(oneLine, 'REG_NoObjMatCtrls%s*=%s*(.*)%s*,')
				regNoObjMatCtrls = string.gsub(regNoObjMatCtrls, '["\'%[%]]', '')
			end

			-- Search for REG_NoBlendCtrls
			if string.match(oneLine, 'REG_NoBlendCtrls%s*=%s*(.*)%s*,') then
				regNoBlendCtrls = string.match(oneLine, 'REG_NoBlendCtrls%s*=%s*(.*)%s*,')
				regNoBlendCtrls = string.gsub(regNoBlendCtrls, '["\'%[%]]', '')
			end

			-- Search for REG_OpNoMask
			if string.match(oneLine, 'REG_OpNoMask%s*=%s*(.*)%s*,') then
				regOpNoMask = string.match(oneLine, 'REG_OpNoMask%s*=%s*(.*)%s*,')
				regOpNoMask = string.gsub(regOpNoMask, '["\'%[%]]', '')
			end

			-- Search for REGS_HelpTopic
			if string.match(oneLine, 'REGS_HelpTopic%s*=%s*(.*)%s*,') then
				regsHelpTopic = string.match(oneLine, 'REGS_HelpTopic%s*=%s*(.*)%s*,')
				regsHelpTopic = string.gsub(regsHelpTopic, '["\'%[%]]', '')
			end
		end

		searchResults.regsName[i] = regsName
		searchResults.regVersion[i] = regVersion
		searchResults.fuseID[i] = fuseID
		searchResults.regClass[i] = regClass
		searchResults.regsCategory[i] = regsCategory
		searchResults.regsOpIconString[i] = regsOpIconString
		searchResults.regsOpDescription[i] = regsOpDescription
		searchResults.regsCompany[i] = regsCompany
		searchResults.regsURL[i] = regsURL
		searchResults.regsHelpTopic[i] = regsHelpTopic
		searchResults.regTimeVariant[i] = regTimeVariant
		searchResults.regSupportsDoD[i] = regSupportsDoD
		searchResults.regNoMotionBlurCtrls[i] = regNoMotionBlurCtrls
		searchResults.regNoObjMatCtrls[i] = regNoObjMatCtrls
		searchResults.regNoBlendCtrls[i] = regNoBlendCtrls
		searchResults.regOpNoMask[i] = regOpNoMask
	end

	-- List the Fuse details
	-- dump(searchResults)

	-- ------------------------------------------------------
	-- Create the GUI
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 1460,600

	win = disp:AddWindow({
		ID = 'FuseScanner',
		TargetID = 'FuseScanner',
		WindowTitle = 'Fuse Scanner',
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
					Text = 'Show Duplicate Fuse IDs',
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
	function win.On.FuseScanner.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("FuseScanner", {
		Target {
			ID = "FuseScanner",
		},

		Hotkeys {
			Target = "FuseScanner",
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
	function win.On.ShowDuplicateIDsCheckbox.Clicked(ev)
		UpdateTree()
	end

	-- Copy the filepath to the clipboard when a Tree view row is clicked on
	function win.On.Tree.ItemClicked(ev)
		-- Column 5 = Filepath
		sourceFile = ev.item.Text[5]

		-- Copy the filepath to the clipboard
		bmd.setclipboard(sourceFile)
		print('[Clipboard Copy] ' .. sourceFile .. '\n')
	end


	-- Open up the folder where the fuse is located when a Tree view row is clicked on
	function win.On.Tree.ItemDoubleClicked(ev)
		-- Column 5 = Filepath
		sourceFile = ev.item.Text[5]

		-- Open up the folder where the media is located
		sourceFolder = Dirname(sourceFile)
		if bmd.fileexists(comp:MapPath(sourceFolder)) then
			bmd.openfileexternal('Open', comp:MapPath(sourceFolder))
			print('[Opening Folder] ' .. sourceFile .. '\n')
		end
	end


	-- Search for duplicate fuses
	function FindDuplicates()
		-- Clear the old duplicate table values
		for i,v in ipairs(searchResults.duplicate) do
			searchResults.duplicate[i] = nil
		end

		-- Find duplicates
		dprint('[Duplicate ID Matches]')
		for i,valSource in ipairs(searchResults.fuseID) do
			for j,valDest in ipairs(searchResults.fuseID) do
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

		-- Search for duplicate fuses
		FindDuplicates()

		-- Clean out the previous entries in the Tree view
		itm.Tree:Clear()

		-- Add the Tree headers:
		hdr = itm.Tree:NewItem()
		hdr.Text[0] = 'ID'
		hdr.Text[1] = 'Name'
		hdr.Text[2] = 'Version'
		hdr.Text[3] = 'Class'
		hdr.Text[4] = 'Category'
		hdr.Text[5] = 'Filepath'
		hdr.Text[6] = 'Filename'
		hdr.Text[7] = 'Description'
		hdr.Text[8] = 'Company'
		hdr.Text[9] = 'URL'
		hdr.Text[10] = 'Help'
		hdr.Text[11] = 'Time Variant'
		hdr.Text[12] = 'SupportsDoD'
		hdr.Text[13] = 'NoMotionBlurCtrls'
		hdr.Text[14] = 'NoObjMatCtrls'
		hdr.Text[15] = 'NoBlendCtrls'
		hdr.Text[16] = 'OpNoMask'

		itm.Tree:SetHeaderItem(hdr)

		-- Number of columns in the Tree list
		-- itm.Tree.ColumnCount = 16

		-- Resize the header column widths
		itm.Tree.ColumnWidth[0] = 150
		itm.Tree.ColumnWidth[1] = 150
		itm.Tree.ColumnWidth[2] = 65
		itm.Tree.ColumnWidth[3] = 150
		itm.Tree.ColumnWidth[4] = 100

		-- Should a relative PathMap or absolute path be used
		if expandPathMapCheckbox == false then
			itm.Tree.ColumnWidth[5] = 275
		else
			itm.Tree.ColumnWidth[5] = 635
		end

		itm.Tree.ColumnWidth[6] = 180
		itm.Tree.ColumnWidth[7] = 370
		itm.Tree.ColumnWidth[8] = 175
		itm.Tree.ColumnWidth[9] = 210
		itm.Tree.ColumnWidth[10] = 510
		itm.Tree.ColumnWidth[11] = 90
		itm.Tree.ColumnWidth[12] = 90
		itm.Tree.ColumnWidth[13] = 120
		itm.Tree.ColumnWidth[14] = 100
		itm.Tree.ColumnWidth[15] = 90
		itm.Tree.ColumnWidth[16] = 90

		-- Pause the onscreen updating
		itm.Tree.UpdatesEnabled = false

		c = 1
		-- ------------------------------------------------------
		-- Add an new entry to the list
		dprint('[Listing Fuse Files]')
		for i,val in ipairs(searchResults.filepath) do
			-- Filter the results in the tree view
			-- If the "Show Only Duplicates" checkbox is checked then filter the tree view to display show duplicate entries
			-- If the "Show Only Duplicates" checkbox is unchecked show all entries in the tree view
			if ((ShowDuplicateIDsCheckbox == true) and (searchResults.duplicate[i] == true)) or (ShowDuplicateIDsCheckbox == false) then
				itFuse = itm.Tree:NewItem()
				itFuse.Text[0] = searchResults.fuseID[i]
				itFuse.Text[1] = searchResults.regsName[i]
				itFuse.Text[2] = searchResults.regVersion[i]
				itFuse.Text[3] = searchResults.regClass[i]
				itFuse.Text[4] = searchResults.regsCategory[i]

				-- Should a relative PathMap or absolute path be used
				if expandPathMapCheckbox == false then
					if searchResults.filename[i] ~= nil then
						itFuse.Text[5] = comp:ReverseMapPath(searchResults.filepath[i])
					end
				else
					itFuse.Text[5] = searchResults.filepath[i]
				end

				itFuse.Text[6] = searchResults.filename[i]
				itFuse.Text[7] = searchResults.regsOpDescription[i]
				itFuse.Text[8] = searchResults.regsCompany[i]
				itFuse.Text[9] = searchResults.regsURL[i]
				itFuse.Text[10] = searchResults.regsHelpTopic[i]
				itFuse.Text[11] = searchResults.regTimeVariant[i]
				itFuse.Text[12] = searchResults.regSupportsDoD[i]
				itFuse.Text[13] = searchResults.regNoMotionBlurCtrls[i]
				itFuse.Text[14] = searchResults.regNoObjMatCtrls[i]
				itFuse.Text[15] = searchResults.regNoBlendCtrls[i]
				itFuse.Text[16] = searchResults.regOpNoMask[i]
				itm.Tree:AddTopLevelItem(itFuse)

				dprint('\t[' .. c .. '] ' .. tostring(searchResults.fuseID[i]))
				c = c + 1
			end
		end

		-- Refresh the tree view
		itm.Tree.SortingEnabled = true
		itm.Tree.UpdatesEnabled = true

		itm.Tree:SortByColumn(0, "AscendingOrder")
		-- itm.Tree:SortByColumn(0, "DescendingOrder")

		itm.FuseScanner.WindowTitle = 'Fuse Scanner: ' .. c .. ' Files'
		dprint('[Fuse Files Displayed] ' .. c)
		dprint('---------------------------------------------')
		dprint('---------------------------------------------')
	end

	-- Update the contents of the tree view
	UpdateTree()

	win:Show()
	disp:RunLoop()
	win:Hide()
	app:RemoveConfig('FuseScanner')
	collectgarbage()
end

-- Run the main function
Main()
print('[Done]')
