-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://twitter.com/Blackmagic_News'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
