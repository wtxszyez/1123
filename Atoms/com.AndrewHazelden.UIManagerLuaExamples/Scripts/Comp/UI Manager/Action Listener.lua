--[[
Action Listener v2 - 2019-10-01
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

## Overview ##

The Action Listener script uses the Fusion ActionManager and ui:AddNotify() functions to log events as they happen inside the Fusion GUI. Only a small percentage of the compositing tasks you carry out in Fusion will show up in the "Recorded Action Log" view since the window is only able to track tools and commands that are applied using the new "action" system.

This script makes use of the fact Lua is a dynamic programming language by creating new functions for handling each ui:AddNotify event on the fly. This script is a Fusion Lua based UI Manager example that works in Fusion 9+

## Installation ##

Copy the "Action Listener.lua" script into your Fusion user preferences "Scripts/Comp/" folder.

Copy the "Action Listener.fu" hotkey file into your Fusion user preferences "Config/" folder.

## Usage ##

In Fusion you can then run the script from inside Fusion's GUI by selecting the "Script > Action Listener" item.

Start adding nodes and carrying out compositing tasks to see the Recorded Action Log update and scroll.

If you install the "Action Listenr.fu" hotkey file you can use the (Command + R) or (Control + R) hotkey to open the "Action Listener" window.


## Version History ##

v1.3 - 2017-11-21
- Action Listener WSL "Reactor Edition"

v2.0 - 2019-10-01
- Added Fusion scope action listening to AddNotify, which massively expands the amount of actions reported by the "Action Listener" script compared to what the previous composite scope only action listening approach was able to output.
- Added comp:DoAction() translation of generic actions to make the snippets runnable.

## GUI Controls ##

### Button Controls ###

The "Print Actions List" button will output a list of all the actions that are present in Fusion to the Console tab.

The "Clear Event and Actions Logs" button will clear the text fields in the Action Listener GUI and give you a fresh recording.

### Checkbox Controls

The "Translate Actions to Lua" checkbox tries to convert the action commands to the nearest Lua approximation.

The "Print Action Log to Console" checkbox will print a running log of the Action and event logs to the Console tabs. When the "ev.Args.tool", "ev.Args.prev", "ev.Rets.tool", and "ev.sender" table items are printed to the console they will have their pointer values probed using :GetAttrs() to print out the extra details.

The "Track Elapsed Time" checkbox adds a pause that will match the speed of the original recorded actions.

## Actions List ##

AddSetting
AddTool
App_About
App_Copy
App_CustomizeHotkeys
App_CustomizeToolBars
App_Cut
App_Delete
App_Exit
App_Help
App_NewImageView
App_OnlyActiveComp
App_Paste
App_PasteSettings
App_SelectAll
App_ShowUI
Bin_Icon_Size
Bin_New_Folder
Bin_New_Item
Bin_New_Reel
Bin_Show_Checker
Bin_View_Mode
Bins_Delete
Bins_Mode_Exit
Bins_Play
Bins_Refresh
Bins_Rename
Bins_SelectAll
Bins_Stop
Comp_Abort
Comp_Activate_Tool
Comp_BackgroundRender
Comp_Choose_Action
Comp_Choose_Tool
Comp_Close
Comp_New
Comp_NewFloatFrame
Comp_NewTabbedFrame
Comp_Open
Comp_Opened
Comp_Recent_Clear
Comp_Recent_Open
Comp_Redo
Comp_Render
Comp_Render_End
Comp_Render_Frame
Comp_Save
Comp_SaveAs
Comp_SaveCopyAs
Comp_SaveVersion
Comp_ShowTimeCode
Comp_Start_Render
Comp_StartRender
Comp_TimeCodeFormat
Comp_Undo
Execute
Frame_Activate_Frame
Frame_Activate_Next
Frame_Activate_Prev
Frame_Activate_SubWnd
Layout_Load
Layout_Reset
Layout_Save
Layout_Switch
NetRender_Allow
No_Action
Playback_Mode
Playback_Seek
Playback_Seek_End
Playback_Seek_Start
Player_Channel
Player_Device_DeckLink
Player_Gain
Player_Gamma
Player_Guide_Enable
Player_Guide_Select
Player_Item_Next
Player_Item_Prev
Player_Loop_Reset
Player_Loop_Set_In
Player_Loop_Set_Out
Player_Loop_Set_Shot
Player_Play
Player_Play_Forward
Player_Play_Reverse
Player_Seek_By
Player_Seek_End
Player_Seek_Next
Player_Seek_Prev
Player_Seek_Start
Player_Seek_To
Player_Set_FPS
Player_Set_Loop
Player_Set_Time
Player_Show_Metadata
Player_Sync_Mode
Player_Trim_Exit
Player_Trim_Set_In
Player_Trim_Set_Out
Prefs_Show
Reel_Delete_Selected
Reel_Delete_Selected
RunScript
Script_Edit
Target_Show_Menu
Target_Show_Menu
Target_Show_Scripts
Time_Goto_GlobalEnd
Time_Goto_GlobalStart
Time_Goto_Key_Next
Time_Goto_Key_Prev
Time_Goto_RenderEnd
Time_Goto_RenderStart
Time_Set
Time_Step_Back
Time_Step_Forward
Time_Step_NextKey
Time_Step_PrevKey
Tool_Settings_Activate
Tool_Settings_Store
Tool_ViewClear
Tool_ViewOn
Utility_Show
View_Pan_Mode
View_Reset
View_Show
View_Zoom_Absolute
View_Zoom_Fit
View_Zoom_In
View_Zoom_Mode
View_Zoom_Out
View_Zoom_Rectangle
View_Zoom_Relative
Viewer_3D_CentreSelected
Viewer_3D_FitAll
Viewer_3D_FitSelected
Viewer_Buffer
Viewer_Channel
Viewer_Controls_Show
Viewer_Guides_Show
Viewer_Image_ROI_Enable
Viewer_Lock
Viewer_QuadView
Viewer_Reset
Viewer_Scale_Abs
Viewer_Scale_Rel
Viewer_SubView_Show
Viewer_SubView_Swap
Viewer_Tools_Disable
Viewer_Unview_All

## Supported Action to Lua Translations ##

The process of translating each action event to its matching Lua script output is a manual process and will take a while to fully implement.

Here is a list of the Lua translated actions:

	AddTool()
	App_About()
	AddSetting()
	Comp_Abort()
	Comp_Activate_Tool()
	Comp_Redo()
	Comp_Start_Render()
	Comp_Render_Frame()
	Comp_Save()
	Comp_SaveAs()
	Comp_SaveCopyAs()
	Comp_SaveVersion()
	Comp_Undo()
	Execute()
	Playback_Mode()
	RunScript()
	Time_Set()
	Time_Step_Back()
	Time_Step_Forward()
	Time_Goto_GlobalStart()
	Time_Goto_GlobalEnd()
	Time_Goto_RenderStart()
	Time_Goto_RenderEnd()
	Viewer_3D_CentreSelected()
	Viewer_3D_FitAll()
	Viewer_3D_FitSelected()
	Viewer_Lock()

## Dev Todos ##

fusion:ToggleBins()

]]

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
print('[Action Listener]')

