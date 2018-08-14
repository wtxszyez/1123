-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.steakunderwater.com'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

