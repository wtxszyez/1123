_VERSION = [[Version 0.9 - Feb 18, 2018]]
-- [se] ScriptScript
-- BMD Fusion Comp-Script
-- have all your little snippets in one comfortable place
-- comment your scripts for your co-workers and add helpful hints.
-- (c) 2018 Eric 'SirEdric' Westphal
-- eric@SirEdric.de | www.fusiontrainer.com
-- parts of the code (especially the GUI stuff) courtesy of Andrew Hazelden https://www.steakunderwater.com/wesuckless/memberlist.php?mode=viewprofile&u=592

--=================================================================================================================
-- Define your table of available functions here. The table order is:
-- [Script Display Name], [Affects tools], [Script Function Name (the name of the actual function defined later in this script)], [Description], [additional Args]
--=================================================================================================================
mIcons = app:MapPath([[Scripts:/Comp/Dev/]])

-- icons currently live in the OriginalScriptDir:\icons\

myScripts = {
	-- [1]Script Display Name, [2]Affects tools, [3]Script FunctionName(!), [4]Description, [5]additional Args, [6] Path to external script, [7] Text for Special Switch
	{"Set All Materials to 1/1/1", "Materials", "setMat", [[<h3 align="center">Materials Full Brightness</h3><br>Set the Diffuse Color of Materials in the comp to R,G,B = 1,1,1 to achieve a neutral look.<br>You can also put other <b>comma separated</b> values like 1,0,0 or 0.5,0.75,1 into the Additional Arguments field.]],"1.0,1.0,1.0"},
	{"Scale Meshes by Factor", "3D Meshes", "scaleMeshes", [[<h3 align="center">Scale Meshes</h3><br>Scale all Meshes up or down. A factor lower than 1 scales down, a factor larger than 1 scales up. <br><br><h4>DANGER!</h4> This can result in wrong object positions! Check the result thoroughly! If this doesn't work, re-export the OBJs with the correct scaling from Blender.]],"1.0"},
	{"Rename Materials to Standard Names", "Materials", "renameMaterials", [[<h3 align="center">Material Standard Names</h3><br>Rename all Materials to valid standard Names.<br>Select the desired name from the dropdown.<br><center><img src="icons:/notice2.png"></center>]],{"chrome", "custom_" , "default", "diffuse", "emit", "glass", "glossy", "unlit", "video"},},
	{"Post Multiply by Alpha", "Loaders", "AlphaPostMultiply", [[<h3 align="center">Alpha Post Multiply</h3><br>Set Loader's PostMultiplyBy Alpha to 1.]]},
	{"Remove all Animation", "All", "removeAllAnimation", [[<h3 align="center">Remove Animation</h3><br>Deletes all Animation and Expressions on all (selected) tools. Activate the "Special Switch" to remove animations only and keep Expressions as they are.]],nil,nil,[[Keep Expressions]],},
	{"Set Comment on Tools", "All", "setToolsComments", [[<h3 align="center">Set Comments</h3><br>Set or delete comments in selected or all tools.]]},
	{"Select Tools that have Comments", "All", "selectCommentTools", [[<h3 align="center">Select Commented</h3><br>Select all tools containing comments or set a specific comment in "additional Arguments".<br><br>Activate <b>Special Switch</b> to <b>add</b> to the current selection.<br><br>Leave <b>Special Switch</b> off to <b>clear</b> the current selection first.]]},
	{"Ext Set all Mat", "External", "externalScript", [[<h3 align="center">Do something outside the box.</h3><br>starts externally!]], [[Q:\_assets\FusionScripts\Comp\MO_MultiOBJtoSPX.lua]],},
	{"Switch OpenCL mode if applicable", "OpenCL enabled", "switchOpenCL", [[<h3 align="center">Switch OpenCL</h3><br>Modify the OpenCL mode of those tools that have an OpenCL switch in their Fusion tab.]], {"Disable", "Auto", "Enable"},},
	{"Bite my Back", "Benders", "bla", [[<h3 align="center">Yeah</h3><br>Whatever]], {"some", "odd", "stuff"},},
	{"Shuffle Spline Colors", "animated Tools", "shuffleSplineColors",[[<h3 align="center">Shuffle Spline Colors</h3><br>Assigns new, random colors to the Splines in Splineview.]]},
	{"Empty", "Nothing", "blub"},

}

-- you can also define RGBA text-colors for the items in the tree, based on the "affects tools" name in myScripts
myColors = {
	["Materials"] = { 0.54, 0.7, 0.48, 1 },
	["3D Meshes"] = { 0.67, 0.78, 0.9, 1 },
	["Loaders"] = { 0.74, 0.9, 0.74, 1 },
	["External"] = { 0.61, 0.62, 0.42, 1 },
	["OpenCL enabled"] = { 0.4, 0.8, 0.4, 1 },
}

--------------------------------------------------------------------------------------------------------------------
-- Define global variables and settings here
--------------------------------------------------------------------------------------------------------------------
--valid_matNames = {chrome = true, glass=true, diffuse=true, glossy = true, video = true, unlit = true, default = true, emit = true, keep_as_is = true, custom_0 = true}
-- We can't bake DT_Image or DT_Mask (and possibly others...)
unbakeable = { Image = true, Mask = true, Particles = true, DataType3D = true } -- used by "remove animation"



--------------------------------------------------------------------------------------------------------------------
-- Define your actual functions here. The function name MUST match the third entry in the associated myScripts table
-- The Mainscript gives you some handles to play with:
-- "tool"	:	the actual tool that is being processed. Can be used to derive attributes from the tool like tool:TOOLS_RegID 
-- "tType"	:	the tool's RegID
-- "tName"	:	the tool's Name
-- "ct"		:	the comp's current time
-- "flow"	:	the current flow view.
-- "doInv"	: 	Boolean value according to the script's "Invert Value" checkbox
-- "combo"	: 	The currently selected index of the combo box

-- adding "return true" to the end of the function triggers the script's counter etc.
--------------------------------------------------------------------------------------------------------------------

function setMat() -- set Blinn Material's Diffuse color to 1/1/1
	colValues = {1,1,1}
	if addArgs ~= "" then
		argsToTable()
		if #argTable == 3 then
			colValues = argTable
		end
	end

	--dump(colValues)
	if tType:match("Mtl") then
		if tool.Diffuse then
			tool.Diffuse.Color.Red[ct] = colValues[1]
			tool.Diffuse.Color.Green[ct] = colValues[2]
			tool.Diffuse.Color.Blue[ct] = colValues[3]
		end
		return true -- triggers the counter et al
	end
end

function renameMaterials() -- Rename Material nodes to standard Names
	if cnt == 0 then -- do this for the first loop only!
		if addArgs == "" then
			return "No Material Name selected!"
		end
	end
	
	if tType:match("Mtl") and tType ~= "MtlReflect" then -- is this a Material node?
		newMatName = addArgs .. cnt 
		tool:SetAttrs({TOOLS_Name = newMatName})
		return true -- triggers the counter et al
	end

end

function scaleMeshes()
	if tType:match("SurfaceFBXMesh") then -- is this a 3D Mesh node?
		tool.Size[ct] = tool.Size[ct] * tonumber(addArgs)
		return true -- triggers the counter et al
	end
end

function switchOpenCL()
	if tool.UseOpenCL then -- does this tool actually have an OpenCL option??
		tool.UseOpenCL[ct] = combo
		return true -- triggers the counter et al
	end
end

function removeAllAnimation()
for key,inp in pairs(tool:GetInputList()) do
	if inp:GetConnectedOutput() or inp:GetExpression() then
		if not unbakeable[inp:GetAttrs().INPS_DataType] then
			print("Removing animation from: " .. inp.Name)
			if inp:GetExpression() and itm.valInvert.Checked == false then
				tool[inp.Name]:SetExpression(nil)
				return true
			else
				tool[inp.Name] = nil
				return true
			end
		end
	end
end
	
end

function AlphaPostMultiply() -- Set Loaders to Post Multiply Alpha in the import tab.
	if tool.PostMultiplyByAlpha then
		tool.PostMultiplyByAlpha[ct] = 1
		return true -- triggers the counter et al
	end
end

function setToolsComments() -- Set Comments on tools
	if tool.Comments then
		tool.Comments[ct] = addArgs
		return true -- triggers the counter et al
	end
end

function selectCommentTools() -- Set Comments on tools
	if cnt == 0 and doInv ~= true then -- do this for the first loop only!
		flow:Select() -- deselect all
	end
	if addArgs ~= "" then 
		excl = addArgs
		print(addArgs)
	else
		excl = ".+"
	end
	
	if tool.Comments then
		--if tool.Comments[ct] ~= excl then
		if tool.Comments[ct]:find(excl) then
			flow:Select(tool)
		end
	return true -- triggers the counter et al
	end
end

function shuffleSplineColors()
	for key,inp in pairs(tool:GetInputList()) do
		if inp:GetConnectedOutput() then
			print(inp:GetAttrs().INPS_DataType)
				if inp:GetAttrs().INPS_DataType == "Number" then
					print(inp:GetAttrs().INPS_Name)
					control = inp:GetConnectedOutput():GetTool()
					dump(control:GetAttrs())
					for key2,inp2 in pairs(control:GetInputList()) do
						print(key2)
						if inp2:GetConnectedOutput() then
							dump(inp2:GetConnectedOutput():GetAttrs())
						end
					end
				end
		end
	end
end

function externalScript()
	if fileexists(addArgs) then 
		dofile(addArgs)
	end
end

function bla()
	return "Sweet Geezus! What did you expect? " .. addArgs .."?"
end

function blub()
	return "Empty. As in 'there's nothing in there.'."
end
--------------------------------------------------------------------------------------------------------------------
-- All the shizbang to make this actually work
--------------------------------------------------------------------------------------------------------------------

function argsToTable()
	--print("starting argsToTable")
	argTable = {}
	for value in addArgs:gmatch("([^,]+)") do 
		--print(value)
		table.insert(argTable, tonumber(value))
	end
	return argTable
end

function iconParse(str)
	return string.gsub(str, '[Ii]cons:/', mIcons)
end

-- Return a string with the directory path where the Lua script was run from
-- scriptTable = GetScriptDir()
function getScriptDir()
	return bmd.parseFilename(string.sub(debug.getinfo(1).source, 2))
end

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 600,700

seToolsWin = disp:AddWindow({
  ID = 'seTools',
  WindowTitle = '[se] ScriptScript (Beta 0.8)',
  Geometry = {100, 100, width, height},
  Spacing = 0,
  
  ui:VGroup{
    ID = 'root',
		ui:HGroup{
		Weight = 0.001,
			ui:LineEdit{ID='search', Text = '', PlaceholderText = "search... (currently inactive...:-)",},
		},
		ui:HGroup{
		Weight = 0.5,
			ui:Tree{ID = 'Tree', Weight=0.7, SortingEnabled=true, UpdatesEnabled = true, Events = {ItemDoubleClicked=true, ItemClicked=true, CurrentItemChanged = true,},},  
			ui:VGroup{ Weight = 0.3,
				ui:TextEdit{ID = 'scriptInfo',  Weight = 0.75, IconSize = {128,128}, Text = "Select a Script on the left.", ReadOnly = true,},
				--ui:TextEdit{ID = 'runInfo', Weight = 0.25, Text = " ",  ReadOnly = true,},
				ui:Tree{ID = 'runTree', Weight=0.25, UpdatesEnabled = true, Events = {ItemClicked=true, CurrentItemChanged = true,},},  
				ui:Button{ID = 'butClear', Weight = 0, Text = 'Clear',},
			},
		},
		ui:HGroup{
		Weight = 0,
			ui:LineEdit{ID='addArgs', Weight = 0.7, Text = '', PlaceholderText = "Add any additional arguments here.",},
			ui:ComboBox{ID = 'comboArgs', Weight = 0.3, Text = 'Combo Menu',},
		},
		ui:HGroup{
		Weight = 0,
			ui:CheckBox{ID = 'selOnly', Text = 'Process Selected Tools only',},
			ui:CheckBox{ID = 'valInvert', Text = 'Special Switch',},
		},
		ui:HGroup{
		Weight = 0,
			ui:Button{ID = 'butOkay', Text = 'Run Script',},
		},
		ui:HGroup{
		Weight = 0,
			ui:Label{ID = 'status', Text = 'status', Alignment = {AlignHLeft = true, AlignTop = true},},
		},
	},
})

-- The window was closed
function seToolsWin.On.seTools.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = seToolsWin:GetItems()

-- Add a header row.
itm.Tree:SetHeaderLabels({"Script Name", "Affects", "idx"})
itm.runTree:SetHeaderLabels({"Processed Tools"})

-- hdr = itm.Tree:NewItem()
-- hdr.Text[0] = 'Script Name'
-- hdr.Text[1] = 'Affects'
-- hdr.Text[2] = 'idx'
-- itm.Tree:SetHeaderItem(hdr)



-- Number of columns in the Tree list
itm.Tree.ColumnCount = 2 -- only 2 to hide the index!
itm.runTree.ColumnCount = 1 

-- Resize the Columns
itm.Tree.ColumnWidth[0] = 300
itm.Tree.ColumnWidth[1] = 75

-- add combo stuff
function addComboStuff()
	if type(myScripts[mSelect][5]) == "table" then -- the args could be a table or a string, which need different handling!
		for _, comboItem in pairs(myScripts[mSelect][5]) do
			itm.comboArgs:AddItem(comboItem)
		end
		itm.comboArgs:Show()
		itm.addArgs.Text = myScripts[mSelect][5][1]
	else
		itm.addArgs.Text = myScripts[mSelect][5]
	end
end

function addRunTreeItem(rtItem)
	runRow = itm.runTree:NewItem()
	runRow.Text[0] = rtItem
	itm.runTree:AddTopLevelItem(runRow)
end

-- clear combo
function clearComboStuff()
	itm.comboArgs:Clear()
	itm.addArgs.Text = ""
	--itm.runInfo.Text = ""
	itm.runTree:Clear()
	itm.runTree:SetHeaderLabels({"Processed Tools"})
	itm.status.Text = "status"
	itm.valInvert.Checked = false
	itm.comboArgs:Hide()
end

-- update infos for selected item in tree
function itemUpdate()
	clearComboStuff()
	mIcons = getScriptDir().Path .. [[\icons\]]
	--print(iconParse(myScripts[mSelect][4]))
	--itm.scriptInfo.Text = iconParse(myScripts[mSelect][4]) or [[<h3 align="center">No Info Available</h3>]]
	if myScripts[mSelect][4] ~= nil then
		itm.scriptInfo.Text = iconParse(myScripts[mSelect][4])
	else
		itm.scriptInfo.Text = [[<h3 align="center">No Info Available</h3>]]
	end
	if myScripts[mSelect][5] then -- do we have pre-defined args to add to the combo?
		addComboStuff()
	end
	-- automagically activate "selected only" when there are tools selected
	if #comp:GetToolList(true) > 0 then
		itm.selOnly.Checked = true
	else
		itm.selOnly.Checked = false
	end
	if myScripts[mSelect][7] then
		itm.valInvert.Text = tostring(myScripts[mSelect][7])
	else
		itm.valInvert.Text = "Special Switch"
	end
end

function seToolsWin.On.comboArgs.CurrentIndexChanged(ev)
	--print(itm.comboArgs.CurrentIndex)
	if itm.comboArgs.CurrentIndex ~= -1 then --maybe we just cleared the combo box?
		itm.addArgs.Text = myScripts[mSelect][5][itm.comboArgs.CurrentIndex+1]
	end
end

-- Add an new row entries to the list
for midx, mScript in pairs(myScripts) do
	print(midx)
	itRow = itm.Tree:NewItem()
	-- String.format is used to create a leading zero padded row number like 'Row A01' or 'Row B01'.
	itRow.Text[0] = mScript[1]
	itRow.Text[1] = mScript[2]
	itRow.Text[2] = tostring(midx)
	itRow.Text[3] = ""
	--itRow.CheckState[0] = "Unchecked"
	itRow.Flags = { ItemIsSelectable = true, ItemIsEnabled = true }
	
	if myColors[itRow.Text[1]] then
		local mats = myColors[itRow.Text[1]]
		itRow.TextColor[0] = { R=mats[1], G=mats[2], B=mats[3], A=mats[4] }
		itRow.TextColor[1] = { R=mats[1], G=mats[2], B=mats[3], A=mats[4] }
	end

	itm.Tree:AddTopLevelItem(itRow)
end

--todo: Add History (arrow up / arrow down) on addArgs.Text?  
--todo: Add Dropdown with customizable args?  

-- A Tree view row was clicked on
function seToolsWin.On.Tree.ItemClicked(ev)
	mSelect = tonumber(ev.item.Text[2]) 
	itemUpdate()
end
function seToolsWin.On.Tree.CurrentItemChanged(ev)
	mSelect = tonumber(ev.item.Text[2]) 
	itemUpdate()
end

function seToolsWin.On.runTree.ItemClicked(ev)
	flow:Select()
	local tSelect = tostring(ev.item.Text[0]) 
	flow:Select(comp:FindTool(tSelect))
end

--------------------------------------------------------------------------------------------------------------------
-- The main function loop to step through tools etc
--------------------------------------------------------------------------------------------------------------------
  
function seToolsWin.On.butOkay.Clicked(ev)
	
	-- maybe find out, if there are any tools selected and activate "selected only" automagically?
	
	itm.runTree:Clear()
	-- make sure to get the CURRENT comp! As well as all those nifty Pointers to tools, flow, etc.
	comp = fusion.CurrentComp
	ct = comp.CurrentTime
	tools = comp:GetToolList(itm.selOnly.Checked)
	flow = comp.CurrentFrame.FlowView
	addArgs = tostring(itm.addArgs.Text)
	doInv = itm.valInvert
	combo = itm.comboArgs.CurrentIndex

	myFunc = myScripts[mSelect][3] -- [3] is the (hidden) index of the row. Needed to allow sorting of the Tree while still getting the correct...well...index...:-)

	runInfo = "[" .. myFunc .. "]"
	--addRunTreeItem("[" .. myFunc .. "]")
	
	if itm.selOnly.Checked == true then
		--print('Selected only is checked!')
	end

	-- find the actual function to run from the myScripts table:
	
	--print("[Running] " .. myFunc)
	
	if myFunc ~= "externalScript" then -- External Scripts run their own loop!
	
	comp:StartUndo("se_ScriptScript")
	comp:Lock()
	cnt = 0
	ntools = #tools

	for i, v in pairs(tools) do
		tType = v:GetAttrs().TOOLS_RegID 
		tName = v:GetAttrs().TOOLS_Name 
		tool = v

		itm.status.Text = "Modifying " .. tName .. " (tool " .. cnt .. " of " .. ntools .. ")"

		-- now call the actual function!!! "doIt" can actually be used to catch return values.
		doIt = getfenv()[myFunc]()
		if doIt == true then
			cnt = cnt + 1
			runInfo = runInfo .."\n  " .. tName
			addRunTreeItem(tName)
			--itm.runInfo.Text = runInfo
			doIt = false
		end
	end

	runInfo = runInfo .."\n[End]"
	--itm.runInfo.Text = runInfo
	if doIt then
		itm.status.Text = doIt
	else
		itm.status.Text = "Processed " .. cnt .. " out of " .. ntools .. " tools."
		itm.runTree:SetHeaderLabels({"Processed Tools (" .. cnt .. ")"})
	end
	
	--print(doIt)
	--itm.status.Text = doIt
	
	comp:Unlock()
	comp:EndUndo(true)
	
	else
		print("Going out...")
		externalScript()
	end 
end

function seToolsWin.On.butClear.Clicked(ev)
	--itm.runInfo.Text = ""
	itm.runTree:Clear()
	itm.addArgs.Text = ""
end

-- search function
--[[
function seToolsWin.On.search.TextChanged(ev)
	g_FilterText = ev.Text
	itm.search.Text = (g_FilterText == "") and "\xF0\x9F\x94\x8D" or "\xF0\x9F\x97\x99"
	--PopulateAtomTree(itm.AtomTree)
end
--]]

-- A Tree view row was double clicked on
function seToolsWin.On.Tree.ItemDoubleClicked(ev)
  --print('[Double Clicked] ' .. tostring(ev.item.Text[0]))
  itm.status.Text = "Stop that pointless double clicking on [" .. tostring(ev.item.Text[0]) .. "]"
  itm.TextColor[0] = { R=1, G=0.8, B=0.8, A=1 }
  itRow.CheckState[0] = "Checked"
end

--dump(getScriptDir())
-- and here we finally go with the main loop!
itm.comboArgs:Hide()

seToolsWin:Show()
disp:RunLoop()
seToolsWin:Hide()
