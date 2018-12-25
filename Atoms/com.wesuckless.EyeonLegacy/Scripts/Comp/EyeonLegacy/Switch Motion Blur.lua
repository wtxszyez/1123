------------------------------------------------------------
-- Switch Motion Blur -- $Revision$
--
-- flow script
--
-- This script toggles the state of the motion blur control 
-- on all tools. When the check box is enabled the script sets 
-- the MotionBlur control to 0 and saves a persistent variable on 
-- the tool. When the script is run with the check box disabled 
-- then all tools that previously had MotionBlur disabled by 
-- this script will be re-enabled, with the previous settings 
-- still set.
--
-- This script uses the SetData() and GetData() functions to 
-- store persistent variables on individual tools. Persistent 
-- values are preserved with the saved flow.
--
-- KNOWN ISSUES
-- This script offers an option to affect selected tools only,
-- but it does not consider masks attached to the selected tool 
-- to also be selected.
--
--
-- written by Isaac Guenard (izyk@eyeonline.com)
-- written  : October 19th, 2002
-- updated : Sept 27, 2005
-- changes : updated for 5
------------------------------------------------------------



-- if the fusion variable isn't available we aren't running inside fusion
if not fusion then
	print("This is a Flow script, it should be run from within Digital Fusion")
end

-- if the flow has run in the past, this data will be  stored in the flow
local state = composition:GetData("Motion Blur Enabled")

-- the script has never been run on this flow,
-- assume the user wants to disable motion blur

if state == nil then 
	state = 1
end

-- get the users input
local ret = composition:AskUser("Toggle Motion Blur", {
			{"disable", Name = "Disable Motion Blur", "Checkbox", Default = state, NumAcross = 2},
			{"selected", Name = "Selected Tools Only", "Checkbox", Default = 0, NumAcross = 2}
			})

-- did they cancel?
if ret == nil then
	return
end

if ret.selected == 1 then
	tools = composition:GetToolList(true)
else 
	tools = composition:GetToolList(false)
end

if tools == nil then
	print("No selected tools!")
	return
end


if ret.disable == 1 then
-- they wanted to disable motion blur?
print("\nMotion Blur has been disabled on these tools (by script).")
	for i,tool in pairs(tools) do
		if tool.MotionBlur and tool.MotionBlur[0] > 0.0 then
		
			-- it's not enough that motion blur is enabled, we better check if 
			-- someone has animated it (we want to leave those alone)
			
			if tool.MotionBlur:GetConnectedOutput() == nil then
				tool:SetData("Motion Blur Was On", true)
				tool.MotionBlur = 0
			
				-- print a comment in the tool, to make it more obvious 
				-- that this WAS a motion blurred tool
				tool.Comments = "Motion Blur Disabled by Script\n" .. 
							tool.Comments[composition.CurrentTime]
				print("disabled  : "..tool:GetAttrs().TOOLS_Name)
			end
		end
		composition:SetData("Motion Blur Enabled", 0)
		
	end
	
else
-- they wanted to enable motion blur?
	print("\nMotion Blur has been restored to these tools (by script).")
	for i,tool in pairs(tools) do
		if tool:GetData("Motion Blur Was On") then
			tool:SetData("Motion Blur Was On", nil)
			tool.MotionBlur = 1
			
			-- this little bit of voodoo finds the comment left when motion blur
			-- was disabled and strips the comment out without damaging any
			-- other comments in the tool
			-- unless you animated the comments, in which case you likely get you deserve :->
			
			tool.Comments = string.gsub(tool.Comments[composition.CurrentTime], "(%.-)(Motion Blur Disabled by Script\n)(.-)", "%1%3")
			print("enabled   : "..tool:GetAttrs().TOOLS_Name)
		end
		composition:SetData("Motion Blur Enabled", 1)
		
	end
end

return


