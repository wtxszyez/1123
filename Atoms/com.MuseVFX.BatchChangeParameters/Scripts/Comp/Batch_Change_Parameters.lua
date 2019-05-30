-- Batch Change Parameters v2.0 for Fusion 9

-- Changes parameters for multiple selected tools simultaneously. The tools need not be of the
-- same type, but only Inputs that they have in common can be changed.

-- Concept by Gringo
-- v1.0 by SlayerK, 2007/02/22
-- v2.0 by Bryan Ray for MuseVFX

-- Change Log:
	-- v2.0, 2018-01-22, updated for Fusion 9 and UI Manager. Cleaned code and added documentation.
	--		Removed orphan and redundant functions. Removed un-implemented math operations code.
	-- v1.0, 2007-02-22, initial release

-- Development Roadmap:
--		Add option for performing arithmetic on the Inputs. For instance, add 0.3 to the current
--			value of each Input. 

-- /////////////////////
-- / Utility Functions /
-- /////////////////////

-- Clears Modifiers from a list of tools. allToolsNames is a global table containing a list of
-- all Tools available in Fusion.
function clearModifiers(tbl)
	local out = {}
	for i = 1, table.getn(tbl) do
		if bmd.isin(allToolsNames, tbl[i]:GetAttrs().TOOLS_RegID) then
			table.insert(out, tbl[i])
		end
	end
	return out
end

-- Finds the tool in the supplied list with the smallest number of Inputs and returns that tool's index.
function getMin(tbl)
	if table.getn(tbl)==0 then
		return(-1) -- If there are no items in the table, throw an error.
	end
	
	local minTool = 0
	local minInputs = math.huge
	numInputs = 0
	
	for i=1, table.getn(tbl) do
		numInputs = table.getn(tbl[i]:GetInputList())
		if numInputs<minInputs then
			minTool=i
			minInputs=numInputs
		end
	end
	return minTool
end

-- Returns a table containing a list of a tool's inputs' types, ids and names.
function getInputInfo(tool)
	local tbl = tool:GetInputList()
	local out = {}
	local attrs = {}
	local name = ""
	local iID = ""
	local iType = ""
	for i, j in ipairs(tbl) do
		attrs = j:GetAttrs()
		name = attrs.INPS_Name
		iID = attrs.INPS_ID
		iType = attrs.INPS_DataType
		if (attrs.INPB_Passive == false) and (bmd.isin(supp_types, iType) == true) then
			table.insert(out, {tp=iType, id=iID, nm=name})
		end
	end
	return out
end


-- Compares the entries in two tables and returns a table containing all entries that are in both.
-- Look into generalizing this function.
function intersect(tblA, tblB)
	if type(tblA)~="table" then
		return nil
	end
	
	local out = {}
	for i = 1, table.getn(tblB) do
		flag = false
		for j = 1, table.getn(tblA) do
			if(tblB[i].id == tblA[j].id) and (tblB[i].nm == tblA[j].nm) and (tblB[i].tp == tblA[j].tp) then
				flag = true
			end
		end
		if flag == true then
			table.insert(out, tblB[i])
		end
	end
		
	return out
end

-- tools is a global table. Returns the contents in string form of the chosen parameter. If the
-- current value of all selected tools is not identical, returns "?" instead. Used to pre-fill
-- the Value text entry field.
function getParameter(pID)
	local new = 0
	local inputNumber = getInputNumber(pID, tools[1])
	local value = tools[1]:GetInputList()[inputNumber][comp.CurrentTime]
	
	for i = 2, table.getn(tools) do
		inputNumber = getInputNumber(pID, tools[i])
		new = tools[i]:GetInputList()[inputNumber][comp.CurrentTime]
		if compareValues(new, value) == false then
			return "?"
		end
	end
	
	if type(value) == "number" then
		return tostring(value)
	end
	
	if type(value) == "table" then
		return value
	end
	
	if type(value) == "string" then
		return value
	end
	
	return "?"
end
	
-- Given information about an input and a tool, returns the index of an input matching the info.
function getInputNumber(inputInfo, tool)
	local inputs = {}
	inputs = tool:GetInputList()
	local attrs
	for i,j in ipairs(inputs) do
		attrs = j:GetAttrs()
		if (attrs.INPS_Name == inputInfo.nm) and
			(attrs.INPS_ID == inputInfo.id) and
			(attrs.INPS_DataType == inputInfo.tp) then
			return i
		end
	end
	return -1
end

-- Compares two values. If they are identical, returns true. Otherwise, returns false.
function compareValues(v1,v2)
	if type(v1) ~= type(v2) then
		return false
	end
	
	if (type(v1)=="number") or (type(v1)=="string") then
		return (v1==v2)
	end
	
	if type(v1)=="table" then
		for i=1, table.getn(v1) do
			if v1[i] ~= v2[i] then
				return false
			end
		end
		return true
	end
	return false
end


-- /////////////////////
-- /    UI Manager     /
-- /////////////////////

