--[[--
Control Pages v1.0 - 2018-07-05 
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
