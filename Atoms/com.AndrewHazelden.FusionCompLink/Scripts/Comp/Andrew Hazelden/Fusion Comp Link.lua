--[[--
Fusion Comp Link v1 - 2018-05-27
By Andrew Hazelden <andrew@andrewhazelden.com>

The Fusion Comp Link script can be run from inside of Fusion Studio or Resolve Studio.

It will then read the counterpart program's active composite data and import it into the foreground Fusion session. This lets you quickly migrate a composite between the two programs.
--]]--

-- Check if Fusion Standalone or the Resolve Fusion page is active
hostPath = fusion:MapPath('Fusion:/')
if string.lower(hostPath):match('resolve') then
	activeHost = 'Resolve'
	remoteHost = 'Interactive'
else
	activeHost = 'Fusion'
	remoteHost = 'Resolve'
end
print('[Active Host] ' .. tostring(activeHost) .. ' [Remote Host] '.. tostring(remoteHost) .. '\n')

-- Connection parameters: bmd.scriptapp('Resolve', ip, timeout, uuid, subtype)
remoteFu = bmd.scriptapp('Fusion', '127.0.0.1', 0.0, 0, remoteHost)
if remoteFu then
	remoteComp = remoteFu.CurrentComp

	-- List the comp details
	-- dump(remoteFu:GetAttrs())
	-- dump(remoteComp:GetAttrs())

	-- Get all of the nodes in the comp
	tools = remoteComp:GetToolList(false)
	-- Get the selected nodes in the comp
	-- tools = remoteComp:GetToolList(true)

	-- Check if any nodes were selected
	if #tools > 0 then
		-- Add the Resolve nodes to the clipboard
		remoteComp:Copy(tools)
		wait(0.1)

		-- Paste the clipboard into the Fusion Studio comp 
		comp:Paste()
	end
else
	print('[Error] Failed to connect to ' .. tostring(remoteHost) .. '.')
end