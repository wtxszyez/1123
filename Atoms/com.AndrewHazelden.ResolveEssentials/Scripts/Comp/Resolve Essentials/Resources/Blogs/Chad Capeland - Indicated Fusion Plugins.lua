-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://indicated.com/blackmagic-fusion-plugins/'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