-- Notification tracking table
notify = {}
notifyCount = 1

local trackTime = true
local prev_when = 0

-- Convert a table to a string
-- Example: TableToString({})
-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
function TableToString(tbl)
	if type(tbl) == 'table' then
		local str = '\n'
		
		for i,val in pairs(tbl) do
			if i == 1 then
				str = str .. 'table: ' .. TableToString(val) .. '\n'
			else
				str = str .. '	' .. i .. ' = ' .. TableToString(val) .. '\n'
			end
		end
		
		return str
	else
		return tostring(tbl)
	end
end

-- Check the current operating system platform
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Create the UI Manager GUI
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 1200,700

win = disp:AddWindow({
	ID = 'ActionListenerWin',
	TargetID = 'ActionListenerWin',
	WindowTitle = 'Fusion Action Listener',
	Geometry = {0, 100, width, height},
	Margin = 10,
	Spacing = 0,

	ui:VGroup{
		ID = 'root',

		-- Add your GUI elements here:

		-- Recorded Action section
		ui:Label{
			ID = 'LogLabel',
			Weight = 0,
			Text = 'Recorded Action Log:',
		},
		ui:TextEdit{
			ID = 'LogTextEdit',
			Weight = 0.75,
			PlaceholderText = 'Action Listener records the actions that happen in a Fusion compositing session and displays the results in an event log.',
			Font = ui:Font{
				Family = 'Droid Sans Mono',
				StyleName = 'Regular',
				PixelSize = 12,
				MonoSpaced = true,
				StyleStrategy = {ForceIntegerMetrics = true},
			},
			TabStopWidth = 28,
			LineWrapMode = 'NoWrap',
			AcceptRichText = false,
			ReadOnly = true,
			-- Use the Fusion hybrid lexer module to add syntax highlighting
			Lexer = 'fusion',
		},

		-- Add a the horizontal strip of checkbox controls
		ui:HGroup{
			Weight = 0.05,
			ui:CheckBox{
				ID = 'TranslateToLuaCheckbox',
				Weight = 0.5,
				Text = 'Translate Actions to Lua',
				Checked = true,
			},
			ui:CheckBox{
				ID = 'PrintToConsoleCheckbox',
				Weight = 0.5,
				Text = 'Print Action Log to Console',
				Checked = true,
			},
			ui:CheckBox{
				ID = 'TrackElapsedTimeCheckbox',
				Weight = 0.5,
				Text = 'Track Elapsed Time',
				Checked = false,
			},
		},

		-- Event section
		ui:Label{
			ID = 'LastEventLabel',
			Weight = 0,
			Text = 'Last Event:',
		},
		ui:TextEdit{
			ID = 'EventTextEdit',
			Weight = 0.4,
			PlaceholderText = 'This section shows results from the last event.',
			Font = ui:Font{
				Family = 'Droid Sans Mono',
				StyleName = 'Regular',
				PixelSize = 12,
				MonoSpaced = true,
				StyleStrategy = {ForceIntegerMetrics = true},
			},
			TabStopWidth = 28,
			LineWrapMode = 'NoWrap',
			AcceptRichText = false,
			ReadOnly = true,
			
			-- Use the Fusion hybrid lexer module to add syntax highlighting
			Lexer = 'fusion',
		},

		-- Clear Event Log Button
		ui:HGroup{
			Weight = 0.1,
			ui:Button{
				Weight = 0.01,
				ID = 'PrintActionsListButton',
				Text = 'Print Actions List',
			},
			ui:Button{
				Weight = 0.001,
				ID = 'ClearLogButton',
				Text = 'Clear Event and Action Logs',
			},
		},
	},
})


