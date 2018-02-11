local P, S, C, R, Ct, Cg = lpeg.P, lpeg.S, lpeg.C, lpeg.R, lpeg.Ct, lpeg.Cg

local ws       = S ('\r\n\f\t ')^1
local alpha    = R ( "az", "AZ" )
local digit    = R ( "09" )
local number   = S ('+-')^-1 * digit^1 * (P "." * digit^0)^-1
local fuid     = (alpha + P "_") * (alpha + digit + P "_")^0
local rest     = (1-(ws * P "&"))^1

local prefix   = P "/for"
local scope    = Cg (P "all" + P "visible" + P "selected", "scope")
local tooltype = Cg (Ct(C(fuid) * (P "," * C(fuid))^0), "tooltype")

function parseopts(cmds, str)
	local command = P(-1)

	for cmd,v in pairs(cmds) do
		command = command + (Cg(P(cmd), "command") * ws * v[2])
	end

	command = Ct ( command )

	local parser = Ct ( prefix * ws * scope * ws * (command + (tooltype * ws * command)) * (ws * P "&" * ws * command) ^ 0 * ws^-1 * P(-1) )

	return parser:match(str)
end


local commands =
{
	set =
	{
		"\tset <input> [at <time>] to <value>",
		Cg(fuid, "input") * (ws * P"at" * ws * Cg(number, "time"))^-1 * ws * P"to" * ws * Cg(rest, "value"),
		function(tool, args)
			local inp = tool[args.input]
			local time = tonumber(args.time) or comp.CurrentTime

			if inp then
				local func,err = loadstring("return " .. args.value)

				if func then
					setfenv(func, setmetatable({ value = inp[time], time = time, tool = tool, input = inp }, { __index = _G }))
					inp[time] = func()
				else
					error(err)
				end
			end
		end
	},

	animate =
	{
		"\tanimate <input> [(with <modifier>|remove)] [force]",
		Cg(fuid, "input") * ((ws * P"with" * ws * Cg(fuid, "modifier")) + (ws * Cg(P"remove", "remove")))^-1 * (ws * Cg(P"force", "force"))^-1,
		function(tool, args)
			local inp = tool[args.input]
			if inp then
				if args.remove then
					inp:ConnectTo(nil)
				elseif args.force or not inp:GetConnectedOutput() then
					local mod = args.modifier

					if not mod then
						local defmod =
						{
							Point = "Path",
						}

						mod = defmod[inp:GetAttrs("INPS_DataType")] or "BezierSpline"
					end

					if mod then
						inp:ConnectTo(comp[mod])
					end
				end
			end
		end
	},
}

local opts = parseopts(commands, args[0])

if opts then
	local tools

	if opts.tooltype then
		tools = {}
		for i,v in ipairs(opts.tooltype) do
			local tmp = comp:GetToolList(opts.scope == "selected", v)
			for i,v in ipairs(tmp) do
				table.insert(tools, v)
			end
		end
	else
		tools = comp:GetToolList(opts.scope == "selected", nil)
	end

	comp:StartUndo(args[0])

	for ic,v in ipairs(opts) do
		local func = commands[v.command][3]
		for it,tool in ipairs(tools) do
			if opts.scope ~= "visible" or tool:GetAttrs("TOOLB_Visible") then
				ok,err = pcall(func, tool, v)
				if not ok then
					print(err)
				end
			end
		end
	end

	comp:EndUndo(true)
else
	print("Usage: /for (selected|visible|all) [tooltype[, tooltype...]] <command> [ & <command>...]")
	print("Supported commands:")

	local t = {}

	for i,v in pairs(commands) do
		table.insert(t, v[1])
	end

	table.sort(t)

	print(table.concat(t,"\n"))
end
