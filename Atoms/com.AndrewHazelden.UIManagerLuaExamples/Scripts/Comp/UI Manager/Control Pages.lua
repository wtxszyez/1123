--[[--
Control Pages - v3 2019-11-04
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

Print out the control page names for the selected node.
--]]--

if comp.ActiveTool then
	print(comp.ActiveTool.Name .. " Node Control Pages:")
	for i,t in pairs(comp.ActiveTool:GetControlPageNames()) do
		print("\t" .. t)
	end
	print("\n")
else
	print("Please select a node and run this script again\n")
end
