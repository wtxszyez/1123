--[[

Tracker Plus - Set Current Time As Reference Frame.lua
http://www.steakunderwater.com/wesuckless/viewtopic.php?f=6&t=1192
20171123 - Pieter Van Houte (pieter[at]secondman[dot]com)

--]]

--[[ 

original script by Bartos P. - info[at]talmai[dot]de
syntax adjustments for Fu9 by Michael Vorberg

]]--

-- THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
-- THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
-- DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
-- UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 

--some variables
current = comp.CurrentTime
k = 1
tracker = {}
inputlist = nil

--this slightly modified chunk was written by: Isaac Guenard (izyk@eyeonline.com)
if not tool then
	tool = composition.ActiveTool
	if not tool then
		print("This is a Tool Script. Plese select a Tool and run again")
		do return end
	end
end

--search for a specific input and return its ID
function SearchInput(t,s)
	none = false
	if inputlist == nil then
		print("Please wait - caching InputList...")	--or doing something absolutely useless 
		inputlist = {}
		for n,m in ipairs(t:GetInputList()) do
			inputlist[n] = m
		end
	end
	for i, inp in ipairs(inputlist) do
		local inpid = inp:GetAttrs().INPS_ID
		if tostring(inpid) == tostring(s) then
			return i
		else
			none = true
		end
	end
	if none == true then
		return nil
	end
end

--check if tracker is disabled
function IsEnabled(t,id)
	c = 1
	enabled = {}
	repeat
		count = SearchInput(t,"Enabled"..c)
		enabled[c] = SearchInput(t,"Enabled"..c)
		c = c + 1
	until count == nil
	--if t:GetInputList()[enabled[id]][current] == 1 or t:GetInputList()[enabled[id]][current] == 2 then
	if t:GetInputList()[enabled[id]][current] == 1 then	
		return true
	end
	return false
end

if tool:GetAttrs().TOOLS_RegID == "Tracker" then
	if tool.Reference[1] == 0 then	--Reference must be set to "Select time"
		if SearchInput(tool,"Tracker"..k) == nil then
			print("No Tracker present. Please add a Tracker")
		else
			comp:StartUndo("update pattern")
			repeat	--get all tracker
				count = SearchInput(tool,"Tracker"..k)
				tracker[k] = SearchInput(tool,"Tracker"..k)
				k = k + 1
			until count == nil
			for i, t in ipairs(tracker) do
				if IsEnabled(tool,i) == true then	--check if enabled
					pcenter = SearchInput(tool,"PatternCenter"..i)	--get PatternCenter input ID
					tcenter = SearchInput(tool,"TrackedCenter"..i)	--get TrackedCenter input ID
					tool:GetInputList()[pcenter][current] = tool:GetInputList()[tcenter][current]	--move PatterCenter to TrackedCenter
					print("Moving PatternCenter"..i.." to TrackedCenter"..i)
					tool.ReferenceFrame = current
				else
					print("Skipping disabled Tracker: "..tool:GetInputList()[t]:GetAttrs().INPS_Name)
				end
			end
			comp:EndUndo(true)
		end
	else
		print("Will only run  when \"Reference\" is set to \"Select time\"")
	end
else
	print("This is not a Tracker")
end