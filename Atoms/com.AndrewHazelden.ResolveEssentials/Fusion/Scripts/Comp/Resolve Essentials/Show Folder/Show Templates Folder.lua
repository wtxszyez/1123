-- Show Templates Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Templates:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Templates Folder] " .. path)
end

print("[Show Templates Folder] " .. path)
bmd.openfileexternal("Open", path)
