-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.lua.org/manual/5.1/'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

