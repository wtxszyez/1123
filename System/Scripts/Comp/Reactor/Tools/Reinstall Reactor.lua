--[[--
Reinstall Reactor menu item - v3.2 2019-10-05
By Andrew Hazelden <andrew@andrewhazelden.com>
--]]--

-- Choose the GitLab based Project ID that should be used to download the "Reactor Installer" Lua script.
-- Reactor GitLab Project ID
local reactor_project_id = "5058837"

-- Reactor GitLab Dev Project ID
-- local reactor_project_id = "4405807"

-- Reactor GitLab Test Repo Project ID
-- local reactor_project_id = "5273696"

-- The release_mode is used to toggle Reactor between a "public" vs "dev" state.
-- In the "public" mode a GitLab Token ID is not required.
local release_mode = "public"
-- local release_mode = "dev"


ffi = require "ffi"
curl = require "lj2curl"
ezreq = require "lj2curl.CRLEasyRequest"

local function EncodeURL(txt)
	if txt ~= nil then
		urlCharacters = {
			{pattern = '[/]', replace = '%%2F'},
			{pattern = '[.]', replace = '%%2E'},
			{pattern = '[ ]', replace = '%%20'},
		}

		for i,val in ipairs(urlCharacters) do
			txt = string.gsub(txt, urlCharacters[i].pattern, urlCharacters[i].replace)
		end
	end

	return txt
end

local separator = package.config:sub(1,1)
local local_system = os.getenv("REACTOR_LOCAL_SYSTEM")

-- Check for a pre-existing PathMap preference
local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
	-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
	reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. separator .. "$", "")
end

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
local path = app:MapPath(tostring(reactor_pathmap) .. "Reactor/System/")

local installer_path = app:MapPath("Temp:/Reactor/")
local destFile = installer_path .. "Reactor-Installer.lua"

local sourceGitFile = ""
if reactor_project_id == "4405807" then
	sourceGitFile = EncodeURL("Reactor-Installer/Reactor-Dev-Installer.lua")
elseif reactor_project_id == "5273696" then
	sourceGitFile = EncodeURL("Reactor-Test-Installer.lua")
else
	-- Reactor Public
	-- GitLab Project ID 5058837
	sourceGitFile = EncodeURL("Reactor-Installer.lua")
end

local branch = os.getenv("REACTOR_BRANCH")
if branch == nil then
	branch = "master"
end

-- Create the "Reactor:/System/" folder
bmd.createdir(path)

-- Create the "Temp:/Reactor/" folder
bmd.createdir(installer_path)

local config = bmd.readfile(path .. "Reactor.cfg")
local token = config and ((config.Repos and config.Repos._Core and config.Repos._Core.Token) or (config.Settings and config.Settings.Reactor and config.Settings.Reactor.Token))

-- Skip checking for the GitLab Token ID when Reactor is running in the public mode.
if not token and release_mode ~= "public" then
	error("[Reactor Error] No private GitLab token was found in the config file. Please edit " .. path .. "Reactor.cfg and add your token.")
end

if not local_system then
	local url = "https://gitlab.com/api/v4/projects/" .. reactor_project_id .. "/repository/files/" .. sourceGitFile .. "/raw?ref=" .. branch

	if token then
		url = url .. "&private_token=" .. token
	end
	print("[Download URL] " .. url)

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
					ldofile(destFile)
				else
					print("[Reactor Error] Disk permissions error when saving: ", destFile)
				end
			end
		else
			print("[Reactor Error] Fetch Failed: ", err)
		end
	else
		print("[Reactor] Running Installer: ", destFile)
		ldofile(destFile)
	end
end
