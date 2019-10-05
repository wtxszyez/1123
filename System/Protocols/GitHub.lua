--[[--
==============================================================================
Reactor Package Manager for Fusion - v3.14 2019-10-05 
==============================================================================
Requires    : Fusion v9.0.2/16+ or Resolve v15/16+
Created by  : We Suck Less Community Members  [https://www.steakunderwater.com/wesuckless/]
	: Pieter Van Houte                [pieter@steakunderwater.com]
	: Andrew Hazelden                 [andrew@andrewhazelden.com]

==============================================================================
Overview
==============================================================================
Reactor is a package manager for Fusion and Resolve. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.

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

The Fusion "AllData:/Reactor/" PathMap folder location is:

(Windows) C:\ProgramData\Blackmagic Design\Fusion\Reactor\
(Linux) /var/BlackmagicDesign/Fusion/Reactor/
(Mac) /Library/Application Support/Blackmagic Design/Fusion/

The Resolve "AllData:/Reactor/" PathMap folder location is:

(Windows) C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Reactor\
(Linux) /var/BlackmagicDesign/DaVinci Resolve/Fusion/Reactor/
(Mac) /Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Reactor/

--]]--

local github_url = "api.github.com/"

local function GetRecentCommitID(repo)
	local token = g_Config.Repos[repo].Token
	local project_url = "https://" .. (token and (token.."@") or "") .. github_url .. "repos/" .. g_Config.Repos[repo].ID .. "/"
	local branch = g_Config.Repos[repo].Branch or os.getenv("REACTOR_BRANCH") or "master"

	local commits = GetJSON(project_url .. "commits?per_page=1")

	if commits[1] == nil then
		dprintf("[Warning] GetRecentCommitID() has a commits[1] value of nil")
		return nil
	end

	return commits[1].sha
end

local function GetSHA(project_url, path, name)
	local root = GetPagedJSON(project_url .. "contents" .. path)
	local ret = nil

	for i,v in ipairs(root) do
		if v.path == name then
			ret = v.sha
			break
		end
	end

	return ret
end

local function GetAtomList(repo, all)
	local token = g_Config.Repos[repo].Token
	local project_url = "https://" .. (token and (token.."@") or "") .. github_url .. "repos/" .. g_Config.Repos[repo].ID .. "/"
	local branch = g_Config.Repos[repo].Branch or os.getenv("REACTOR_BRANCH") or "master"

--	msg.Text = "Updating Atom List from "..repo

	local previd = g_Config.Repos[repo].PrevCommitID
	local curid = GetRecentCommitID(repo)
	local files = {}

	if previd ~= curid or all then
		local sha = GetSHA(project_url, "/", "Atoms")

		if sha then
			local paths = GetPagedJSON(project_url .. "git/trees/" .. sha, "tree")

			if paths then
				for i,path in ipairs(paths) do
					if path.type == "tree" then
						table.insert(files, "Atoms/" .. path.path .. "/" .. path.path .. ".atom")
					end
				end
			end
		end
	end

	g_Config.Repos[repo].PrevCommitID = curid

	return files
end

local function GetFiles(paths, repo, callbacks, cbdata)
	local token = g_Config.Repos[repo].Token
	local project_url = "https://" .. (token and (token.."@") or "") .. github_url .. "repos/" .. g_Config.Repos[repo].ID .. "/"

	local urls = {}

	for i,path in ipairs(paths) do
		urls[i] = project_url .. "contents/" .. path
	end

	return GetURLs(urls, false, {"Accept: application/vnd.github.v3.raw"}, callbacks, cbdata)
end

-- Expose our module interface
return {
	Init = function() end,
	CleanUp = function() end,
	GetAtomList = GetAtomList,
	GetFiles = GetFiles,
	GetRecentCommitID = GetRecentCommitID,
}
