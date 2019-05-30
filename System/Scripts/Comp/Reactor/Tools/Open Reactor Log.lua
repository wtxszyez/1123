-- Open Reactor Log menu item

local reactor_log = app:MapPath("Temp:/Reactor/ReactorLog.txt")
if os.getenv("REACTOR_DEBUG") ~= "true" then
	-- Logging is disabled
	print("[Reactor Log] You need to enable the \"REACTOR_DEBUG\" environment variable to turn on Reactor file logging.")
else
	if bmd.fileexists(reactor_log) == false then
		print("[Reactor Log] Log File Missing: " .. reactor_log)
	else
		bmd.openfileexternal("Open", app:MapPath(reactor_log))
		print("[Reactor Log] " .. reactor_log .. "\n")
	end
end
