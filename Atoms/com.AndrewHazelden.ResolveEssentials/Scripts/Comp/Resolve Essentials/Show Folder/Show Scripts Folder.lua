-- Show Scripts Folder menu item

local path = app:MapPath("Scripts:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Scripts Folder] " .. path)
end

print("[Show Scripts Folder] " .. path)
bmd.openfileexternal("Open", path)