-- Set up UI Manager
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,200

-- Define the Window
win = disp:AddWindow({
	ID = 'BCWin',
	WindowTitle = 'Batch Parameter Changer',
	Geometry = {800,200,600,340},
	Spacing = 10,
	
	ui:VGroup{
		ID = 'root',
		Weight = 1.0,
		ui:HGroup{
			Weight = 0,
			ui:Label{
				ID = 'paramLabel',
				Text = 'Choose Parameter:',
				Weight = 0,
			},
		},
		ui:VGap(3),
		ui:HGroup{
			Weight = 0,
			ui:HGap(53),
			ui:ComboBox{
				ID = 'Parameter',
				Text = 'Choose Parameter',
				Weight = 1,
			},
		},
		ui:VGap(30),
		ui:HGroup{
			Weight = 0,
			ui:Label{
				ID = 'setLabel',
				Text = 'Set To:',
			},
		},
		ui:VGap(10),
		ui:HGroup{
			Weight = 0,
			ui:Label{
				ID = 'dataTypeLabel', 
				Text = 'dataType', 
				Weight = 0, 
				Visible = true,
			},
			ui:LineEdit{
				ID = 'textFld',
				Text = 0,
				Visible = true,
			},
		},
		ui:HGroup{
			Weight = 0,
			ui:HGap(53),
			ui:ComboBox{
				ID = 'listFuID',
				Text = '',
				Weight = 1,
				Visible = true,
			},
		},
		ui:HGroup{
			Weight = 0,
			ui:HGap(36),
			ui:Label{
				ID = 'xlabel',
				Text = 'X:',
				Visible = true,
				Weight = 0.05,
			},
			ui:LineEdit{
				ID = 'cordX',
				Text = '0.5',
				Visible = true,
				Weight = 1,
			},
			ui:HGap(20),
			ui:Label{
				ID = 'ylabel',
				Text = 'Y:',
				Visible = true,
				Weight = 0.05,
			},
			ui:LineEdit{
				ID = 'cordY',
				Text = '0.5',
				Visible = true,
				Weight = 1,
			},
		},
		ui:VGap(30),
		ui:HGroup{
			ui:Button{
				ID = 'btn_set',
				Text = 'Apply',
				Weight = 1,
			},
		},
	},
	
})

-- The window was closed
function win.On.BCWin.Close(ev)
  disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems() -- Collects a list of fields in the GUI

-- When an entry is chosen in the Parameter combo box, change the data type label and pre-fill
-- the appropriate data entry field with the current value of the chosen Input, if it's identical
-- on all controls. If it is not, insert "?". Toggle Visible attributes to configure the UI.
function win.On.Parameter.CurrentIndexChanged(ev)
	local index = itm.Parameter.CurrentIndex + 1
	local currentValue = getParameter(controls[index])
	local dataType = controls[index].tp
	local xVal, yVal
	local id = controls[index].id
	
	itm.dataTypeLabel.Text = dataType
	
	if dataType == "Point" then
		if currentValue == "?" then
			currentValue = {"?", "?"}
		else
			xVal = currentValue[1]
			yVal = currentValue[2]
		end
		
		itm.textFld.Visible = false
		itm.listFuID.Visible = false
		itm.xlabel.Visible = true
		itm.ylabel.Visible = true
		itm.cordX.Visible = true
		itm.cordY.Visible = true
		itm.cordX.Text = tostring(xVal)
		itm.cordY.Text = tostring(yVal)
		
	elseif dataType == "FuID" then
		itm.textFld.Visible = false
		itm.listFuID.Visible = true
		itm.xlabel.Visible = false
		itm.ylabel.Visible = false
		itm.cordX.Visible = false
		itm.cordY.Visible = false
		
		itm.listFuID:Clear()
		
		fuIDAttrs = tools[1][id]:GetAttrs()
		inputControlType = string.gsub(fuIDAttrs.INPID_InputControl, "ID", "")
		controlID = "INPIDT_"..inputControlType.."_ID"
		fuIDlist = tools[1][id]:GetAttrs()[controlID]
		
		for i = 1, table.getn(fuIDlist) do
			itm.listFuID:AddItem(fuIDlist[i])
		end
		
	else
		itm.textFld.Visible = true
		itm.listFuID.Visible = false
		itm.xlabel.Visible = false
		itm.ylabel.Visible = false
		itm.cordX.Visible = false
		itm.cordY.Visible = false
		
		itm.textFld.Text = currentValue
	end
	
end

