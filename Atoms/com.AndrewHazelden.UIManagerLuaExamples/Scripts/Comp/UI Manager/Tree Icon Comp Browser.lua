--[[--
----------------------------------------------------------------------------
Comp Browser for Fusion - v1.0 2019-08-22 8.33 PM
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com
-- ----------------------------------------------------------------------------

This script is from the Reactor "UI Manager Lua & Python Examples" atom package.

It is primarily designed as a code demo for how a ui:Icon PNG image resource can be added to a ui:Tree.

This script can be used as a Fusion "Comp Browser" window that displays a list of currently open Fusion .comp files, and the rows list summary details about each comp. Double clicking on a row in the Comp Browser ui:Tree view will open the comp file's parent folder in a desktop folder browsing window.

This script requires Fusion Standalone 16 in order to work correctly as the ability to add ui:Icon resources to a ui:Tree was added to the UI Manager library in this version.

--]]--


-- Find out the current directory from a file path
-- Example: print(dirname('/Volumes/Media/image.0000.exr'))
function dirname(filename)
	return filename:match('(.*' .. osSeparator .. ')')
end

-- Show the ui:Tree View
function CompBrowser()
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 1920,600

	win = disp:AddWindow({
		ID = 'CompBrowserWin',
		TargetID = 'CompBrowserWin',
		WindowTitle = 'Comp Browser',
		Geometry = {0, 100, width, height},
		Spacing = 0,

		ui:VGroup{
			ID = 'root',
			ui:Tree{
				ID = 'Tree',
				SortingEnabled = true,
				Events = {
					ItemDoubleClicked = true,
					ItemClicked = true,
				},
			},
		},
	})

	-- The window was closed
	function win.On.CompBrowserWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- Add a header row.
	hdr = itm.Tree:NewItem()
	hdr.Text[0] = 'Comp Name'
	hdr.Text[1] = 'Media Nodes'
	hdr.Text[2] = 'Global Range'
	hdr.Text[3] = 'Render Range'
	hdr.Text[4] = 'Format Name'
	hdr.Text[5] = 'Frame Size'
	hdr.Text[6] = 'Frame Rate'
	hdr.Text[7] = 'HiQ'
	hdr.Text[8] = 'Rendering'
	hdr.Text[9] = 'Filepath'

	itm.Tree:SetHeaderItem(hdr)

	-- Number of columns in the Tree list
	itm.Tree.ColumnCount = 10

	-- Resize the Columns
	itm.Tree.ColumnWidth[0] = 320
	itm.Tree.ColumnWidth[1] = 90
	itm.Tree.ColumnWidth[2] = 90
	itm.Tree.ColumnWidth[3] = 90
	itm.Tree.ColumnWidth[4] = 182
	itm.Tree.ColumnWidth[5] = 100
	itm.Tree.ColumnWidth[6] = 70
	itm.Tree.ColumnWidth[7] = 50
	itm.Tree.ColumnWidth[8] = 65
	itm.Tree.ColumnWidth[9] = 600

	-- Change the sorting order of the tree
	itm.Tree:SortByColumn(0, "AscendingOrder")

	-- Create a table based upon the open Fusion composites
	local compList = fu:GetCompList()
	for row = 1, table.getn(compList) do
		-- Set cmp to the pointer of the current composite
		cmp = compList[row]

		-- Add a new row entry to the list
		itRow = itm.Tree:NewItem();
	
		-- Add an image resource to the cell
		-- Make sure this is excluded from Fusion 9 since the Icon support in a tree view was added in v16.
		if fu:GetVersion() and fu:GetVersion()[1] and fu:GetVersion()[1] >= 16 then
			itRow.Icon[0] = ui:Icon{File = 'Scripts:/Comp/UI Manager/fusion-logo.png'}
		end
		
		-- The Composite Tab name (comp base filename)
		itRow.Text[0] = string.format('%s', tostring(cmp:GetAttrs()['COMPS_Name']))
	
		-- Node count
		-- Should the selected nodes be listed? (Otherwise all loader/saver nodes will be listed from the comp)
		--listOnlySelectedNodes = true
		listOnlySelectedNodes = false

		local toollist1 = cmp:GetToolList(listOnlySelectedNodes, 'Loader')
		local toollist2 = cmp:GetToolList(listOnlySelectedNodes, 'Saver')
		local toollist3 = cmp:GetToolList(listOnlySelectedNodes, 'SurfaceFBXMesh')
		local toollist4 = cmp:GetToolList(listOnlySelectedNodes, 'SurfaceAlembicMesh')

		-- Scan the comp to check how many media nodes are present
		local totalLoaders = table.getn(toollist1)
		local totalSavers = table.getn(toollist2)
		local totalFBX = table.getn(toollist3)
		local totalAlembic = table.getn(toollist4)
	
		-- Add up how many media nodes are present
		local totalNodes = totalLoaders + totalSavers + totalFBX + totalAlembic
		itRow.Text[1] = tostring(totalNodes)

		-- Timeline Frame Range
		itRow.Text[2] = tostring(cmp:GetAttrs().COMPN_GlobalStart) .. '-' .. tostring(cmp:GetAttrs().COMPN_GlobalEnd)
		itRow.Text[3] = tostring(cmp:GetAttrs().COMPN_RenderStart) .. '-' .. tostring(cmp:GetAttrs().COMPN_RenderEnd)

		-- Read the comp frame format settings
		local compPrefs = cmp:GetPrefs("Comp.FrameFormat")

		-- Format Name
		itRow.Text[4] = tostring(compPrefs.Name)

		-- Frame Size
		itRow.Text[5] = tostring(compPrefs.Width) .. 'x' .. tostring(compPrefs.Height) .. ' px'

		-- Frame Rate
		itRow.Text[6] = tostring(compPrefs.Rate) .. ' fps'

		-- HiQ High Quality Mode
		itRow.Text[7] = tostring(cmp:GetAttrs().COMPB_HiQ)

		-- Render Status
		itRow.Text[8] = tostring(cmp:GetAttrs().COMPB_Rendering)

		-- The Composite absolute filename
		local filepath = cmp:MapPath(cmp:GetAttrs()['COMPS_FileName'])
		if filepath == '' or not filepath then
			filepath = '<Unsaved>'
		end
		itRow.Text[9] = tostring(filepath)


		itm.Tree:AddTopLevelItem(itRow)
	end

	-- A Tree view row was clicked on
	function win.On.Tree.ItemClicked(ev)
		print('[Single Clicked] ' .. tostring(ev.item.Text[9]))
	end

	-- A Tree view row was double clicked on
	function win.On.Tree.ItemDoubleClicked(ev)
		-- Grab the absolute comp filepath
		local compPath = dirname(tostring(ev.item.Text[9] or ''))
		print('[Double Clicked] ' .. tostring(compPath))

		-- Open the comp file's parent folder in a desktop folder browsing window
		if bmd.direxists(compPath) == true then
			bmd.openfileexternal('Open', compPath)
		end
	end

	-- The app:AddConfig() command will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("CompBrowserWin", {
		Target
		{
			ID = "CompBrowserWin",
		},

		Hotkeys
		{
			Target = "CompBrowserWin",
			Defaults = true,

			CONTROL_W = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
			CONTROL_F4 = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
		},
	})

	win:Show()
	disp:RunLoop()
	win:Hide()
end


-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Show the ui:Tree View
CompBrowser()

-- End of the script
print('[Done]')
