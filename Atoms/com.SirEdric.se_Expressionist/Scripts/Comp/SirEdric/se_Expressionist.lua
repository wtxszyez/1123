--[[

TODO:
	- Add field to do Increments per Control
	- Check if Expression matches convention for DataType (Text, Number, Point,...)

	
Done:
	- Transform1.Angle*20 does not evaluate as being connected to Transform1.Angle (creates recursive link!!!)
	- Option for Expression / Set Value
	- For increments, sort tool table by TOOLS_Name	
		
--]]--


hint = [[Do you like this Script? Why not buy me a coffee (or two)?
It's easy. Just visit https://www.paypal.me/siredric
Thanks.]]

_VERSION = 0.75
  
tools = comp:GetToolList(true) -- table of selected Tools in the comp!
numTools = #tools
flow = comp.CurrentFrame.FlowView
ct = comp.CurrentTime
commonControls={}
cntInp = 0
myItems = {}
myTypes = {}
myAnims = {}
typeFilter = "All"
--oriOp = {{"Discard", ""}, {"Add", "+"}, {"Subtract", "-"}, {"Multiply", "*"}, {"Divide", "/"}}
sortOp = {"None", "Name Ascending", "Name Descending", "Flow Pos Y BottomUp", "Flow Pos Y TopDown", "Flow Pos X LeftRight", "Flow Pos X RightLeft"} 

---------------------------------------------------------------------------------[ /GUI ] -------------------------------------
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 750,400

-- Create an "About Window" dialog. Courtesy from Andrew Hazelden 'http://www.andrewhazelden.com/blog/'
function AboutWindow()
	local disp2 = bmd.UIDispatcher(ui)
  --local URL = 'https://www.fusiontrainer.com/'
  local URL = 'https://www.paypal.me/siredric'
  local aboutText = [[This script adds Expressions to any Number of Tools and Inputs.
Therefore it first checks the selected Tools for Inputs they have in Common and displays those in a treeview.
From there the desired Inputs can be selected and the Expression is applied to them.]]
  local width,height = 500,250
  win2 = disp2:AddWindow({
    ID = "AboutWin",
    WindowTitle = 'About se_Expressionist v'.._VERSION,
    WindowFlags = {Window = true, WindowStaysOnTopHint = true,},
    Geometry = {200, 200, width, height},

    ui:VGroup{
      ID = 'root',
      
      -- Add your GUI elements here:
      ui:TextEdit{ID = 'AboutText', ReadOnly = true, Alignment = {AlignHCenter = true, AlignTop = true}, HTML = '<h1>se_Expressionist</h1>\n<p>' .. aboutText .. '</p>\n<p>Copyright &copy; 2018 Eric "SirEdric" Westphal.</p>',},
      
      ui:VGroup{
        Weight = 0,

        ui:Label{
          ID = "URL",
          Text = 'Wanna buy me a coffee?: <a href="' .. URL .. '">' .. URL .. '</a>',
          Alignment = {AlignHCenter = true, AlignTop = true,},
          WordWrap = true,
          OpenExternalLinks = true,},
    
        ui:Label{
          ID = "EMAIL",
          Text = 'Any questions?: <a href="' .. 'mailto:eric@siredric.de?subject=se_Expressionist&body=Hi. I totally love this script, but...' .. '">' .. 'eric@siredric.de' .. '</a>',
          Alignment = {AlignHCenter = true, AlignTop = true,},
          WordWrap = true,
          OpenExternalLinks = true,},
      },
    },
  })

  -- Add your GUI element based event functions here:
  itm2 = win2:GetItems()

  -- The window was closed
  function win2.On.AboutWin.Close(ev)
    disp2:ExitLoop()
  end

  win2:Show()
  disp2:RunLoop()
  win2:Hide()

  return win2,win2:GetItems()
end

