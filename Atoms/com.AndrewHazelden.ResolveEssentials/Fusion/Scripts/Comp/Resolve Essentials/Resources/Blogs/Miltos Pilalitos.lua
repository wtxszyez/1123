-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://www.pilalitos.com'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
