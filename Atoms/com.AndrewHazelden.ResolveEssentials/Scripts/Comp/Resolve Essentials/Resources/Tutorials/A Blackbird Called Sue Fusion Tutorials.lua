-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/channel/UCysXflqUMpUxOf1fiqDjn6Q/videos'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

