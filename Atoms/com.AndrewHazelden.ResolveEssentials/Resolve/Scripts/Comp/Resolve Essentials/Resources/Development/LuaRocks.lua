-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://luarocks.org'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
