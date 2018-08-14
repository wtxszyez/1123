-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://www.comp-fu.com/tag/Fusion/'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

