-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://www.andrewhazelden.com/blog'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

