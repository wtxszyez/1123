-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.steakunderwater.com/wesuckless/viewtopic.php?f=6&t=1411'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

