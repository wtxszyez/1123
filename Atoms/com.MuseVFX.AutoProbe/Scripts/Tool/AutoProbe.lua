DEBUG = false

--[[--

	AutoProbe 
	v1.0 - 2019-08-05
	by Bryan Ray for Muse VFX

	===== Overview =====	

	Automatically connects all four channels of a ColorControl to a new Probe Modifier.

	===== License =====

	This script is released to the public domain, and no guarantee is made as to its suitability for any particular purpose. No warranty
	is provided, and no burden of support is assumed by any of its creators or distributors. 

	===== Change Log =====

	v1.0: Initial public release

	-- To do: Clarify the question.Menu thing
		UI Manager? 

--]]--


-- ===========================================================================
-- globals
-- ===========================================================================
_fusion = nil
_comp = nil

--==============================================================
-- main()
--==============================================================

function main()
	-- get fusion instance
	_fusion = getFusion()

	-- ensure a fusion instance was retrieved
	if not _fusion then
		error("Please open the Fusion GUI before running this tool.")
	end

	-- get composition
	_comp = _fusion.CurrentComp
	SetActiveComp(_comp)

	-- ensure a composition is active
	if not _comp then
		error("Please open a composition before running this tool.")
	end

	dprint("\nActive comp is ".._comp:GetAttrs().COMPS_Name)


	-- Get all color control sliders - parse IC_ControlGroup to match multiple color controls in one tool
	local colorControls = {}
	for i, inp in ipairs(tool:GetInputList()) do
		if inp:GetAttrs().INPID_InputControl == 'ColorControl' then
			-- Identify control group
			local group = inp:GetAttrs().INPI_IC_ControlGroup
			local id = inp:GetAttrs().INPI_IC_ControlID
			if not colorControls[group] then
				colorControls[group] = {}
			end
			colorControls[group][id] = inp
		end
	end



	if table.getn(colorControls) > 1 then
		local controlList = {}
		for i, item in ipairs(colorControls) do
			controlList[i] = item[0].Name
		end
		-- Ask the user which control the probe should attach to.
		d = {}
		d[1] = {"Menu", Name = "Which Control?", "Dropdown", Options = controlList, default = 0}
		question = _comp:AskUser("Choose Control", d)
	else
		question = {}
		question.Menu = 0
	end

	-- Create Probe modifier on item 0
	tool:AddModifier(colorControls[question.Menu+1][0].ID, "Probe")


	-- Detect Probe Modifiers
	probe = colorControls[question.Menu+1][0]:GetConnectedOutput():GetTool()

	-- Connect other related sliders to the proper output channels
	local channelList = {"Red", "Green", "Blue", "Alpha"}

	for i, inp in ipairs(colorControls[question.Menu+1]) do
		local channel = nil
		-- find the channel
		for j, item in ipairs(channelList) do
			found = string.find(inp.Name, item)
			if found then
				channel = item
				break
			end
		end
		tool[inp.ID] = probe[channel]
	end


end -- End of main()




--======================== ENVIRONMENT SETUP ============================--

------------------------------------------------------------------------
-- getFusion()
--
-- check if global fusion is set, meaning this script is being
-- executed from within fusion
--
-- Arguments: None
-- Returns: handle to the Fusion instance
------------------------------------------------------------------------
function getFusion()
	if fusion == nil then 
		-- remotely get the fusion ui instance
		fusion = bmd.scriptapp("Fusion", "localhost")
	end
	return fusion
end -- end of getFusion()


--========================== DEBUGGING ============================--


---------------------------------------------------------------------
-- dprint(string, suppressNewline)
--
-- Prints debugging information to the console when DEBUG flag is set
--
-- Arguments:
--		string, string, a message for the console
--		suppressNewline, boolean, do not start a new line
---------------------------------------------------------------------
function dprint(string, suppressNewline)
	local newline = "\n"
	if suppressNewline then newline = '' end
	if DEBUG then _comp:Print(string..newline) end
end -- dprint()

---------------------------------------------------------------------
-- ddump(object)
--
-- Performs a dump() if the DEBUG flag is set
--
-- Arguments
--		object, object, an object to be dumped
---------------------------------------------------------------------
function ddump(object)
	if DEBUG then dump(object) end
end -- end ddump()


main()