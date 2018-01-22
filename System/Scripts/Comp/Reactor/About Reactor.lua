-- About Reactor menu item

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local scriptPath = app:MapPath(tostring(reactor_pathmap) .. "Reactor/System/UI/AboutWindow.lua")
if bmd.fileexists(scriptPath) == false then
  print("[Reactor Error] Open the Reactor window once to download the missing file: " .. scriptPath)
else
  ldofile(scriptPath)
end