-- When the Apply button is clicked, set the chosen Parameter on each selected tool. This button
-- does not close the GUI.
function win.On.btn_set.Clicked(ev)
	-- Identify the parameter to be changed, get its datatype and ID.
	local index = itm.Parameter.CurrentIndex + 1
	local dataType = controls[index].tp
	local id = controls[index].id
	
	-- Loop through each entry in the selected tools list.
	for i, j in ipairs(tools) do
	
		--Selection based on dataType
		if dataType == "Number" then
			--Get the user-supplied new value
			local newValue = itm.textFld.Text
			--Check it for valid type
			if tonumber(newValue)==nil then
				print("Entered data is not a Number")
				return
			end
			--Set the chosen input
			j[id][comp.CurrentTime] = tonumber(newValue)
		end
		
		--Second verse, same as the first, except we don't need to validate the data type.
		if dataType == "Text" then
			local newValue = itm.textFld.Text
			j[id][comp.CurrentTime] = newValue
		end
		
		--Points are a 3 dimensional value (though the Z value is 
		--very rarely addressed), so we use a table to hold it.
		if dataType == "Point" then
			local newValue = {}
			newValue[1] = tonumber(itm.cordX.Text)
			newValue[2] = tonumber(itm.cordY.Text)
			newValue[3] = 0
			local errFlag = 0
			if tonumber(itm.cordX.Text) == nil then
				print("X Coordinate data is not a Number")
				errFlag = 1
			end
			if tonumber(itm.cordY.Text) == nil then
				print("Y Coordinate data is not a Number")
				errFlag = 1
			end
			if errFlag == 1 then
				return
			end
			j[id][comp.CurrentTime] = newValue
		end
		
		--The combo box uses a different attribute to hold its current
		--value, but it's otherwise just like the others. No need to test
		--for valid input since that's enforced by the box itself.
		if dataType == "FuID" then
			local newValue = itm.listFuID.CurrentText
			j[id][comp.CurrentTime] = newValue
		end
	end
end

-- //////////////////////////////////
-- /           MAIN CODE            /
-- //////////////////////////////////
function main()
	allTools = {}
	allToolsNames = {}

	-- Get a list of all the tools in Fusion's registry
	if globals.__addtool_data then
		allTools = globals.__addtool_data
	else
		allTools = fu:GetRegSummary(CT_Tool)
		globals.__addtool_data = allTools
	end

	-- Make a new list containing the REGS_ID of all tools that have all three of name, OpIcon and ID.
	for i,v in ipairs(allTools) do
		if v.REGS_Name~=nil and v.REGS_OpIconString~=nil and v.REGS_ID~=nil then
			table.insert(allToolsNames, v.REGS_ID)
		end
	end

	supp_types = {"Number", "FuID", "Point", "Text",}	-- DataTypes supported by this script.
	tools = comp:GetToolList(true)						-- List of user-selected tools
	tools = clearModifiers(tools)						-- Removes Modifiers from the tool list.
	seen={}												-- Holds a list of tool REGIDs detected in the tools list
														--		Filters the list for efficiency when building 
														--		the Parameters table.

	-- If fewer than two tools are selected, throw an error.
	if table.getn(tools) < 2 then
		comp:AskUser("You must select more than one tool.\nAborting.", {})
		print("You must select more than one tool.")
		return 0
	end

	-- Get the index of the tool with the smallest number of inputs
	minEntry = getMin(tools)

	-- Get a list of the inputs in that tool. 
	controls = getInputInfo(tools[minEntry])

	-- Add the tool type to the seen table
	table.insert(seen, tools[minEntry]:GetAttrs().TOOLS_RegID)

	-- Remove the tool from the tool list so it won't be reprocessed
	table.remove(tools, minEntry)

	-- Pare down the inputs in the controls table to the inputs common to all selected tools.
	while (table.getn(tools)>0) do 	-- Loop as long as at least one tool remains in the table. 
									-- This loop always processes the tool at index 1 of the tools table.
		-- Check to see if the current tool's RegID has already been processed.
		if bmd.isin(seen, tools[1]:GetAttrs().TOOLS_RegID) == false then
			-- Add the RegID to the seen table
			table.insert(seen, tools[1]:GetAttrs().TOOLS_RegID)
			-- Get info about the tool's Inputs
			iInfo = getInputInfo(tools[1])
			-- Remove any inputs that are not already present in controls
			controls = intersect(controls, iInfo)
		end
		-- Remove the current tool from the list. getn() will be reduced by 1. When no tools remain,
		-- the loop will break.
		table.remove(tools, 1)
	end

	-- If no inputs remain in the controls table, the selected tools have no controls in common.
	-- Throw an error.
	if table.getn(controls) == 0 then
		composition:AskUser("No Common Inputs. Aborting.", {})
		print("No common inputs.")
		return 0
	end

	-- Alphabetize the controls table.
	table.sort(controls, function(a,b) return (b.nm > a.nm) end)

	-- Populate the Parameter combo box
	for i = 1, table.getn(controls) do
		itm.Parameter:AddItem(controls[i].nm)
	end

	-- Repopulate the tool list
	tools = comp:GetToolList(true)
	tools = clearModifiers(tools)
	
	return 1

end

-- Fill the Parameter combo box and acquire the tool list.
status = main()

if status == 1 then -- Check for successful execution of main function
	-- Activate the window
	win:Show()
	disp:RunLoop()
	win:Hide()
end