--[[--
Composite Export for Resolve - v1 2018-03-16
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

The "Composite Export" hotkey exports the current comp to disk from Resolve.

## Installation ##

Step 1. Move the "Composite Export.lua" file into the Resolve Fusion page user prefs "Scripts:/Tool" folder.

## Usage ##

The "Composite Export" Tool script makes it easy to export the current Fusion page comp to disk.

--]]--

if comp then
	print('[Composite Export]')
	comp:SaveCopyAs()
else
	print('[Composite Export] Please open a Fusion Page compositing session.')
end
