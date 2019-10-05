-- Show Config Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Config:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Config Folder] " .. path)
end

print("[Show Config Folder] " .. path)
bmd.openfileexternal("Open", path)
