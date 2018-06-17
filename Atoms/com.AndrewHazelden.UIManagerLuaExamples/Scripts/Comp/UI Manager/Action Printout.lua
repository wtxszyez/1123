--[[
Action Printout v1.0 - 2018-06-17
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

Print a copy of the actions list to the Console.

--]]--

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