-- Add your GUI element based event functions here:
itm = win:GetItems()


-- The window was closed
function win.On.ActionListenerWin.Close(ev)
	disp:ExitLoop()
end


-- Print a copy of the actions list to the Console
function win.On.PrintActionsListButton.Clicked(ev)
	-- Track the actions that are available in Fusion
	local actionList = fu.ActionManager:GetActions()

	-- Count the total number of actions
	actionCount = 0
	for i, act in ipairs(actionList) do
		if not act:Get('Parent') then
			actionCount = actionCount + 1
		end
	end
	print('[' .. actionCount .. ' Actions Found]')

	-- List each action sequentially
	for i, act in ipairs(actionList) do
		if not act:Get('Parent') then
			print(act.ID)
		end
	end
end


-- The Clear Event Log Button was pressed
function win.On.ClearLogButton.Clicked(ev)
	itm.LogTextEdit.PlainText = ' '
	itm.EventTextEdit.PlainText = ' '
end


-- Add a new function for each AddNotify event
function ProcessAction(a, win)
	-- Track all scopes of the actions (app, comp, etc...)
	notify[notifyCount] = ui:AddNotify(a.ID, nil)
	notifyCount = notifyCount + 1

	print('[AddNotify] ' .. a.ID)

	disp.On[a.ID] = function(ev)
	-- win.On[a.ID] = function(ev)

	-- List the event that happened
	what = tostring(ev.what)
	when = tonumber(ev.when)

	-- Args
	argsId = tostring(ev.Args.id)
	argsTime = tostring(ev.Args.time)
	argsTool = tostring(ev.Args.tool)
	if argsTool ~= 'nil' then
		argsToolName = tostring(ev.Args.tool:GetAttrs('TOOLS_Name'))
		argsToolType = tostring(ev.Args.tool:GetAttrs('TOOLS_RegID'))
	else
		argsToolName = 'nil'
		argsToolType = 'nil'
	end

	-- Rets
	retsTool = tostring(ev.Rets.tool)
	if retsTool ~= 'nil' then
		retsToolName = tostring(ev.Rets.tool:GetAttrs('TOOLS_Name') or '')
	else
		retsToolName = 'nil'
	end

	-- Sender
	sender = tostring(ev.sender)
	if sender ~= 'nil' then
		senderCompFilename = tostring(ev.sender:GetAttrs('COMPS_FileName') or '')
		-- Debug print the sender table
		-- dump(ev.sender:GetAttrs())
	else
		senderCompFilename = 'nil'
	end

	-- Elapsed time
	if prev_when == 0 then
		prev_when = when
	end
	elapsed = when - prev_when

	local luaCommand = ''
	local luaElapsed = 'bmd.wait(' .. elapsed .. ') -- Pause'

	-- Translate the Action events back into Lua commands
	if itm.TranslateToLuaCheckbox.Checked then 
		if what == 'AddTool' then
			-- Add a node to the comp
			-- The magic coordinate values "-32768, -32768" mean Fusion will automatically place the node at the right spot relative to the current selection
			luaCommand = 'AddTool("' .. argsId .. '", -32768, -32768) -- Add a ' .. argsId .. ' node to the comp called "' .. retsToolName .. '"'
			-- luaCommand = 'AddTool("' .. argsId .. '")'
		elseif what == 'App_About' then
			-- About Fusion Dialog
			luaCommand = 'app:ShowAbout() -- About Fusion dialog'
		elseif what == 'AddSetting' then
			-- Add a macro to the comp
			luaCommand = 'comp:Paste(bmd.readfile(comp:MapPath("' .. tostring(ev.Args.filename) .. '"))) -- Add a macro .setting file to the comp'
		elseif what == 'Time_Set' then
			-- Move the playhead
			luaCommand = 'comp.CurrentTime = ' .. argsTime .. ' -- Move the playhead'
		elseif what == 'Time_Step_Forward' then
			-- Step the playhead forward by 1 frame
			luaCommand = 'comp.CurrentTime = comp.CurrentTime + 1 -- Step the playhead forward by 1 frame'
		elseif what == 'Time_Step_Back' then
			-- Step the playhead back by 1 frame
			luaCommand = 'comp.CurrentTime = comp.CurrentTime - 1 -- Step the playhead back by 1 frame'
		elseif what == 'Time_Goto_GlobalStart' then
			-- Move the playhead to the GlobalStart
			luaCommand = 'comp.CurrentTime = composition:GetAttrs().COMPN_GlobalStart -- Move the playhead to the GlobalStart'
		elseif what == 'Time_Goto_GlobalEnd' then
			-- Move the playhead to the GlobalEnd
			luaCommand = 'comp.CurrentTime = composition:GetAttrs().COMPN_GlobalEnd -- Move the playhead to the GlobalEnd'
		elseif what == 'Time_Goto_RenderStart' then
			-- Move the playhead to the RenderStart
			luaCommand = 'comp.CurrentTime = composition:GetAttrs().COMPN_RenderStart -- Move the playhead to the RenderStart'
		elseif what == 'Time_Goto_RenderEnd' then
			-- Move the playhead to the RenderEnd
			luaCommand = 'comp.CurrentTime = composition:GetAttrs().COMPN_RenderEnd -- Move the playhead to the RenderEnd'
		elseif what == 'Comp_Abort' then
			-- The Esc key was press to abort the current render
			luaCommand = 'comp:AbortRender() -- The Esc key was press to abort the current render'
		elseif what == 'Comp_Activate_Tool' then
			if argsToolType ~= 'nil' and argsToolName ~= 'nil' and argsTool ~= 'nil' then
				-- Select a node
				luaCommand = 'comp:SetActiveTool(' .. tostring(argsToolName) .. ') -- Selected a ' .. tostring(argsToolType) .. ' node called "' .. tostring(argsToolName) .. '"'
				-- luaCommand = 'comp.CurrentFrame.FlowView:Select("' .. argsId .. '")'
			else
				-- Deselect all nodes
				luaCommand = 'comp.CurrentFrame.FlowView:Select() -- Deselect the nodes'
			end
		elseif what == 'Comp_Start_Render' then
			-- Start a batch sequence rendering task
			luaCommand = 'comp:Render() -- Start a batch sequence rendering task'
		elseif what == 'Comp_Render_Frame' then
			-- A frame is being rendered to disk as part of a batch sequence rendering task
			luaCommand = 'comp:Render({ FrameRange = "' .. argsTime .. '", Wait = true }) -- Render a frame to disk'
		elseif what == 'Comp_Undo' then
			-- The Undo command
			luaCommand = 'comp:Undo(1) -- Undo'
		elseif what == 'Comp_Redo' then
			-- The Redo command
			luaCommand = 'comp:Redo(1) -- Redo'
		elseif what == 'Comp_Save' then
			-- The Save command
			luaCommand = 'comp:Save("' .. senderCompFilename .. '") -- Saved the comp file "' .. senderCompFilename .. '"'
		elseif what == 'Comp_SaveAs' then
			-- The SaveAs command
			luaCommand = 'comp:SaveAs() -- Saved the comp file as "' .. senderCompFilename .. '"'
		elseif what == 'Comp_SaveCopyAs' then
			-- The SaveCopyAs command
			luaCommand = 'comp:SaveCopyAs() -- Saved a copy of the comp file'
		elseif what == 'Comp_SaveVersion' then
			-- The SaveAs command
			luaCommand = 'comp:SaveVersion() -- Saved a version of the comp with the name of "' .. senderCompFilename .. '"'
		elseif what == 'Execute' then
			-- The execute command runs a snippet of script code from a variable
			luaCommand = 'comp:Execute() -- Run a snippet of script code from a variable'
		elseif what == 'RunScript' then
			-- The RunScript command runs a script from disk
			luaCommand = 'comp:RunScript("' .. tostring(ev.Args.filename) .. '") -- Run a script from disk'
		elseif what == 'Viewer_Lock' then
			-- The viewer window lock command
			-- Will require checking the actual right or left viewer context with something like:
			-- left = comp:GetPreviewList().Left.View.SetLocked()
			luaCommand = 'self:SetLocked() -- Lock the viewer'
		elseif what == 'Viewer_3D_FitAll' then
			-- Fit the 3D view to all
			-- Will require checking the actual right or left viewer context with something like:
			-- left = comp:GetPreviewList().Left.View.SetLocked()
			luaCommand = 'self:FitAll() -- Fit the 3D View to All'
		elseif what == 'Viewer_3D_CentreSelected' then
			-- Center the 3D View
			-- Will require checking the actual right or left viewer context with something like:
			-- left = comp:GetPreviewList().Left.View.SetLocked()
			luaCommand = 'self:CenterSelected() -- Center the 3D View'
		elseif what == 'Viewer_3D_FitSelected' then
			-- Fit the 3D view to selected
			-- Will require checking the actual right or left viewer context with something like:
			-- left = comp:GetPreviewList().Left.View.SetLocked()
			luaCommand = 'self:FitSelected() -- Fit the 3D view to selected'
		elseif what == 'Fusion_View_Show' then
			-- View layout change
			if ev.Rets and ev.Rets.state ~= nil then
				local viewState = ev.Rets.state and "show" or "Hide"
				luaCommand = 'comp:DoAction("Fusion_View_Show", {view = "' .. tostring(ev.Args.view) .. '"}) -- ' .. tostring(viewState) .. ' the "' .. tostring(ev.Args.view) .. '" view'
			else
				luaCommand = 'comp:DoAction("Fusion_View_Show", {view = "' .. tostring(ev.Args.view) .. '"})'
			end
		elseif what == 'Console_Show' then
			-- Console window change
			luaCommand = 'comp:DoAction("Console_Show", {}) -- Toggle the display of the Console view'
		elseif what == 'Playback_Mode' then
			-- Play the sequence
			
			-- Check if play in reverse is active
			if ev.Args.play == false then
				-- Stop playing the sequence
				luaCommand = 'comp:Stop() -- Stop playing the sequence'
			else
				-- Play the sequence forwards
				if tostring(ev.Args.reverse) ~= 'nil' then
					luaCommand = 'comp:Play(' .. tostring(ev.Args.reverse) .. ') -- Play the sequence in reverse'
				else
					luaCommand = 'comp:Play() -- Play the sequence forwards'
				end
			end
		else
			-- Add the action record to the "Last Event" Log 
			if argsId == 'nil' then
				 luaCommand = 'comp:DoAction("' .. what .. '", {})'
			else
				luaCommand = 'comp:DoAction("' .. what .. '", {}) -- ' .. what .. '("' .. argsId .. '")'
			end
		end
	else
		-- Lua translation is off - Add the action record to the "Last Event" Log
		if argsId == 'nil' then
			 luaCommand = what .. '()'
		else
			luaCommand = what .. '("' .. argsId .. '")'
		end
	end
	
	-- Should time be tracked in the logging window
	--if trackTime == true then 
	if itm.TrackElapsedTimeCheckbox.Checked then 
		logEntry = luaElapsed .. '\n' .. luaCommand
	else
		logEntry = luaCommand
	end
	
	-- Append the record to the event log
	itm.LogTextEdit.PlainText = logEntry .. '\n' .. itm.LogTextEdit.PlainText
	
	-- List the raw event table
	itm.EventTextEdit.PlainText = TableToString(ev)
	
	-- Print Action Log to Console
	if itm.PrintToConsoleCheckbox.Checked then
		print('[Action] ' .. luaCommand)
		print('[Event]')
		dump(ev)
		
		if ev.Args.tool ~= nil then
			print('[ev.Args.tool]')
			dump(ev.Args.tool:GetAttrs())
		end
		
		if ev.Args.prev ~= nil then
			print('[ev.Args.prev]')
			dump(ev.Args.prev:GetAttrs())
		end
		
		if ev.Rets.tool ~= nil then
			print('[ev.Rets.tool]')
			dump(ev.Rets.tool:GetAttrs())
		end
		
		if ev.sender ~= nil then
			print('[ev.sender]')
			dump(ev.sender:GetAttrs())
		end
		
		print('-------------------------------------------------------------------------------')
	end
	
	-- Track the time interval between actions
	prev_when = when
	end
