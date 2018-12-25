------------------------------------------------------------
-- Highlight Animated.eyeonscript
--
-- Version 2.0
--
-- USE: Run the script from the composition to highlight tools
-- with animated parameters that have more than one keyframe.
--
-- written by Sean Konrad, Isaac Guenard (sdk@eyeonline.com)
-- updated : March 20th, 2008
-- v2.0 Changes
-- fixed: uses INPS_DataType now to ensure script no longer highlights all tools
-- added: supports simple expressions
-- added: prints done when it is finished
-- added: ignores non-visible tools
------------------------------------------------------------

toollist = comp:GetToolList()

for i, tool in pairs(toollist) do

	t_attrs = tool:GetAttrs()

	if t_attrs.TOOLB_Visible == true then
		local inplist = tool:GetInputList()
		
		for j, inp in pairs(inplist) do
			attrs = inp:GetAttrs()
			
			if inp:GetConnectedOutput() then
				if not (attrs.INPS_DataType == "Image" or attrs.INPS_DataType == "Mask") then
				
					tool.TileColor = { R=1, G=1, B=1}
					tool.TextColor = { R=.1, G=.1, B=.1}
					print("Highlighted ".. t_attrs.TOOLS_Name.." : "..attrs.INPS_Name)
					break
				end
			elseif inp:GetExpression() then
				tool.TileColor = { R=1, G=1, B=1}
				tool.TextColor = { R=.1, G=.1, B=.1}
				print("Highlighted ".. t_attrs.TOOLS_Name.." : "..attrs.INPS_Name)
				break
			end
			
		end
		
	end
	
end
print("Done")