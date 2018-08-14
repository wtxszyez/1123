-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.blackmagicdesign.com/products/fusion/'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
