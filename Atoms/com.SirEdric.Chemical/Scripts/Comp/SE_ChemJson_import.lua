--[[ HEADER
	Script to Import JSON 3D Files of chemical structures as published on
	https://www.ncbi.nlm.nih.gov/pccompound
	https://pubchem.ncbi.nlm.nih.gov/compound/6914120
	
	This will most likely fail with any other json structure...:-)
	
	Download the desired .json file from the 3D-Section of any element on that site.
	Run the Script to import that structure into Fusion.
	
	For Fusion earlier than 9.0.1 this Script requires the lua JSON library from:
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

--[[ Todo: 
			Add Grouped Mtl to Atoms similar to Bonds ✔
			Set Subdivs on Atoms

--]]

--json = require "json" --before Fusion 9.0.1
json = require "dkjson"
tools = composition:GetToolList()
flow = comp.CurrentFrame.FlowView

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

--{"H", {255,255,255}},
ElColors={
{"H", {190,255,255}}, {"He", {217,255,255}}, {"Li", {204,128,255}}, {"Be", {194,255,0}},
{"B", {255,181,181}}, {"C", {144,144,144}}, {"N", {48,80,248}}, {"O", {255,13,13}},
{"F", {144,224,80}}, {"Ne", {179,227,245}}, {"Na", {171,92,242}}, {"Mg", {138,255,0}},
{"Al", {191,166,166}}, {"Si", {240,200,160}}, {"P", {255,128,0}}, {"S", {255,255,48}},
{"Cl", {31,240,31}}, {"Ar", {128,209,227}}, {"K", {143,64,212}}, {"Ca", {61,255,0}},
{"Sc", {230,230,230}}, {"Ti", {191,194,199}}, {"V", {166,166,171}}, {"Cr", {138,153,199}},
{"Mn", {156,122,199}}, {"Fe", {224,102,51}}, {"Co", {240,144,160}}, {"Ni", {80,208,80}},
{"Cu", {200,128,51}}, {"Zn", {125,128,176}}, {"Ga", {194,143,143}}, {"Ge", {102,143,143}},
{"As", {189,128,227}}, {"Se", {255,161,0}}, {"Br", {166,41,41}}, {"Kr", {92,184,209}},
{"Rb", {112,46,176}}, {"Sr", {0,255,0}}, {"Y", {148,255,255}}, {"Zr", {148,224,224}},
{"Nb", {115,194,201}}, {"Mo", {84,181,181}}, {"Tc", {59,158,158}}, {"Ru", {36,143,143}},
{"Rh", {10,125,140}}, {"Pd", {0,105,133}}, {"Ag", {192,192,192}}, {"Cd", {255,217,143}},
{"In", {166,117,115}}, {"Sn", {102,128,128}}, {"Sb", {158,99,181}}, {"Te", {212,122,0}},
{"I", {148,0,148}}, {"Xe", {66,158,176}}, {"Cs", {87,23,143}}, {"Ba", {0,201,0}},
{"La", {112,212,255}}, {"Ce", {255,255,199}}, {"Pr", {217,255,199}}, {"Nd", {199,255,199}},
{"Pm", {163,255,199}}, {"Sm", {143,255,199}}, {"Eu", {97,255,199}}, {"Gd", {69,255,199}},
{"Tb", {48,255,199}}, {"Dy", {31,255,199}}, {"Ho", {0,255,156}}, {"Er", {0,230,117}},
{"Tm", {0,212,82}}, {"Yb", {0,191,56}}, {"Lu", {0,171,36}}, {"Hf", {77,194,255}},
{"Ta", {77,166,255}}, {"W", {33,148,214}}, {"Re", {38,125,171}}, {"Os", {38,102,150}},
{"Ir", {23,84,135}}, {"Pt", {208,208,224}}, {"Au", {255,209,35}}, {"Hg", {184,184,208}},
{"Tl", {166,84,77}}, {"Pb", {87,89,97}}, {"Bi", {158,79,181}}, {"Po", {171,92,0}},
{"At", {117,79,69}}, {"Rn", {66,130,150}}, {"Fr", {66,0,102}}, {"Ra", {0,125,0}},
{"Ac", {112,171,250}}, {"Th", {0,186,255}}, {"Pa", {0,161,255}}, {"U", {0,143,255}},
{"Np", {0,128,255}}, {"Pu", {0,107,255}}, {"Am", {84,92,242}}, {"Cm", {120,92,227}},
{"Bk", {138,79,227}}, {"Cf", {161,54,212}}, {"Es", {179,31,212}}, {"Fm", {179,31,186}},
{"Md", {179,13,166}}, {"No", {189,13,135}}, {"Lr", {199,0,102}}, {"Rf", {204,0,89}},
{"Db", {209,0,79}}, {"Sg", {217,0,69}}, {"Bh", {224,0,56}}, {"Hs", {230,0,46}}, {"Mt", {235,0,38}},
}


JsnFile = comp:GetData("JsnFile") or "C:\\"
hSize = comp:GetData("hSize") or .1
aSize = comp:GetData("aSize") or .25
bSize = comp:GetData("bSize") or 5
aSubs = comp:GetData("aSubs") or 20
lBonds = comp:GetData("lBonds") or 1
lAtoms = comp:GetData("lAtoms") or 1
aLabels = comp:GetData("aLabels") or 0
lFall = comp:GetData("lFall") or 0
sDist = comp:GetData("sDist") or 1
BondBoost = comp:GetData("BondBoost") or 2


ret = comp:AskUser("Import JSON chemical Structure", {
		--{"CopyShop", Name = "Copy to Shop", "Checkbox", NumAcross = 1, Default = mySettings.CopyShop },
		{"JsnFile", Name="Json File", "FileBrowse", Default = JsnFile, Save=false},
		{"hSize", Name = "Helium Radius", "Slider", Default = hSize, Min = 0.01, Max = 1 },
		{"aSize", Name = "All Other Radius", "Slider", Default = aSize, Min = 0.01, Max = 1 },
		{"aSubs", Name = "Atom Subdivs", "Slider", Default = aSubs, Integer = true, Min = 3, Max = 100 },
		{"bSize", Name = "Bond Width", "Slider", Default = bSize, Integer = true, Min = 1, Max = 10 },
		{"BondBoost", Name = "Bonds Material Boost", "Slider", Default = BondBoost, Min = 1, Max = 10 },
		{"sDist", Name = "Scale Atom Distance (last scale applied: "..sDist..")", "Slider", Default = 1, Min = 0.1, Max = 10 },
		{"lBonds", Name = "Bonds receive Lighting", "Checkbox", NumAcross = 1, Default = lBonds },
		{"lAtoms", Name = "Atoms receive Lighting", "Checkbox", NumAcross = 1, Default = lAtoms },
		{"lFall", Name = "Pseudo (falloff) lighting on Atoms", "Checkbox", NumAcross = 1, Default = lFall },
		{"aLabels", Name = "Create Element Labels", "Checkbox", NumAcross = 1, Default = aLabels },
		{"verbose", Name = "Verbose parsing", "Checkbox", NumAcross = 1, Default = 0 },
		{"Msg", Name = "Get your json models from", "Text", ReadOnly = true, Lines = 1, Wrap = false, Default = "https://www.ncbi.nlm.nih.gov/pccompound"},
	})
if ret == nil then do return end end
--dump(ret)

JsnFile = comp:MapPath(ret.JsnFile)
print(JsnFile)
jsonInFile = SF_ReadAll(JsnFile)
--jsonParsed = json.parse(jsonInFile) --before Fusion 9.0.1
jsonParsed = json.decode(jsonInFile)


if ret.verbose == 1 then
	print("------------------atoms")
	dump(jsonParsed["PC_Compounds"][1]["atoms"])

	print("------------------bonds")
	dump(jsonParsed["PC_Compounds"][1]["bonds"])

	print("------------------coords-conformers-y")
	dump(jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["y"])
end


-- build atom Merge
atomMerge = comp.Merge3D()
bondMerge = comp.Merge3D()
bondMerge.SceneInput1 = atomMerge
for atoms, elements in pairs(jsonParsed["PC_Compounds"][1]["atoms"]["element"]) do
	if elements == 1 then -- This is Sparta. Errr...Helium.
		sRadius = ret.hSize
	else
		sRadius = ret.aSize
	end
	--print(atoms, elements)
	atom = comp.Shape3D()
	atom.Shape[1] = "SurfaceSphereInputs"
	atom.SurfaceSphereInputs.Radius[1] = sRadius
	atom.SurfaceSphereInputs.SubdivisionLevelBase[1] = ret.aSubs
	atom.SurfaceSphereInputs.SubdivisionLevelHeight[1] = ret.aSubs
	atom.SurfaceSphereInputs.Lighting.IsAffectedByLights[1] = ret.lAtoms
	atom.Transform3DOp.Translate.X[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["x"][atoms] * ret.sDist
	atom.Transform3DOp.Translate.Y[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["y"][atoms] * ret.sDist
	atom.Transform3DOp.Translate.Z[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["z"][atoms] * ret.sDist
-- 	we now create element-based materials further down, rather than coloring each individual atom
--	atom.MtlStdInputs.Diffuse.Color.Red[1] = 1/255*ElColors[elements][2][1]
--	atom.MtlStdInputs.Diffuse.Color.Green[1] = 1/255*ElColors[elements][2][2]
--	atom.MtlStdInputs.Diffuse.Color.Blue[1] = 1/255*ElColors[elements][2][3]
	atom:SetAttrs({TOOLS_Name = "atom_" ..ElColors[elements][1].."_" .. atoms})
	atomMerge["SceneInput"..atoms] = atom
	aPosX, aPosY = flow:GetPos(atom)
	
	-- atom Material
	if ret.lFall == 1 then -- add falloff node to material
		colName = "elFO_".. ElColors[elements][1]
	elseif ret.aLabels == 1 then
		colName = "elLa_".. ElColors[elements][1]
	else
		colName = "elMat_".. ElColors[elements][1]
	end
	elMat = comp:FindTool(colName)
	if elMat then -- the Material already exists
		-- just exit and connect. This saves a bunch Material Nodes
		
	else -- build a new Material
		elMat = comp.MtlBlinn()
		elMat.Diffuse.Color.Red[1] = 1/255*ElColors[elements][2][1]
		elMat.Diffuse.Color.Green[1] = 1/255*ElColors[elements][2][2]
		elMat.Diffuse.Color.Blue[1] = 1/255*ElColors[elements][2][3]
		elMat:SetAttrs({TOOLS_Name = "elMat_".. ElColors[elements][1]})
		flow:SetPos(elMat, aPosX-4, aPosY)
		
		if ret.aLabels == 1 then -- add Element Labels
			-- channel Boolean
			bol3 = comp.MtlChanBool()
			bol3.OperationR[1]=4
			bol3.OperationG[1]=4
			bol3.OperationB[1]=4
		
			bol3:SetAttrs({TOOLS_Name = "elLa_".. ElColors[elements][1]})
			flow:SetPos(bol3, aPosX-3, aPosY)
			
			-- Texture2D
			elTex = comp.Texture2DOperator()
			elTex.WrapMode[1] = "Wrap"
			elTex.UScale[1] = 0.25
			flow:SetPos(elTex, aPosX-3, aPosY-1)
			
			-- Text+
			elText = comp.TextPlus()
			elText.Width[1] = 64
			elText.Height[1] = 128
			elText.StyledText[1] = ElColors[elements][1]
			elText.Size[1] = 1
			flow:SetPos(elText, aPosX-3, aPosY-2)
			elTex.Input = elText
			
			-- connect it up
			bol3.ForegroundMaterial = elTex
			bol3.BackgroundMaterial = elMat
			elMat = bol3
		end
		
		if ret.lFall == 1 then -- add falloff node to material
			falloff = comp.FalloffOperator()
			falloff.FaceOn.Red[1] = 1
			falloff.FaceOn.Green[1] = 1
			falloff.FaceOn.Blue[1] = 1
			falloff.FaceOn.Opacity[1] = 1

			falloff.Glancing.Red[1] = 0.3
			falloff.Glancing.Green[1] = 0.3
			falloff.Glancing.Blue[1] = 0.3
			-- position on the flow and Name
			flow:SetPos(falloff, aPosX-2, aPosY)
			falloff:SetAttrs({TOOLS_Name = "elFO_".. ElColors[elements][1]})
			-- connect it up
			falloff.GlancingMaterial = elMat
			falloff.FaceOnMaterial = elMat
			elMat = falloff
		end
	end
	-- connect Material to Atom Shape
	atom.MaterialInput = elMat
end

--build bonds
for bondi, bonds in pairs(jsonParsed["PC_Compounds"][1]["bonds"]["aid2"]) do
	if ret.verbose == 1 then print(jsonParsed["PC_Compounds"][1]["bonds"]["aid2"][bondi]) end
	bFrom = jsonParsed["PC_Compounds"][1]["bonds"]["aid2"][bondi]
	bTo = jsonParsed["PC_Compounds"][1]["bonds"]["aid1"][bondi]
	inMat = jsonParsed["PC_Compounds"][1]["atoms"]["element"][bFrom]
	outMat = jsonParsed["PC_Compounds"][1]["atoms"]["element"][bTo]
	--dump(ElColors[inMat])
	--dump(ElColors[outMat])
	bLines = jsonParsed["PC_Compounds"][1]["bonds"]["order"][bondi]
	colName = "col_"..inMat.."_"..outMat
	if ret.verbose == 1 then print(colName) end
	
	bond = comp.Ribbon3D()
	bond.NumberOfLines[1] = bLines
	bond.LineThickness[1] = ret.bSize
	bond.Lighting.IsAffectedByLights[1] = ret.lBonds
	
	bond.Start.X[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["x"][bFrom] * ret.sDist
	bond.Start.Y[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["y"][bFrom] * ret.sDist
	bond.Start.Z[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["z"][bFrom] * ret.sDist
	bond.End.X[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["x"][bTo] * ret.sDist
	bond.End.Y[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["y"][bTo] * ret.sDist
	bond.End.Z[1] = jsonParsed["PC_Compounds"][1]["coords"][1]["conformers"][1]["z"][bTo] * ret.sDist
	
	bond.MtlStdInputs.Diffuse.Color.Red[1] = ret.BondBoost
	bond.MtlStdInputs.Diffuse.Color.Green[1] = ret.BondBoost
	bond.MtlStdInputs.Diffuse.Color.Blue[1] = ret.BondBoost
	bond.MtlStdInputs.Diffuse.Color.Alpha[1] = ret.BondBoost
	
	bond:SetAttrs({TOOLS_Name = "bond_" .. bondi})
	bondMerge["SceneInput"..bondi+1] = bond
	
	bPosX, bPosY = flow:GetPos(bond)
	
	-- bond coloring
	bColor = comp:FindTool(colName)
	if bColor then -- the Material already exists
		-- just exit and connect. This saves a bunch of additonal BG Tools
		
	else -- build a new Material
		bColor = comp.Background()
		bColor:SetAttrs({TOOLS_Name = colName})
		bColor.Type[1] = "Horizontal"
		bColor.Width[1] = 2
		bColor.Height[1] = 2
		bColor.TopLeftRed[1] = 1/255*ElColors[inMat][2][1]
		bColor.TopLeftGreen[1] = 1/255*ElColors[inMat][2][2]
		bColor.TopLeftBlue[1] = 1/255*ElColors[inMat][2][3]
		bColor.TopRightRed[1] = 1/255*ElColors[outMat][2][1]
		bColor.TopRightGreen[1] = 1/255*ElColors[outMat][2][2]
		bColor.TopRightBlue[1] = 1/255*ElColors[outMat][2][3]
		flow:SetPos(bColor, bPosX-3, bPosY)
	end
	bond.MaterialInput = bColor
end

--comp:SetData("JsnFile", JsnFile)
for s1, s2 in pairs(ret) do
	comp:SetData(s1,s2)
end