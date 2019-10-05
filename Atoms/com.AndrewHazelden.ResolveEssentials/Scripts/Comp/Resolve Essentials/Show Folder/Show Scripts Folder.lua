-- Show Scripts Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Scripts:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Scripts Folder] " .. path)
end

print("[Show Scripts Folder] " .. path)
bmd.openfileexternal("Open", path)
