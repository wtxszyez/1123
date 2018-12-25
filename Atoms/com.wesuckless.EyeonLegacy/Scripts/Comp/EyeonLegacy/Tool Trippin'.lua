-- Animates the TileColor and TextColor attributes on all of the nodes in your comp. 
-- When the script finished the node colors are set back to their defaults.

tools = comp:GetToolList()

for i=1,50 do
	for j,tool in pairs(tools) do
		tool.TileColor = { R=math.random(), G=math.random(), B=math.random()}
		tool.TextColor = { R=math.random(), G=math.random(), B=math.random()}
	end
	wait(0.1)
end

for j,tool in pairs(tools) do
	tool.TileColor = nil
	tool.TextColor = nil
end
