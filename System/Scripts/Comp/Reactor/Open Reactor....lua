-- Open Reactor... menu item

-- This GitLab based Project ID is used to download "Reactor.lua"
local reactor_project_id = "5058837"

-- The release_mode is used to toggle Reactor between a "public" vs "dev" state.
-- In the "public" mode a GitLab Token ID is not required.
-- local release_mode = "dev"
local release_mode = "public"

local branch = os.getenv("REACTOR_BRANCH")
if branch == nil then
	branch = "master"
end

ffi = require "ffi"
curl = require "lj2curl"
ezreq = require "lj2curl.CRLEasyRequest"

local separator = package.config:sub(1,1)
local local_system = os.getenv("REACTOR_LOCAL_SYSTEM")
local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local path = app:MapPath(tostring(reactor_pathmap) .. "Reactor/System/")
local destFile = path .. "Reactor.lua"
bmd.createdir(path)

local config = bmd.readfile(path .. "Reactor.cfg")

local token = config and config.Settings and config.Settings.Reactor and config.Settings.Reactor.Token
if not token or #token == 0 then
	-- For now, let's just create a new config file if there's no token.
	bmd.writefile(path .. "Reactor.cfg", {
		Repos = {
			GitLab = {
				Projects = {
					Reactor = reactor_project_id,
				},
			},
		},
		Settings = {
			Reactor =
			{
				Token = "",
			},
		},
	})

  -- Skip checking for the GitLab Token ID when Reactor is running in the public mode.
	if release_mode ~= "public" then
		error("[Reactor Error] No private GitLab token was found in the config file. Please edit " .. path .. "Reactor.cfg and add your token.")
	end
end

if local_system then
	local file = io.open(local_system .. separator .. "Reactor.lua", "r")
	local str = file:read("*all")
	file:close()

	file = io.open(destFile, "w")
	file:write(str)
	file:close()

	ldofile(fusion:MapPath(destFile))
else
	local url = "https://gitlab.com/api/v4/projects/" .. reactor_project_id .. "/repository/files/System%2FReactor%2Elua/raw?ref=" .. branch

	if token then
		url = url .. "&private_token=" .. token
	end

	local file = io.open(destFile, "r")
	local doFetch = true -- file == nil or file:read(1) == nil

	if file then
		file:close()
	end

	if doFetch then
		local req = ezreq(url)

		local body = {}

		req:setOption(curl.CURLOPT_SSL_VERIFYPEER, 0)
		req:setOption(curl.CURLOPT_WRITEFUNCTION, ffi.cast("curl_write_callback",
			function(buffer, size, nitems, userdata)
				table.insert(body, ffi.string(buffer, size*nitems))
				return nitems;
			end))

		ok, err = req:perform()

		if ok then
			-- Check if the Reactor.lua file was downloaded correctly
			if table.concat(body) == [[{"message":"401 Unauthorized"}]] then 
				error("[Reactor Download Failed] 401 Unauthorized\n\n[Pro Tip] You should double check that you are syncing with the Reactor public repository in your \"Config:/Reactor.fu\" and \"Reactor:/System/Reactor.cfg\" files.")
			elseif table.concat(body) == [[{"message":"404 Project Not Found"}]] then 
				error("[Reactor Download Failed] 404 GitLab Project Not Found\n\n[Pro Tip] You should double check that you are syncing with the Reactor public repository in your \"Config:/Reactor.fu\" and \"Reactor:/System/Reactor.cfg\" files.")
			elseif table.concat(body) == [[{"message":"404 File Not Found"}]] then 
				error("[Reactor Download Failed] 404 File Not Found\n\n[Pro Tip] The main Reactor GitLab file has been renamed. Please download and install a new Reactor Installer script or you can try manually installing the latest Reactor.fu file.")
			else
				local file = io.open(destFile, "w")
				file:write(table.concat(body))
				file:close()
				ldofile(fusion:MapPath(destFile))
			end
		else
			print("[Reactor Error] fetch failed: ", err)
		end
	else
		ldofile(fusion:MapPath(destFile))
	end
end
