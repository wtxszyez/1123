_version = 'v1.1 2018-05-15'
--[[--
----------------------------------------------------------------------------
GetScriptDir v1.1 2018-05-15
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com
----------------------------------------------------------------------------

Overview:
A simple Lua script example that returns the current directory name for the Lua script that is being run.

Result:
[Lua Script Filename Table]
table: 0x0d238800
	Path = /Users/andrew/Library/Application Support/Blackmagic Design/Fusion/Scripts/Comp/
	FullName = GetScriptDir.lua
	UNC = false
	CleanName = GetScriptDir
	SNum = 
	Extension = .lua
	Name = GetScriptDir
	FullPath = /Users/andrew/Library/Application Support/Blackmagic Design/Fusion/Scripts/Comp/GetScriptDir.lua


[Current Lua Script Filepath] /Users/andrew/Library/Application Support/Blackmagic Design/Fusion/Scripts/Comp/GetScriptDir.lua
[Current Lua Script Folder] /Users/andrew/Library/Application Support/Blackmagic Design/Fusion/Scripts/Comp/
[Current Lua Script File Name] GetScriptDir.lua
[Current Lua Script Basename No Extension] GetScriptDir
--]]--

------------------------------------------------------------------------
-- Return a string with the directory path where the Lua script was run from
-- If the script is run by pasting it directly into the Fusion Console define a fallback path
-- fileTable = GetScriptDir('Reactor:/Deploy/Scripts/Comp/UI Manager/GetScriptDir.lua')
function GetScriptDir(fallback)
	if debug.getinfo(1).source == '???' then
		-- Fallback absolute filepath
		return parseFilename(app:MapPath(fallback))
	else
		-- Filepath coming from the Lua script's location on disk
		return parseFilename(app:MapPath(string.sub(debug.getinfo(1).source, 2)))
	end
end


------------------------------------------------------------------------------
-- parseFilename() from bmd.scriptlib
--
-- this is a great function for ripping a filepath into little bits
-- returns a table with the following
--
-- FullPath	: The raw, original path sent to the function
-- Path		: The path, without filename
-- FullName	: The name of the clip w\ extension
-- Name     : The name without extension
-- CleanName: The name of the clip, without extension or sequence
-- SNum		: The original sequence string, or "" if no sequence
-- Number 	: The sequence as a numeric value, or nil if no sequence
-- Extension: The raw extension of the clip
-- Padding	: Amount of padding in the sequence, or nil if no sequence
-- UNC		: A true or false value indicating whether the path is a UNC path or not
------------------------------------------------------------------------------
function parseFilename(filename)
	local seq = {}
	seq.FullPath = filename
	string.gsub(seq.FullPath, "^(.+[/\\])(.+)", function(path, name) seq.Path = path seq.FullName = name end)
	string.gsub(seq.FullName, "^(.+)(%..+)$", function(name, ext) seq.Name = name seq.Extension = ext end)

	if not seq.Name then -- no extension?
		seq.Name = seq.FullName
	end

	string.gsub(seq.Name, "^(.-)(%d+)$", function(name, SNum) seq.CleanName = name seq.SNum = SNum end)

	if seq.SNum then
		seq.Number = tonumber(seq.SNum)
		seq.Padding = string.len(seq.SNum)
	else
	   seq.SNum = ""
	   seq.CleanName = seq.Name
	end

	if seq.Extension == nil then seq.Extension = "" end
	seq.UNC = (string.sub(seq.Path, 1, 2) == [[\\]])

	return seq
end

-- The Main Function
function Main()
	print('[Lua Script Filename Table]');
	fileTable = GetScriptDir('Reactor:/Deploy/Scripts/Comp/UI Manager/GetScriptDir.lua')
	dump(fileTable)
	
	print('\n')
	print('[Current Lua Script Filepath] ' .. fileTable.FullPath)
	print('[Current Lua Script Folder] ' .. fileTable.Path)
	print('[Current Lua Script File Name] ' .. fileTable.FullName)
	print('[Current Lua Script Basename No Extension] ' .. fileTable.Name)
end

Main()
print('[Done]')
