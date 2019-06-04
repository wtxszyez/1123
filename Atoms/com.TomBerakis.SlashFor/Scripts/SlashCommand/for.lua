local P, S, C, R, Ct, Cg, Cc = lpeg.P, lpeg.S, lpeg.C, lpeg.R, lpeg.Ct, lpeg.Cg, lpeg.Cc

local ws       = S ('\r\n\f\t ')^1
local alpha    = R ( "az", "AZ")
local digit    = R ( "09" )
local number   = (S ('+-')^-1 * digit^1 * (P "." * digit^0)^-1) / tonumber
local fuid     = (alpha + P "." + P "_" ) * (alpha + digit + P "." + P "_")^0
local rest     = (1-(ws * P "&"))^1

local prefix   = P "/for"
local scope    = Cg (P "all" + P "visible" + P "selected", "scope")
local tooltype = Cg (Ct(C(fuid) * (P "," * C(fuid))^0), "tooltype")
local color    = Ct(Cg(number, "R") * P"," * Cg(number, "G") * P"," * Cg(number, "B"))
local clrcolor = (P"clear" * Cc(false)) + color

function parseopts(cmds, str)
	local command = P(-1)

	for cmd,v in pairs(cmds) do
		command = command + (Cg(P(cmd), "command") * v[2])
	end

	command = Ct(command)
	local where = P"where" * ws * Cg((1 - command)^1, "where")

	local parser = Ct(prefix * ws * scope * ws * (command + (where * command) + (tooltype * ws * command)) * (ws * P "&" * ws * command) ^ 0 * ws^-1 * P(-1))

	return parser:match(str)
end

local commands =
{
	set =
	{
		"\tset <input> ([at <time>] to <value>|expression <exp>)",
		ws * Cg(fuid, "input") * (((ws * P"at" * ws * Cg(number, "time"))^-1 * ws * P"to" * ws * Cg(rest, "value")) + (ws * P"expression" * ws * Cg(rest, "expression"))),
		function(tool, args)
			local inp = tool[args.input]

			if inp then
				if args.expression then
					inp:SetExpression(args.expression)
				else
					local time = args.time or comp.CurrentTime
					local func,err = loadstring("return " .. args.value)

					if func then
						local cur = inp[time]
						setfenv(func, setmetatable({ value = cur, current = cur, time = time, tool = tool, input = inp }, { __index = _G }))
						inp[time] = func()
					else
						error(err)
					end
				end
			end
		end
	},
	animate =
	{
		"\tanimate <input> [(with <modifier>|remove)] [force]",
		ws * Cg(fuid, "input") * ((ws * P"with" * ws * Cg(fuid, "modifier")) + (ws * Cg(P"remove", "remove")))^-1 * (ws * Cg(P"force", "force"))^-1,
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
	select =
	{
		"\tselect [(add|remove)]",
		(ws * (Cg("add", "add") + Cg("remove", "remove")))^-1,
		function(tool, args)
			comp.CurrentFrame.FlowView:Select(tool, not args.remove)
		end,
		function(tools, args)
			if not (args.add or args.remove) then
				comp.CurrentFrame.FlowView:Select(nil)
			end
		end,
	},
	color =
	{
		"\tcolor [tile <color>] [text <color>] [fill <color>]",
		(ws * ((P"tile" * ws * Cg(clrcolor, "tile")) + (P"text" * ws * Cg(clrcolor, "text")) + (P"fill" * ws * Cg(clrcolor, "fill"))))^1,
		function(tool, args)
			if args.tile ~= nil then tool.TileColor = args.tile or nil end
			if args.text ~= nil then tool.TextColor = args.text or nil end
			if args.fill ~= nil then tool.FillColor = args.fill or nil end
		end,
	},
}

local opts = parseopts(commands, args[0])

if opts then
	local tools = {}

	if opts.tooltype then
		for i,v in ipairs(opts.tooltype) do
			local tmp = comp:GetToolList(opts.scope == "selected", v)
			for i,v in ipairs(tmp) do
				table.insert(tools, v)
			end
		end
	else
		tools = comp:GetToolList(opts.scope == "selected", nil)
	end

	if opts.where then
		local old = bmd.getusing()
		local func,err = loadstring("return " .. opts.where)
		if not func then
			error(err)
		end

		local env = setmetatable({ time = comp.CurrentTime, tool = tool, input = inp }, { __index = function(t,k) return rawget(t,"tool"):GetInput(k, rawget(t,"time")) or _G[k] end })
		setfenv(func, env)

		local matchtools = {}

		for i,tool in ipairs(tools) do
			env.tool = tool
			local ok,ret = pcall(func)
			if ok and ret then
				table.insert(matchtools, tool)
			end
		end

		tools = matchtools
	end

	comp:StartUndo(args[0])

	for ic,v in ipairs(opts) do
		if commands[v.command][4] then
			commands[v.command][4](tools, v)
		end
		local func = commands[v.command][3]
		for it,tool in ipairs(tools) do
			if tool and opts.scope ~= "visible" or tool:GetAttrs("TOOLB_Visible") then
				ok,err = pcall(func, tool, v)
				if not ok then
					print(err)
				end
			end
		end
	end

	comp:EndUndo(true)
else
	print("Usage: /for (selected|visible|all) [tooltype[,tooltype...]] [where <condition>] <command> [ & <command>...]")
	print("Supported commands:")

	local t = {}

	for i,v in pairs(commands) do
		table.insert(t, v[1])
	end

	table.sort(t)

	print(table.concat(t,"\n"))
end
