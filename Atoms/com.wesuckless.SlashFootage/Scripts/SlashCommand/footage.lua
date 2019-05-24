--[[--
A console slash command to automate common footage manipulation tasks.

## Usage ##

Step 1. Switch to the Fusion Console tab.

Step 2. To list the Loader node based footage in the current composite type in:
/footage list

--]]--

local cmd = args[2]

local commands =
{
	list = function()
		local loaders = comp:GetToolList(false, "Loader")

		if #loaders == 0 then
			print("\tNo footage found.")
		else
			for i,ld in ipairs(loaders) do
				print("\t" .. ld.Clip[fu.TIME_UNDEFINED])
			end
		end
	end,
}

if cmd then
	if commands[cmd] then
		commands[cmd]()
	else
		print("unknown " .. args[1] .. " command: " .. cmd)
	end
else
	print(args[1] .. " commands:")
	for i,v in pairs(commands) do
		print("\t" .. i)
	end
end
