-- Show Macros Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Macros:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Macros Folder] " .. path)
end

print("[Show Macros Folder] " .. path)
bmd.openfileexternal("Open", path)
