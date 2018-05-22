-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/user/eyeonsoftware/playlists'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

