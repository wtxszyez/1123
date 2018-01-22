_version = 'v1.0 2017-11-14'
--[[--
----------------------------------------------------------------------------
GetScriptDir v1.0 2017-11-14
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
-- scriptTable = GetScriptDir()
function GetScriptDir()
  return bmd.parseFilename(string.sub(debug.getinfo(1).source, 2))
end

-- The Main Function
function Main()
	print('[Lua Script Filename Table]');
	fileTable = GetScriptDir()
	dump(fileTable)
	
	print('\n')
	print('[Current Lua Script Filepath] ' .. fileTable.FullPath)
	print('[Current Lua Script Folder] ' .. fileTable.Path)
	print('[Current Lua Script File Name] ' .. fileTable.FullName)
	print('[Current Lua Script Basename No Extension] ' .. fileTable.Name)
end

Main()
print('[Done]')
