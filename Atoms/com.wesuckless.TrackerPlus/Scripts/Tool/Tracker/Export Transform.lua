--[[

Tracker Plus - Export Transform.lua
http://www.steakunderwater.com/wesuckless/viewtopic.php?f=6&t=1192
20171123 - Pieter Van Houte (pieter[at]secondman[dot]com)

--]]

--[[

based on work by

-- Stefan Ihringer <stefan@bildfehler.de>
-- Isaac Guenard
-- Sean Konrad
-- Michael Vorberg
-- possibly others :)

--]]

-- THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
-- THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
-- DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
-- UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 

-- settings to use for later

local RENAME = true
local COLORED = 1
local LINKEDCOLOUR = {bg = {R=40/255, G=80/255, B=120/255}, fg = {R=200/255, G=200/255, B=200/255}}
local BAKEDCOLOUR = {bg = {R=20/255, G=100/255, B=60/255}, fg = {R=200/255, G=200/255, B=200/255}}

-- first check if a Tracker is selected

local flow = composition.CurrentFrame.FlowView
if not comp.ActiveTool then
	print ("Please make sure Tracker is selected...")
	return
end
local tracker = comp.ActiveTool
if tracker:GetAttrs().TOOLS_RegID ~= "Tracker" then
	print ("Please select a Tracker...")
	return
end

-- read some settings from the tracker

local posdefault = tracker.Position[fu.TIME_UNDEFINED]
local rotdefault = tracker.Rotation[fu.TIME_UNDEFINED]
local scadefault = tracker.Scaling[fu.TIME_UNDEFINED]

local ret = comp:AskUser("Select Transform Export Options :", { 
	{"XFType", Name = "Operation", "Dropdown", Options = {"Matchmove","Stabilize"} },
	{"ExType", Name = "Type", "Dropdown", Options = {"Linked","Baked"} },
	{"Position", "Checkbox", Default = posdefault, NumAcross=2},
	{"Rotation", "Checkbox", Default = rotdefault, NumAcross=2},
	{"Scaling", "Checkbox", Default = scadefault, NumAcross=2},
	{"Axis", "Checkbox", Default = 1, NumAcross=2},
	})

	if ret == nil then
		return
	end

composition:Lock()
comp:StartUndo("Export Transform")

-- add the XF tool and put it close to the Tracker

local XPos, YPos  = flow:GetPos(tracker)
local exptool = composition:AddTool("Transform", XPos+2+ret.ExType, YPos+2)


-- connect xform parameters to tracker steady inputs
if ret.Position == 1 then 
  exptool.Center:ConnectTo( tracker.SteadyPosition	)
end

if ret.Rotation == 1 then 
   exptool.Angle:ConnectTo( tracker.SteadyAngle )
end

if ret.Scaling == 1 then 
	exptool.Size:ConnectTo( tracker.SteadySize )
end

if ret.Axis == 1 then 
	exptool.Pivot:ConnectTo( tracker.SteadyAxis )
end

if ret.XFType == 0 then
	-- invert to convert the transformation 
	-- from stablize to matchmove
	exptool.InvertTransform = 1
end

-- when exporting a baked transform, bake all the keyframes in the render range
if ret.ExType == 1 then

	-- Generate a list of inputs that are animated
	local inputs = {}
	local input_id = {}
	for key,inp in pairs(exptool:GetInputList()) do
		if inp:GetConnectedOutput() or inp:GetExpression() then
				table.insert(inputs, inp.Name)
				table.insert(input_id, inp.ID)
		end
	end
	
	-- now bake each of those inputs
	
	for i=1, table.getn(inputs) do
		local inpname = input_id[i]
		local inp = exptool[inpname]
		local inpattrs = inp:GetAttrs()
			
		-- Get the range to process from render range
		local compattrs = composition:GetAttrs()
		local from = compattrs.COMPN_RenderStart
		local to = compattrs.COMPN_RenderEnd
		
		-- Record keyframes into a table for later use
		local keyframes = {}
		print("Recording "..(to-from+1).." keyframes from "..inp.Name.."...")
		for i=from,to do
			keyframes[i] = inp[i]
		end

		-- Create an appropriate modifier.
		-- We assume BezierSpline unless it's a DT_Point, then we use a Path
		
		if inpattrs.INPS_DataType == "Point" then
			modifier = comp:Path({})
		else
			modifier = comp:BezierSpline({})
		end
		
		if exptool[inpname]:GetExpression() then
			exptool[inpname]:SetExpression(nil)
		end
		
		-- Now connect it up.  This removes the old modifier
		exptool[inpname] = modifier

		-- Now set the keyframes back in
		print("Baking keyframes...")
		for i=from,to do
			inp[i] = keyframes[i]
		end
		print("Done.")
	end
end

-- colour the exported Transform, blue for linked, green for baked

if COLORED ~= nil then
	if ret.ExType == 1 then
		exptool.TileColor = BAKEDCOLOUR.bg
		exptool.TextColor = BAKEDCOLOUR.fg
	elseif ret.ExType == 0 then
		exptool.TileColor = LINKEDCOLOUR.bg
		exptool.TextColor = LINKEDCOLOUR.fg
	end
end

-- rename tool?
if RENAME == true then
	local toolName = exptool:GetAttrs().TOOLS_Name
	local trackerName = tracker:GetAttrs().TOOLS_Name
	if not string.find(toolName, "_"..trackerName.."$") then
		-- prevent adding the tracker name over and over
		exptool:SetAttrs({TOOLS_Name = toolName.."_"..trackerName, TOOLB_NameSet = true})
	end
end

-- add comments in the Transform node
-- first collect Comments data

-- put all the data in the Comments tab
if tracker.Reference[1] == 0 then
	exptool.Comments = "Reference Frame: "..tracker.ReferenceFrame[1]
end

comp:EndUndo(true)
composition:Unlock()

-- done
return
