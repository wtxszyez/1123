-- Resync Repository menu item

local separator = package.config:sub(1,1)
-- Check for a pre-existing PathMap preference
local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
	-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
	reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. separator .. "$", "")
end

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
local scriptPath = app:MapPath(tostring(reactor_pathmap) .. "Reactor/System/UI/ResyncRepository.lua")
if bmd.fileexists(scriptPath) == false then
	print("[Reactor Error] Open the Reactor window once to download the missing file: " .. scriptPath)
else
	ldofile(scriptPath)
end
