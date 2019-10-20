--[[--
Render Selected.lua v3.14 - 2019-10-19

The "Render Selected" script will render the actively selected node in Fusion Standalone/Resolve's Fusion page Nodes view. This means you can output content in Resolve's Fusion Page directly to disk using nodes like the FBXExporter, Saver, LifeSaver, PutFrame, or custom EXRIO based Fuse.

--]]--

-- Is a Fusion comp open?
if comp then
	-- The "tool" variable is empty
	if not tool then
		-- Get the selected tool when running as a comp script
		tool = comp.ActiveTool
	end

	-- Was a node selected in the Nodes view?
	if tool then
		print('[Render Selected] ' .. tool.Name)

		-- Render only the selected tool
		comp:Render({Tool = tool})
	else
		print('[Render Selected] [Selection Error] Please select a node before running this script.')
	end
else
	print('[Render Selected] [Comp Error] Please open a new Fusion composite before trying to render it.')
end
