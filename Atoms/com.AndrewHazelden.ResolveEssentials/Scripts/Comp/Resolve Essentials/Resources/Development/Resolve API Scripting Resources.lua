-- Resolve Scripting Resources menu item

-- Check the current operating system platform
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

if platform == 'Windows' then
	path = 'C:\\ProgramData\\Blackmagic Design\\DaVinci Resolve\\Support\\Developer\\Scripting\\'
elseif platform == 'Mac' then
	path = '/Library/Application Support/Blackmagic Design/DaVinci Resolve/Developer/Scripting/'
elseif platform == 'Linux' then
	path = '/opt/resolve/Developer/Scripting/'
end

if bmd.direxists(path) then
	print("[Resolve Scripting Resources Folder] " .. path)
	bmd.openfileexternal("Open", path)
else
	print("[Resolve Scripting Resources Folder] [Folder Missing] " .. path)
end

