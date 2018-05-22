-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.steakunderwater.com/wesuckless/viewtopic.php?f=32&t=1814'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

