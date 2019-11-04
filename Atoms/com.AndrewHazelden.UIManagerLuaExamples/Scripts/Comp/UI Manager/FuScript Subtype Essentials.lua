_VERSION = 'v3 2019-11-04'
--[[--
FuScript Subtype Essentials - v3 2019-11-04
By Andrew Hazelden <andrew@andrewhazelden.com>
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

## Overview ##

Resolve Studio, Generation, Fusion Studio, the Fusion Bin Player, and the Fusion Render manager all allow for remote usage via FuScript.

This is done via FuScript using the following Lua function:
	bmd.scriptapp(host, ip, timeout, uuid, subtype)

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

## Script Output ##

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
FuScript and Subtype Essentials - v2 2019-11-02
By Andrew Hazelden <andrew@andrewhazelden.com>
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

[ScriptApp Session]
table: 0x6341c938
	FUSIONS_CLVendor = Intel
	FUSIONS_FileName = /Applications/Blackmagic Fusion 9/Fusion.app/Contents/MacOS/Fusion
	FUSIONH_CurrentComp = Composition (0x0x7f9cfa132200) [App: 'Fusion' on 127.0.0.1, UUID: dbf0dc72-c9d5-46ce-bf46-6c5c4b7f9bc6]
	FUSIONI_PhysicalRAMTotalMB = 16384
	FUSIONS_CLVersion = OpenCL 1.2  1.1
	FUSIONI_VersionLo = 131079
	FUSIONS_MachineType = IA32
	FUSIONI_PhysicalRAMFreeMB = 11041
	FUSIONI_VersionHi = 589824
	FUSIONB_IsManager = false
	FUSIONS_Version = 9.0.2
	FUSIONS_CLType = CPU
	FUSIONS_CLDevice = Intel(R) Core(TM) i7-4578U CPU @ 3.00GHz
	FUSIONI_SerialHi = XXXXXXXXX
	FUSIONI_VirtualRAMTotalMB = 16384
	FUSIONS_GLVendor = Intel Inc.
	FUSIONS_GLVersion = 2.1 INTEL-10.36.19
	FUSIONI_VirtualRAMUsedMB = 5342
	FUSIONB_IsRenderNode = false
	FUSIONS_GLDevice = Intel Iris OpenGL Engine
	FUSIONI_NumProcessors = 4
	FUSIONI_SerialLo = 0


[Comp Session]
table: 0x678962a8
	COMPN_LastFrameRendered = -2000000000
	COMPB_HiQ = true
	COMPI_RenderFlags = 131088
	COMPN_ElapsedTime = 0
	COMPN_AverageFrameTime = 0
	COMPB_Locked = false
	COMPB_Modified = false
	COMPN_TimeRemaining = 0
	COMPN_CurrentTime = 1
	COMPN_RenderEnd = 1
	COMPN_AudioOffset = 0
	COMPS_Name = LookingGlassRenderer3D.comp
	COMPN_GlobalStart = 1
	COMPI_RenderStep = 1
	COMPS_FileName = /Volumes/Media/LookingGlassRenderer3D.comp
	COMPB_Rendering = false
	COMPN_RenderStartTime = 1
	COMPN_GlobalEnd = 2
	COMPN_RenderEndTime = 1
	COMPN_RenderStart = 1
	COMPN_LastFrameTime = 0
	COMPB_Proxy = false

## Tips ##

1. You can probe the UUID value (which acts like a PID code) for multiple concurrent Fusion Studio sessions operating on a single host using:

uuid = bmd.getappuuid()
bmd.setclipboard(uuid)
print('[UUID] ' .. uuid)

A real-world UUID value looks like this:

	dbf0dc72-c9d5-46ce-bf46-6c5c4b7f9bc6

An empty UUID value of zero (0) can be used if you don't want to use the UUID property.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


2. You can probe the active FuScript hosted systems on your network using:

	dump(bmd.pinghosts())
	
	or
	
	==bmd.pinghosts()

The "bmd.pinghosts()" function returns a result table with content like this:

table: 0x64c550d8
1 = table: 0x64c55120
	HostName = Pine.local
	IP = 10.20.30.82
	Hosts = table: 0x64c54f88
		1 = FusionServer
		2 = Fusion
		3 = Fusion
		4 = StudioPlayer
	UserName = andrew
	Platform = macOS
	Version = 9.0.2

3. When using the bmd.scriptapp() Function, the host argument could be a string like:

Fusion
Resolve
Generation
StudioPlayer
FusionServer

When you are inside of the host app's Fusion console or a tool/comp script you can run this command to print back the active host app name:

dump(GetAppName())

In Fusion Studio you would get back a value of "Fusion" when you run that code snippet. 

And Yes. That snippet is written correctly. There is no bmd prefix needed to run the "GetAppName()" function.

--]]--

-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

print('\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
print('FuScript and Subtype Essentials - ' ..  tostring(_VERSION))
print('By Andrew Hazelden <andrew@andrewhazelden.com>')
print('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n\n')

-- bmd.scriptapp() Connection settings

-- Choose which API you want to connect to (Fusion vs Resolve)
-- Link to the Fusion() API in a comp session
local host = 'Fusion'

-- Links to Resolve() API in a Resolve video editing session
-- local host = 'Resolve'

-- You also have the option to binding against these APIs too:
-- local host = 'Generation'
-- local host = 'StudioPlayer'
-- local host = 'FusionServer'

-- The remote system's IP address or domain name for FuScript to connect to
-- For your own system the "localhost" value can also be "127.0.0.1"
local ip = '127.0.0.1'

-- (Optional) Define a timeout value should the connection request fail
local timeout = 0.0

-- (Optional) Define which Fusion session you want to connect to - If multiple are running on the same computer
local uuid = 0

-- A sub-type is the type of FuScript process you are connecting to on the remote system:
-- local subtype = 'Resolve' -- Resolve GUI session
local subtype = 'Interactive' -- Fusion GUI session
-- local subtype = 'Bins' -- Fusion Studio Bin window
-- local subtype = 'Playback'-- Fusion Studio Bin - Playback window
-- local subtype = 'RenderManager' -- Fusion Studio Render Manager GUI (master)
-- local subtype = 'RenderManagerLite' -- Fusion (Free)  Render Manager GUI (master)
-- local subtype = 'Renderer' -- A Fusion render node (slave)
-- local subtype = 'RendererLite' -- A Fusion (Free) GUI render session (slave)


-- Connection parameters: bmd.scriptapp(host, ip, timeout, uuid, subtype)
local remoteFu = bmd.scriptapp(host, ip, timeout, uuid, subtype)

if remoteFu then
	-- List the scriptapp session details
	print('\n[ScriptApp Session]')
	dump(remoteFu:GetAttrs())

	if host == 'Fusion' then
		-- List the comp session details
		remoteComp = remoteFu.CurrentComp
		if remoteComp then
			print('\n[Comp Session]')
			dump(remoteComp:GetAttrs())
		end
	end
else
	print('[Error] Failed to connect to ' .. tostring(subtype) .. '@' .. tostring(ip) .. '.')
end

print('\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
print('[Done]')
