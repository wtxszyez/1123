-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://forum.blackmagicdesign.com/viewforum.php?f=21'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

