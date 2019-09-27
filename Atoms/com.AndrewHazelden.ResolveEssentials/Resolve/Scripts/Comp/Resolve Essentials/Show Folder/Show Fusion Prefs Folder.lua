-- Show Fusion Prefs Folder menu item

local path = app:MapPath("UserData:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created UserData Folder] " .. path)
end

print("[Show UserData Folder] " .. path)
bmd.openfileexternal("Open", path)
