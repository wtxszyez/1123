-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://fusiontrainer.de'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

