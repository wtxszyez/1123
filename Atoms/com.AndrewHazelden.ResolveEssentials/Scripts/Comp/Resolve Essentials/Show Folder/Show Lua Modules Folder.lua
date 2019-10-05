-- Show Lua Modules Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("LuaModules:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Lua Modules Folder] " .. path)
end

print("[Show Lua Modules Folder] " .. path)
bmd.openfileexternal("Open", path)
