--[[--
Ping SlashCommand - v1.0 2018-01-11
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

Ping is a console slash command that runs a network ping check. This can be used if you are having networking issues with your Fusion render nodes.

This script requires Fusion 9.0.1+ and the SlashCommand.fuse to be installed.

## Installation ##

Step 1. Copy the "ping.lua" file to the Fusion "Scripts:/SlashCommand/" folder.

Step 2. Install a copy of the "SlashCommand.fuse" using the WeSuckLess forum's "Reactor" package manager. This atom package is found in the Reactor "Console" category.

Step 3. Restart Fusion. The SlashCommand.fuse module will load and then you can use the Ping Slash Command

## Usage ##

Step 1. Switch to the Fusion Console tab.

Step 2. To run a network ping command type in:

/ping <hostname>

/ping google.com

If you wanted to ping your own system you could use:

/ping localhost

or you can simply type in "/ping" with no address specified to achieve the same result

If you are on Mac/Linux you can ping your whole subnet using the "255.255.255.255" broadcast address:

/ping 255.255.255.255

## Output Example ## 

Check the ping time to Google via the internet:

> /ping google.com
PING google.com (173.237.125.21): 56 data bytes
64 bytes from 173.237.125.21: icmp_seq=0 ttl=58 time=18.836 ms
64 bytes from 173.237.125.21: icmp_seq=1 ttl=58 time=18.592 ms
64 bytes from 173.237.125.21: icmp_seq=2 ttl=58 time=17.990 ms

--- google.com ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 17.990/18.473/18.836/0.356 ms

Scan a subnet to see all the nodes (Mac/Linux):

> /ping 255.255.255.255
PING 255.255.255.255 (255.255.255.255): 56 data bytes
64 bytes from 10.20.30.82: icmp_seq=0 ttl=64 time=0.088 ms
64 bytes from 10.20.30.101: icmp_seq=0 ttl=64 time=0.591 ms
64 bytes from 10.20.30.80: icmp_seq=0 ttl=64 time=0.601 ms
64 bytes from 10.20.30.100: icmp_seq=0 ttl=64 time=1.185 ms
64 bytes from 10.20.30.107: icmp_seq=0 ttl=64 time=1.196 ms


--- 255.255.255.255 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.049/0.621/1.198/0.436 ms

--]]--

-- Check what platform this script is running on
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Ping a server address
-- Example: ping('localhost')
function ping(ipaddress)
	local commandString = ''
	if ipaddress ~= nil then
		if platform == 'Windows' then
			commandString = 'ping -n 3 '
		else
			commandString = 'ping -c 3 -i 0.5 '
		end

		local handler = io.popen(commandString .. ipaddress)
		local response = handler:read('*a')
		print(response)
	else
		print('[Warning] The Hostname is a nil value.')
	end
end

------------------------------------------------------------------------
-- The Main Function
function Main()
	-- Check the slash command user input
	if args ~= nil and args[2] ~= nil then
		-- Read the server address
		ping(args[2])
	else
		-- Fallback to pinging the localhost if no address is specified
		ping('localhost')
	end
end

-- Run the main function
Main()