win = disp:AddWindow({
  ID = 'wAddSuffix',
  WindowTitle = 'se_Expressionist v' .. _VERSION,
  Geometry = {100, 100, width, height},
  Spacing = 0,
  
  ui:VGroup{
    ID = 'root',
	ui:HGroup{
		Weight = 0.01,
			--ui:CheckBox{ID = 'selOnly', Text = 'Process Selected Tools only', Checked = true},
			--ui:VGap(1),
			-- ui:Label{ID = 'Label6', Text = 'Original Value', Weight = 0.01},
			-- ui:ComboBox{ID = 'oriVal', Text = 'Combo Menu', Weight = 0.01},
			--ui:HGap(1),
			ui:Label{ID = 'Label7', Text = 'Sort Tools by', Weight = 0.01},
			ui:ComboBox{ID = 'sortSel', Text = 'Combo Menu'},
			ui:HGap(2),
			ui:CheckBox{ID = 'doInfo', Text = 'Store Original Values', Checked = true, Weight = 0.01},
			ui:VGap(0.1),
	},
	ui:HGroup{
		Weight = 0,
			ui:Label{ID = 'Label3', Text = 'Filter List by Data Type', Weight = 0.01},
			ui:ComboBox{ID = 'dTypeCombo', Text = 'Combo Menu',},
	},
	ui:VGap(3),
	ui:HGroup{
		Weight = 0.05,
		ui:VGroup{
			--ui:Label{ID = 'Label1', Text = 'Select the Controls to add an Expression to.', Alignment = {AlignHCenter = true, AlignTop = true},},
			ui:Label{ID = 'Label1', Text = 'Select the Controls to add an Expression to. DoubleClick to copy Input Name.', Weight = 0.01},
			ui:Tree{ID = 'Tree', SortingEnabled=true, Events = {ItemDoubleClicked=true, ItemClicked=true},},
			ui:HGroup{Weight = 0.01,
				ui:LineEdit{ID='addCtrl', Weight = 0.8, Text = '', PlaceholderText = "Alternatively type Controls here (Transform3DOp.Translate.X, Transform3DOp.Translate.Y,...) Will override above selections.",},
				ui:Button{ID = 'butClear', Weight = 0.01, Text = 'Clear', Enabled = true},
			},
		},
	},
		
	ui:VGap(3),
	ui:HGroup{
		Weight = 0,
			ui:VGroup{
			ui:Label{ID = 'Label2', Text = 'Type Expression here. Use "$current" to keep the current value.'},
			ui:LineEdit{ID='addExp', Weight = 0.7, Text = '', PlaceholderText = 'e.g. $current + myTool.myControl - 5 + $1 / $2',},
			},
		},
	ui:HGroup{
		Weight = 0,
			ui:Label{ID = 'Label4', Text = 'Increment 1 ($1)', Weight = 0.01},
			ui:LineEdit{ID='inc1', Weight = 0.5, Text = '', PlaceholderText = "number",},
			ui:HGap(3),
			ui:Label{ID = 'Label5', Text = 'Increment 2 ($2)', Weight = 0.01},
			ui:LineEdit{ID='inc2', Weight = 0.5, Text = '', PlaceholderText = "number",},
			ui:HGap(3),
			ui:Label{ID = 'Label6', Text = 'Increment 3 ($3)', Weight = 0.01},
			ui:LineEdit{ID='inc3', Weight = 0.5, Text = '', PlaceholderText = "number",},
		},
	ui:HGroup{
		Weight = 0,
			ui:Button{ID = 'butOkay', Text = 'Run Script', Enabled = true},
			ui:Button{ID = 'butUndo', Text = 'Undo', Enabled = true},
			ui:Button{ID = 'butAbout', Text = 'About', Enabled = true},
			ui:Button{ID = 'butCncl', Text = 'Close', Enabled = true},
		},
  },
})

-- The window was closed
function win.On.wAddSuffix.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- for _, op in pairs(oriOp) do
	-- itm.oriVal:AddItem(op[1])
-- end

for _, op in pairs(sortOp) do
	itm.sortSel:AddItem(op)
end

function win.On.butCncl.Clicked(ev)
	disp:ExitLoop()
end

function win.On.butUndo.Clicked(ev)
	comp:Undo()
end

function win.On.butAbout.Clicked(ev)
	AboutWindow()
end

function win.On.butClear.Clicked(ev)
	itm.addCtrl.Text = ""
end

function win.On.dTypeCombo.CurrentIndexChanged(ev)
	typeFilter = itm.dTypeCombo.CurrentText
	print('Filter [' .. typeFilter .. ']')
	UpdateTree()
end

function win.On.oriVal.CurrentIndexChanged(ev)
	local oriOp = itm.oriVal.CurrentText
	local oriIdx = itm.oriVal.CurrentIndex
	local oriIdx2 = itm.oriVal.Index or "bla"
	print('Selected: [' .. oriOp .. '] - Index: ' .. oriIdx .. '] - Index2: ' .. oriIdx2 )
--	UpdateTree()
end

function win.On.sortSel.CurrentIndexChanged(ev)
	--sortOp = {"None", "Name Ascending", "Name Descending", "Flow Pos Y BottomUp", "Flow Pos Y TopDown", "Flow Pos X LeftRight", "Flow Pos X RightLeft"} 
	sIdx = itm.sortSel.CurrentIndex
	print(sIdx)
	if sIdx == 1 then
		sortAscending()
	elseif sIdx == 2 then
		sortDescending()
	elseif sIdx == 3 then
		sortPosDescending("Y")
	elseif sIdx == 4 then
		sortPosAscending("Y")
	elseif sIdx == 5 then
		sortPosAscending("X")
	elseif sIdx == 6 then
		sortPosDescending("X")
	else
		tNamesSorted = tNames
		print("Unsorted")
		dump(tNamesSorted)
	end
