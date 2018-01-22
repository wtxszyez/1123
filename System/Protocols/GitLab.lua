--[[--
==============================================================================
Reactor Package Manager for Fusion - v1.0 2018-01-22
==============================================================================
Requires    : Fusion 9.0.1+
Created by  : We Suck Less Community Members  [https://www.steakunderwater.com/wesuckless/]
            : Pieter Van Houte                [pieter@steakunderwater.com]
            : Andrew Hazelden                 [andrew@andrewhazelden]

==============================================================================
Overview
==============================================================================
Reactor is a package manager for Fusion (Free) and Fusion Studio. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.

Reactor GitLab Public Repository:
https://gitlab.com/WeSuckLess/Reactor

Reactor Support Forum:
https://www.steakunderwater.com/wesuckless/viewforum.php?f=32

==============================================================================
Reactor Usage
==============================================================================
After Reactor.fu is installed on your system and you restart Fusion once you will see a new "Reactor" menu item is added to Fusion's menu bar.

The main Reactor Package Manager window is opened by selecting the "Reactor > Open Reactor..." menu item.

The "Reactor > Show Reactor Folder" menu item allows you to quickly view the "AllData:/Reactor/" PathMap folder location where the Reactor "atom" packages are downloaded and installed.

The "AllData:/Reactor/" PathMap folder location is:

(Windows) C:\ProgramData\Blackmagic Design\Fusion\Reactor\
(Linux) /var/BlackmagicDesign/Fusion/Reactor/
(Mac) /Library/Application Support/Blackmagic Design/Fusion/

--]]--

local ffi = require "ffi"
local curl = require "lj2curl"
local json = require "dkjson"

--@todo: remove
local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local atoms_root = reactor_root .. "Atoms/"
local deploy_root = reactor_root .. "Deploy/"
local installed_root = deploy_root .. "Atoms/"

local branch = os.getenv("REACTOR_BRANCH")
if branch == nil then
	branch = "master"
end

local gitlab_url = "https://gitlab.com/api/v4/projects/"

local function GetURL(url, do_headers)
	dprintf("gitlab GetURL('%s')", url:gsub("&private_token=.+", ""))

	local body = {}
	local headers

	curl.curl_easy_setopt(curl_handle, curl.CURLOPT_URL, url)
	curl.curl_easy_setopt(curl_handle, curl.CURLOPT_SSL_VERIFYPEER, 0)
	curl.curl_easy_setopt(curl_handle, curl.CURLOPT_WRITEFUNCTION, ffi.cast("curl_write_callback",
		function(buffer, size, nitems, userdata)
			table.insert(body, ffi.string(buffer, size*nitems))
			return size*nitems
		end))

	if do_headers then
		headers = {}
		curl.curl_easy_setopt(curl_handle, curl.CURLOPT_HEADERFUNCTION, ffi.cast("curl_write_callback",
			function(buffer, size, nitems, userdata)
				table.insert(headers, ffi.string(buffer, size*nitems))
				return size*nitems
			end))
	end

	local ret = curl.curl_easy_perform(curl_handle)

	return table.concat(body),headers
end

local function GetJSON(url)
	local body = GetURL(url)

	return json.decode(body)
end

local function GetPagedJSON(url)
	local ret = {}

	repeat
		local body,headers = GetURL(url, true)

		local data = json.decode(body)

		for i,v in ipairs(data) do
			table.insert(ret, v)
		end

		url = nil

		for i,hdr in ipairs(headers) do
			if hdr:sub(1,5) == "Link:" then
				local links = {}
				hdr:gsub('<(.-)>; *rel="(.-)"', function(link,rel) links[rel] = link end)

				url = links.next
			end
		end
	until not url

	return ret
end

function GetRecentCommitID(project_url, token)
	local commits = GetJSON(project_url .. "/repository/commits/?per_page=1" .. token)

	if commits[1] == nil then
		return nil
	end

	return commits[1].id
end


function GetAtomList(project_url, token)
	local paths = GetPagedJSON(project_url .. "/repository/tree?per_page=100&path=Atoms&ref=" .. branch .. token)
	local atoms = {}

	if paths then
		for i,path in ipairs(paths) do
			if path.type == "tree" then
				atoms[path.path .. "/" .. path.name .. ".atom"] = true
			end
		end
	end
	return atoms
end

local function UpdateAtoms(msg, repo, id, force)
	local project_url = gitlab_url .. id

	msg.Text = "Updating Atom List from "..repo

	local previd = g_Config.Settings[repo] and g_Config.Settings[repo].PrevCommitID
	local repo_atoms = atoms_root..repo..'/'
	local files = {}

	local token = g_Config.Settings[repo].Token and ("&private_token=" .. g_Config.Settings[repo].Token) or ""

	if previd == nil or force then
		-- initial fetch
		previd = GetRecentCommitID(project_url, token)
		files = GetAtomList(project_url, token)
	else
		-- update from commits
		local commits = GetJSON(project_url .. "/repository/compare?per_page=100&from=" .. previd .. "&to=" .. branch .. token)
		if commits.diffs then
			for i,v in ipairs(commits.diffs) do
				if v.old_path:sub(-5):lower() == ".atom" then
					files[v.old_path] = true
				end

				if v.new_path:sub(-5):lower() == ".atom" then
					files[v.new_path] = true
				end
			end
			previd = commits.commit and commits.commit.id
		else
			print("WARNING: Failed to get recent commits from ".. repo ..
					commits.message and "\n   " .. commits.message or "")
		end
	end

	bmd.createdir(repo_atoms)
	for path,_ in pairs(files) do
		local name = path:gsub(".+/(.+).atom", "%1")

		msg.Text = "Repo ".. repo .. ": Fetching Atom: " .. name

		body = GetURL(project_url .. "/repository/files/" .. EscapeStr(path) .. "/raw?ref=" .. branch .. token)

		SaveFile(repo_atoms .. name .. ".atom", body)
	end

	if previd then
		g_Config.Settings[repo] = g_Config.Settings[repo] or {}
		g_Config.Settings[repo].PrevCommitID = previd
	end
end

function Init()
	curl_handle = curl.curl_easy_init()
end

function CleanUp()
	curl.curl_easy_cleanup(curl_handle)
end

function GetFile(path, id, repo)
	local token = g_Config.Settings[repo].Token and ("&private_token=" .. g_Config.Settings[repo].Token) or ""

	return GetURL(gitlab_url .. id .. "/repository/files/" .. EscapeStr(path) .. "/raw?ref=" .. branch .. token)
end

-- Expose our module interface
mod =
{
	Init = Init,
	CleanUp = CleanUp,

	UpdateAtoms = UpdateAtoms,
	GetFile = GetFile,
}

return mod
