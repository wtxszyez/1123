--[[--
Render Selected.lua v3.14 - 2019-10-05

The "Render Selected" script will render the active node in Resolve's Fusion page Nodes view. This means you can still output content in Resolve's Fusion Page directly to disk using nodes like the FBXExporter node, or a custom EXRIO based Fuse.

--]]--

if not tool then
	tool = comp.ActiveTool
end

if tool then
	print('[Render Selected] ' .. tool.Name)
	comp:Render({Tool = tool})
else
	print('[Render Selected] Selection Error - Please select a node before running this script.')
end