--	UpdateTree()
end

function win.On.Tree.ItemDoubleClicked(ev)
    print(ev.item.Text[0])
	if itm.addCtrl.Text == "" then
		itm.addCtrl.Text = ev.item.Text[0]
	else
		itm.addCtrl.Text = itm.addCtrl.Text .. "," .. ev.item.Text[0]
	end
end

function splitArgs(bla)
	myAnims = {}
	ctrls = bmd.split(bla, ",")
	for n, ctrl in pairs(ctrls) do
		print("[" .. ctrl .. "]")
		table.insert(myAnims, ctrl)
	end
end

function storeValues()


end

function sortAscending()
	table.sort(tFull, function(a, b) return a["name"] < b["name"] end)
	fillNameTable()
	-- print(sortOp[sIdx])
	-- dump(tNamesSorted)
end

function sortDescending()
	table.sort(tFull, function(a, b) return a["name"] > b["name"] end)
	fillNameTable()
	-- print(sortOp[sIdx])
	-- dump(tNamesSorted)
end

function sortPosDescending(axis)
	table.sort(tFull, function(a, b) return a["pos"..axis] > b["pos"..axis] end)
	fillNameTable()
	-- print(sortOp[sIdx])
	-- dump(tNamesSorted)
end

function sortPosAscending(axis)
	table.sort(tFull, function(a, b) return a["pos"..axis] < b["pos"..axis] end)
	fillNameTable()
--	print(sortOp[sIdx])
--	dump(tNamesSorted)
end

function fillNameTable()
	if sIdx == nil then sIdx = 0 end
	tNamesSorted = {}
	for t, tool in pairs(tFull) do
		tNamesSorted[t] = tool["name"]
	end
	print("Sorting by: " .. sortOp[sIdx+1])
	dump(tNamesSorted)
end

function sortTools()
	tNames = {}
	tFull = {}
	for t, tool in pairs(tools) do
		posX, posY = flow:GetPos(tool)
		tNames[t] = tool:GetAttrs().TOOLS_Name
		tFull[t] = {["name"] = tool:GetAttrs().TOOLS_Name, ["posX"] = posX, ["posY"] = posY }
	end
	fillNameTable()
	print("Unsorted:")
	dump(tNamesSorted)
end

function buildTree()
	-- Add a header row
	hdr = itm.Tree:NewItem()
	hdr.Text[0] = 'Common animatable Inputs on selected Tools'
	hdr.Text[1] = 'Name'
	hdr.Text[2] = 'Data Type'
	hdr.Text[3] = 'anim'
	itm.Tree:SetHeaderItem(hdr)

	-- Number of columns in the Tree list
	itm.Tree.ColumnCount = 4

	-- Resize the Columns
	itm.Tree.ColumnWidth[0] = 300
	itm.Tree.ColumnWidth[1] = 200
	itm.Tree.ColumnWidth[2] = 100
	itm.Tree.ColumnWidth[3] = 100
end

function UpdateTree()
	-- Clean out the previous entries in the Tree view
	itm.Tree:Clear()
	myItems = {}
	
    for i, inp in pairs(commonControls) do
		if inp[2] == typeFilter or typeFilter == "All" then
			itRow = itm.Tree:NewItem(); 
			--print(i)
			itRow.Text[0] = i
			itRow.Text[1] = inp[1]
			itRow.Text[2] = inp[2]
			itRow.Text[3] = inp[4]
			itRow.CheckState[0] = "Unchecked"
			itm.Tree:AddTopLevelItem(itRow)
			
			--curItem = itm.Tree:AddTopLevelItem(itRow)
			table.insert(myItems, itRow)
			--dump(curItem)
		end
    end  
end

function updateCombo()
	itm.dTypeCombo:AddItem("All")
	for ty, val in pairs(myTypes) do
		itm.dTypeCombo:AddItem(ty)
	end
end


function findCommonControls()
	for n, tool in pairs(tools) do
		nodeInps = tool:GetInputList()
		nodeName = tool:GetAttrs().TOOLS_Name
		print('Input Controls: ' .. nodeName)
		
		-- first, find all animatable inputs on the tool
		for i, inp in pairs(nodeInps) do
			if inp:GetAttrs().INPB_External == true then --animatable only!
				curID = inp:GetAttrs().INPS_ID
				curName = inp:GetAttrs().INPS_Name
				curType = inp:GetAttrs().INPS_DataType
				curAnim = ""
				-- TODO check for existing expressions and show in dialogue?
				-- :GetExpression()
				-- s1.Transform3DOp.Rotate.Y:GetConnectedOutput():GetTool():GetAttrs().TOOLS_RegID
				if inp:GetExpression() then
					curAnim = "Expression"
				elseif inp:GetConnectedOutput() then
					curAnim = inp:GetConnectedOutput():GetTool():GetAttrs().TOOLS_RegID
				end
				-- add a counter for the control ID. 
				-- only if this counter equals the number of selected tools in the end,
				-- the control is available on all selected!
				if commonControls[curID] == nil then
					commonControls[curID] = {curName, curType, 1, curAnim}
				else
					cntTemp = commonControls[curID][3]
					commonControls[curID][3] = cntTemp + 1
				end
			end
		end
	end
	print('[Done]')
