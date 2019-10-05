-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://docs.python.org/3/'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

