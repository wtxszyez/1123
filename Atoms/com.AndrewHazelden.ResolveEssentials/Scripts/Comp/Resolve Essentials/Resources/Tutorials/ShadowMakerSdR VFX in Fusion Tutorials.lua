-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/playlist?list=PLPwJdYgVSj-S7wSlxuU3_m4BL99KxLyX1'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

