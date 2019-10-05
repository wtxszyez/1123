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

local gitlab_url = "https://gitlab.com/api/v4/projects/"

local function GetRecentCommitID(repo)
	local branch = g_Config.Repos[repo].Branch or os.getenv("REACTOR_BRANCH") or "master"
	local project_url = gitlab_url .. g_Config.Repos[repo].ID

	local token = ""
	if g_Config.Repos[repo].Token and #g_Config.Repos[repo].Token >= 10 then
		token = "&private_token=" .. g_Config.Repos[repo].Token
	end

	local commits = GetJSON(project_url .. "/repository/commits/?per_page=1&ref_name=" .. branch .. token)

	if commits[1] == nil then
		dprintf("[Warning] GetRecentCommitID() has a commits[1] value of nil")
		return nil
	end

	return commits[1].id
end

local function GetAtomList(repo, all)
	local branch = g_Config.Repos[repo].Branch or os.getenv("REACTOR_BRANCH") or "master"
	local project_url = gitlab_url .. g_Config.Repos[repo].ID

--	msg.Text = "Updating Atom List from "..repo

	local previd = g_Config.Repos[repo] and g_Config.Repos[repo].PrevCommitID
	local files = {}

	local token = ""
	if g_Config.Repos[repo].Token ~= nil and string.len(g_Config.Repos[repo].Token) >= 10 then
		token = "&private_token=" .. g_Config.Repos[repo].Token
	end

	if previd == nil or all then
		-- initial fetch
		previd = GetRecentCommitID(repo)

		local paths = GetPagedJSON(project_url .. "/repository/tree?per_page=100&path=Atoms&ref=" .. branch .. token)

		if paths then
			for i,path in ipairs(paths) do
				if path.type == "tree" then
					table.insert(files, path.path .. "/" .. path.name .. ".atom")
				end
			end
		end
	else
		-- update from commits
		local url = project_url .. "/repository/compare?per_page=100&from=" .. previd .. "&to=" .. branch .. token
		-- dprintf("[Status] GitLab GetJSON('%s')", url)
		dprintf("[Status] GitLab GetJSON('%s')", url:gsub("&private_token=.+", ""))

		local commits = GetJSON(url)
		if commits.diffs then
			local temp = {}
			for i,v in ipairs(commits.diffs) do
				if v.old_path:sub(-5):lower() == ".atom" then
					temp[v.old_path] = true
				end

				if v.new_path:sub(-5):lower() == ".atom" then
					temp[v.new_path] = true
				end
			end

			for file,_ in pairs(temp) do
				table.insert(files, file)
			end

			previd = commits.commit and commits.commit.id
		else
			local msg = "[Warning] Failed to get recent commits from ".. repo .. commits.message and "\n   " .. commits.message or ""
			dprintf(msg)
			print(msg)
		end
	end

	if previd then
		g_Config.Repos[repo].PrevCommitID = previd
	end

	return files
end

local function GetFiles(paths, repo, callbacks, cbdata)
	local branch = g_Config.Repos[repo].Branch or os.getenv("REACTOR_BRANCH") or "master"
	local token = ""
	if g_Config.Repos[repo].Token ~= nil and string.len(g_Config.Repos[repo].Token) >= 10 then
		token = "&private_token=" .. g_Config.Repos[repo].Token
	end

	local project_url = gitlab_url .. g_Config.Repos[repo].ID .. "/repository/files/"

	local urls = {}

	for i,path in ipairs(paths) do
		urls[i] = project_url .. EscapeStr(path) .. "/raw?ref=" .. branch .. token
	end

	return GetURLs(urls, false, nil, callbacks, cbdata)
end

-- Expose our module interface
return {
	-- Init =
	-- CleanUp =
	GetAtomList = GetAtomList,
	GetFiles = GetFiles,
	GetRecentCommitID = GetRecentCommitID,
}