end


-- The main function
function Main()
	-- Track the actions that are available in Fusion
	local actionList = fu.ActionManager:GetActions()
	for i, act in ipairs(actionList) do
		if not act:Get('Parent') then
			-- Add a new AddNotify event for each action found
			ProcessAction(act, win)
		end
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('ActionListener', {
		Target {
			ID = 'ActionListenerWin',
		},

		Hotkeys {
			Target = 'ActionListenerWin',
			Defaults = true,
			
			CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
			CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		},
	})

	-- Adjust the syntax highlighting colors
	bgcol = {
		R = 0.125,
		G = 0.125,
		B = 0.125,
		A = 1
	}

	-- Set the Log text region background color
	itm.LogTextEdit.BackgroundColor = bgcol
	itm.LogTextEdit:SetPaletteColor('All', 'Base', bgcol)

	-- Set the event text region backgrouond color
	itm.EventTextEdit.BackgroundColor = bgcol
	itm.EventTextEdit:SetPaletteColor('All', 'Base', bgcol)
end

-- Display the window
win:Show()

-- Add the action listener functions, setup the hotkeys and adjust the ui:TextEdit background colors
Main()

-- Keep the window updating until the script is quit
disp:RunLoop()
win:Hide()
app:RemoveConfig('ActionListener')
collectgarbage()
