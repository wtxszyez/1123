-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://gitlab.com/WeSuckLess/Reactor'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

