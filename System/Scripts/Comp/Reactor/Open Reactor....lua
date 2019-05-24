--[[--
Open Reactor... menu item - v3 2019-05-23
By Andrew Hazelden <andrew@andrewhazelden.com>
--]]--

-- This GitLab based Project ID is used to download "Reactor.lua"
-- Reactor GitLab Project ID
local reactor_project_id = "5058837"

-- Reactor GitLab Test Repo Project ID
-- local reactor_project_id = "5273696"

-- The release_mode is used to toggle Reactor between a "public" vs "dev" state.
-- In the "public" mode a GitLab Token ID is not required.
local release_mode = "public"
-- local release_mode = "dev"

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

local token = config and ((config.Repos and config.Repos._Core and config.Repos._Core.Token) or (config.Settings and config.Settings.Reactor and config.Settings.Reactor.Token))

-- Skip checking for the GitLab Token ID when Reactor is running in the public mode.
if not token and release_mode ~= "public" then
	error("[Reactor Error] No private GitLab token was found in the config file. Please edit " .. path .. "Reactor.cfg and add your token.")
end

if local_system then
	local file = io.open(local_system .. separator .. "Reactor.lua", "r")
	local str = nil

	if file then
		str = file:read("*all")
		file:close()
	else
		print("[Reactor Error] Disk permissions error reading local_system path ", local_system)
		os.exit()
	end

	file = io.open(destFile, "w")
	if file then
		file:write(str)
		file:close()
		ldofile(fusion:MapPath(destFile))
	else
		print("[Reactor Error] Disk permissions error when saving: ", destFile)
		os.exit()
	end
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
			elseif table.concat(body) == [[{"error":"invalid_token","error_description":"Token was revoked. You have to re-authorize from the user."}]] then
				error("[Reactor Download Failed] GitLab TokenID Revoked Error\n\n[Pro Tip] Your GitLab TokenID has been revoked. Please enter a new TokenID value in your Reactor.cfg file, or switch to the Reactor Public repo and remove your existing Reactor.cfg file.")
			elseif table.concat(body) == [[{"message":"404 Commit Not Found"}]] then
				error("[Reactor Download Failed] GitLab Previous CommitID Empty Error\n\n[Pro Tip] Please remove your existing Reactor.cfg file and try again. Alternativly, you may have a REACTOR_BRANCH environment variable active and it is requesting a branch that does not exist.")
			elseif table.concat(body) == [[{"error":"insufficient_scope","error_description":"The request requires higher privileges than provided by the access token.","scope":"api"}]] then
				error("[Reactor Download Failed] GitLab TokenID Permissions Scope Error\n\n[Pro Tip] Your GitLab TokenID privileges do not grant you access to this repository.")
			else
				local file = io.open(destFile, "w")
				if file then
					file:write(table.concat(body))
					file:close()
					ldofile(fusion:MapPath(destFile))
				else
					print("[Reactor Error] Disk permissions error when saving: ", destFile)
				end
			end
		else
			print("[Reactor Error] Fetch Failed: ", err)
		end
	else
		ldofile(fusion:MapPath(destFile))
	end
end
