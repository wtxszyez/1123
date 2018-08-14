-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/playlist?list=PLURZdvzBgI3qJIffECftVTcRY4V6P2MOE'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

