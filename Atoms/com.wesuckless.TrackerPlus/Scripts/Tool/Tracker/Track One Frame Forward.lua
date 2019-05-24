--[[

Tracker Plus - Track One Frame Forward.lua
http://www.steakunderwater.com/wesuckless/viewtopic.php?f=6&t=1192
Pieter Van Houte (pieter[at]secondman[dot]com)

v1.1 20171123 	- Lua doesn't concatenate variables, corrected
				- fixed pattern updating
				- make variables local
				- it's faster! 
v1.0 20170217 	- initial release

--]]

--[[ 

original script by Bartos P. - info[at]talmai[dot]de
1.0 syntax adjustments for Fu9 by Michael Vorberg

]]--

-- THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
-- THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
-- DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
-- UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 

if not tool then
	tool = composition.ActiveTool
	if not tool then
		print("This is a Tool Script. Plese select a Tool and run again")
		do return end
	end
end

comp:Lock()													-- lock comp, this will stop the "render complete" msg.
comp:StartUndo("track one frame forward")
local compattrs = comp:GetAttrs()
local from_orig = compattrs.COMPN_RenderStart				-- get the original render range
local to_orig = compattrs.COMPN_RenderEnd
local current = comp.CurrentTime
local to_new = current + 1
comp:SetAttrs({COMPN_RenderStart = current})				-- set new render range relative to current time
comp:SetAttrs({COMPN_RenderEnd = to_new})
tool.TrackForwardFromCurrentTime[current] = 1				-- track
while comp:IsRendering() == true do							-- wait for tracker to complete
	wait(0.05)
end
comp:SetAttrs({COMPN_CurrentTime = to_new})

-- pattern center won't update while comp is locked

local activetrack = tool.TrackerList[1] + 1
local varnames = { "PatternCenter"..activetrack , "TrackedCenter"..activetrack }

local tcenter = tool:GetInput( varnames[2], to_new )
tool:SetInput( varnames[1], tcenter, to_new )

--

comp:SetAttrs({COMPN_RenderStart = from_orig})				-- set render range back to original state
comp:SetAttrs({COMPN_RenderEnd = to_orig})
comp:EndUndo(true)
comp:Unlock()												-- unlock comp