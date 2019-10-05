-- Show Temp Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Temp:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Temp Folder] " .. path)
end

print("[Show Temp Folder] " .. path)
bmd.openfileexternal("Open", path)
