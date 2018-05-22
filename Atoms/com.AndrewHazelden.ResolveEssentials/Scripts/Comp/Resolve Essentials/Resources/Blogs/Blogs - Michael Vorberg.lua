-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://wordpress.empty98.de'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

