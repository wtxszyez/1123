-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.steakunderwater.com/wesuckless/viewforum.php?f=6'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

