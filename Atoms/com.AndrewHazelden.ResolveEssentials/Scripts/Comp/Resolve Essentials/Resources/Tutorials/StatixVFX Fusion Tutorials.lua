-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/channel/UCTCeDas53OEcWcRujkQiwLg'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

