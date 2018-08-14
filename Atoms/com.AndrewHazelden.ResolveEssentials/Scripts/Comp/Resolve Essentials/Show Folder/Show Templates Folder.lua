-- Show Templates Folder menu item

local path = app:MapPath("Templates:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Templates Folder] " .. path)
end

print("[Show Templates Folder] " .. path)
bmd.openfileexternal("Open", path)
