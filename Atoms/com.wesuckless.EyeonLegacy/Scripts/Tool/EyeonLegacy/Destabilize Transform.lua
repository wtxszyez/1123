------------------------------------------------------------------------------
-- Destabilize Transform, Revision: 2.0 
--
-- tool script
--
-- Connects transforms / merges to trackers.
--
-- written by : Isaac Guenard (izyk@eyeonline.com)
-- updated by: Sean Konrad (sean@eyeonline.com)
-- written    : August 28th, 2003
-- updated : Jan. 9, 2005
-- changes : updated for 5
------------------------------------------------------------------------------

local tracks = {}
local names = {}
local id = tool:GetID()

local Mrg ="Merge"
local XF  = "Transform"


-- is this a transform?
if tool:GetID() ~= Mrg and tool:GetID() ~=  XF then 
	local err  = "This script is designed to connect a transform tool to the "..
					"unsteady outputs of a tracker. You must select a transform "..
					"or merge tool."
					
	comp:AskUser("Error!", { 
			{"Description", "Text", ReadOnly = true, Default = err, Wrap=true, Lines = 5 } 
			})
	return
end


local toollist = comp:GetToolList()
for i, v in pairs(toollist) do
	if v:GetID() == "Tracker" then
		table.insert(tracks, v)
		table.insert(names, v:GetAttrs().TOOLS_Name)
	end
end

-- if so find all trackers
if table.getn(tracks) == 0 then
	print("There are no trackers in this comp!")
end

-- display dialog of trackers
local desc = "This script will connect the controls of a tool "..
			"to the Steady Outputs of a Tracker. It will then invert "..
			"the transformation to produce to apply the tracked motion "..
			"to the image input of the transform."

local ret = comp:AskUser("Select a Tracker to Connect To :", { 
	{"Tracker", "Dropdown", Options = names },
	{"Size", "Checkbox", Default = 1, NumAcross=2},
	{"Angle", "Checkbox", Default = 1, NumAcross=2},
	{"Position", "Checkbox", Default = 1, NumAcross=2},
	{"Axis", "Checkbox", Default = 1, NumAcross=2},
	{"Description", "Text", ReadOnly = true, Default = desc, Wrap=true, Lines = 5}
	})

	if ret == nil then
		return
	end

local tracker = tracks[ret.Tracker + 1]

comp:StartUndo("Destabilize Transform")
	
	-- connect xform parameters to tracker steady inputs
	if ret.Position == 1 then 
	  tool.Center:ConnectTo( tracker.SteadyPosition	)
	end
	
	if ret.Size == 1 then 
		tool.Size:ConnectTo( tracker.SteadySize )
	end
	
	if ret.Angle == 1 then 
	   tool.Angle:ConnectTo( tracker.SteadyAngle )
	end
	
	-- the merge tool has no axis, 
	-- so skip this if the tool is a merge
	if ret.Axis == 1 and id ~= Mrg then 
		tool.Pivot:ConnectTo( tracker.SteadyAxis )
	end

-- invert to convert the transformation 
	-- from stablize to unstabilize
	tool.InvertTransform = 1

comp:EndUndo(true)

-- done
return
