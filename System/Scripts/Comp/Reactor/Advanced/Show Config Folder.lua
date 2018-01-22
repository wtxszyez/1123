-- Show Config Folder menu item

local path = app:MapPath("Config:/")
if bmd.direxists(path) == false then
  bmd.createdir(path)
  print("[Created Reactor Folder] " .. path)
end

print("[Show Config Folder] " .. path)
bmd.openfileexternal("Open", path)