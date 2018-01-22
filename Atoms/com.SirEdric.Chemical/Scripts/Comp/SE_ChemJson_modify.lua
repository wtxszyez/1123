--[[ HEADER
	Script to Import JSON 3D Files of chemical structures as published on
	https://www.ncbi.nlm.nih.gov/pccompound
	https://pubchem.ncbi.nlm.nih.gov/compound/6914120
	
	This will most likely fail with any other json structure...:-)
	
	Download the desired .json file from the 3D-Section of any element on that site.
	Run the Script to import that structure into Fusion.
	
	For Fusion earlier than 9.0.1 this Scriptrequires the lua JSON library from:
	https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
	to be present in (e.g.) %AppData%\Blackmagic Design\Fusion\Modules\Lua
	As of Fusion 9.0.1 the dkjson library is already included.
	
	Beware! This might create humongous amounts of tools on your flow!
	Especially with interesting looking structures like:
	https://pubchem.ncbi.nlm.nih.gov/compound/186342#section=2D-Structure
	
	If you want to Render with SuperSampling turned on,
	a LineThickness of 10 and MaterialBoost of at least 2 is recommended.
	
	(C) 2017 by Eric "SirEdric" Westphal.
	Eric@SirEdric.de
	
--]]


--json = require "json" --before Fusion 9.0.1
json = require "dkjson"
tools = composition:GetToolList()

-- read a file ino a string
function SF_ReadAll(file)
	if fileexists(file) then
		local f = io.open(file, "rb")
		local content = f:read("*all")
		f:close()
		return content
	else
		SF_Danger("REQUESTED FILE NOT FOUND:\n"..file)
		do return end
	end
end

function SF_Danger(msg)
	print("------------------\n" .. msg .. "\n----------------")
	danger = comp:AskUser("Some Error occured..." , {
	{"Msg1", Name = "Warning", "Text", ReadOnly = true, Lines = 5, Wrap = true, Default = msg},
	})
	
	return danger
end

function numcut(num)
	return tonumber(string.format("%.3f",num))
end

JsnFile = comp:GetData("JsnFile") or "C:\\"
hSize = comp:GetData("hSize") or .1
aSize = comp:GetData("aSize") or .25
bSize = comp:GetData("bSize") or 5
aSubs = comp:GetData("aSubs") or 20
lBonds = comp:GetData("lBonds") or 1
lAtoms = comp:GetData("lAtoms") or 1
sDist = comp:GetData("sDist") or 1
BondBoost = comp:GetData("BondBoost") or 2


ret = comp:AskUser("Modify imported chemical Structure", {
		--{"JsnFile", Name="Json File", "FileBrowse", Default = JsnFile, Save=false},
		{"hSize", Name = "Helium Radius", "Slider", Default = hSize, Min = 0.01, Max = 1 },
		{"aSize", Name = "All Other Radius", "Slider", Default = aSize, Min = 0.01, Max = 1 },
		{"aSubs", Name = "Atom Subdivs", "Slider", Default = aSubs, Integer = true, Min = 3, Max = 100 },		
		{"bSize", Name = "Bond Width", "Slider", Default = bSize, Integer = true, Min = 1, Max = 10 },
		{"BondBoost", Name = "Bonds Material Boost", "Slider", Default = BondBoost, Min = 1, Max = 10 },
		{"sDist", Name = "Scale Atom Distance (last scale applied: "..sDist..")", "Slider", Default = 1, Min = 0.1, Max = 10 },
		{"lBonds", Name = "Bonds receive Lighting", "Checkbox", NumAcross = 1, Default = lBonds },
		{"lAtoms", Name = "Atoms receive Lighting", "Checkbox", NumAcross = 1, Default = lAtoms },
		{"verbose", Name = "Verbose parsing", "Checkbox", NumAcross = 1, Default = 0 },
	})
if ret == nil then do return end end
--dump(ret)

for n, tool in pairs(tools) do
	if tool:GetAttrs().TOOLS_RegID == "Shape3D" and tool:GetAttrs().TOOLS_Name:match("atom_") then 
		tool.SurfaceSphereInputs.Lighting.IsAffectedByLights[1] = ret.lAtoms
		if tool:GetAttrs().TOOLS_Name:match("_H_") then -- it's Helium
			tool.SurfaceSphereInputs.Radius[1] = ret.hSize
		else --
			tool.SurfaceSphereInputs.Radius[1] = ret.aSize
		end
		tool.SurfaceSphereInputs.SubdivisionLevelBase[1] = ret.aSubs
		tool.SurfaceSphereInputs.SubdivisionLevelHeight[1] = ret.aSubs
		
		-- Scale Distances
		tool.Transform3DOp.Translate.X[1] = tool.Transform3DOp.Translate.X[1] * ret.sDist
		tool.Transform3DOp.Translate.Y[1] = tool.Transform3DOp.Translate.Y[1] * ret.sDist
		tool.Transform3DOp.Translate.Z[1] = tool.Transform3DOp.Translate.Z[1] * ret.sDist
	end

	if tool:GetAttrs().TOOLS_RegID == "Ribbon3D" and tool:GetAttrs().TOOLS_Name:match("bond_") then 
		tool.MtlStdInputs.Diffuse.Color.Red[1] = ret.BondBoost
		tool.MtlStdInputs.Diffuse.Color.Green[1] = ret.BondBoost
		tool.MtlStdInputs.Diffuse.Color.Blue[1] = ret.BondBoost
		tool.MtlStdInputs.Diffuse.Color.Alpha[1] = ret.BondBoost
		
		tool.Lighting.IsAffectedByLights[1] = ret.lBonds
		tool.LineThickness[1] = ret.bSize
		
		-- Scale Distances
		tool.Start.X[1] = tool.Start.X[1] * ret.sDist
		tool.Start.Y[1] = tool.Start.Y[1] * ret.sDist
		tool.Start.Z[1] = tool.Start.Z[1] * ret.sDist
		tool.End.X[1] = tool.End.X[1] * ret.sDist
		tool.End.Y[1] = tool.End.Y[1] * ret.sDist
		tool.End.Z[1] = tool.End.Z[1] * ret.sDist
		
	end

end

for s1, s2 in pairs(ret) do
	comp:SetData(s1,s2)
end