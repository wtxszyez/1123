-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