--	dump(commonControls)
	-- filter out all non-common controls
	for n, control in pairs(commonControls) do
		if control[3] ~= numTools then
			print(n .. "is not common")
			commonControls[n] = nil
		else
			if myTypes[control[2]] == nil then
				--table.insert(myTypes, control[2])
				myTypes[control[2]] = true
			end
		end
	end
	--dump(commonControls)
	updateCombo()
	UpdateTree()
end

function isItemChecked()
	myAnims = {}
	for n, item in pairs(myItems) do
		if item.CheckState[0] == "Checked" then
			print("Item " .. item.Text[0] .. " is selected")
			table.insert(myAnims, item.Text[0])
		end
	end
end

function expressionSuffix()
	for n, tool in pairs(tools) do
		for _, ctrl in pairs(ctrls) do
			if tool[ctrl] then
				curVal = tonumber(tool[ctrl][ct])
				curExp = curVal .. inExp
				--print("Control: [" .. ctrl .. "] Value: [" .. curVal .. "] Exp: [" .. curExp .. "]")
				tool[ctrl]:SetExpression(curExp)
				if itm.doInfo.Checked == true then
					curComm = tool.Comments[ct]
					tool.Comments[ct] = curComm .. "\n" .. ctrl .. "=" .. curVal
				end
			end
		end
	end
end

function expressionSuffix2()
	--local oriIdx = itm.oriVal.CurrentIndex 
	oriIdx = 0
	print('Original Value Index: ' .. oriIdx )
	-- for n, tool in pairs(tools) do -- uses unsorted tool array
	for n, tName in pairs(tNamesSorted) do -- uses SORTED tool-names array
		tool = comp:FindTool(tName)
		modExp = inExp:gsub("$1", var1 * n)
		modExp = modExp:gsub("$2", var2 * n)
		modExp = modExp:gsub("$3", var3 * n)
		print("modExp: " .. modExp)
		for _, ctrl in pairs(myAnims) do
			print("ctrl: " .. ctrl)
			if tool[ctrl] then
				local curName = tool:GetAttrs().TOOLS_Name
				
				-- somehow make sure that a control is not referenced to itself on the master tool
				local expCheck = curName .. "." .. ctrl
				print(expCheck .. " vs " .. inExp)
				
				--if expCheck ~= inExp then
				if not inExp:find(expCheck) then
					curVal = tonumber(tool[ctrl][ct])
					-- add option to completely override the current value!
					if curVal == nil then curVal = 0 end
					print("Current Value: [" ..curVal .. "]")
					curExp = modExp:gsub("$current", curVal) -- we don't need oriIdx anymore!
					--if itm.valAdd.Checked == true then
					if oriIdx ~= 0 then
						print("Using Original Value with Operator [" .. oriOp[oriIdx+1][2] .. "]")
						curExp = curVal .. oriOp[oriIdx+1][2] .. modExp
					end
					
					
					--print("Control: [" .. ctrl .. "] Value: [" .. curVal .. "] Exp: [" .. curExp .. "]")
					
					tool[ctrl]:SetExpression(curExp)
					if itm.doInfo.Checked == true then
						curComm = tool.Comments[ct]
						-- tool.Comments[ct] = curComm .. "\n" .. ctrl .. "=" .. curVal
						tool.Comments[ct] = ctrl .. "=" .. curVal .. "\n"
					end
				else
					print("POSSIBLE CROSS REFERENCE! Can't connect Control to itself.")
				end
			end
		end
	end
end

function win.On.butOkay.Clicked(ev)
	comp:StartUndo("AddExpressionSuffix")

	inCtrl = itm.addCtrl.Text
	inExp = itm.addExp.Text
	var1 = tonumber(itm.inc1.Text) or 0
	var2 = tonumber(itm.inc2.Text) or 0
	var3 = tonumber(itm.inc3.Text) or 0
	print("vars: " .. var1, var2, var3)
	
	if inCtrl ~= "" then
		splitArgs(inCtrl)
	else
		isItemChecked()
	end

	expressionSuffix2()
	
	comp:EndUndo(true)
end


buildTree()

findCommonControls()

sortTools()

win:Show()
disp:RunLoop()

win:Hide()

print(hint)
