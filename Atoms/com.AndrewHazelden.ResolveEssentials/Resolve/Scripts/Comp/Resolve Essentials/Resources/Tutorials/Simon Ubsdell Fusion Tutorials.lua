-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/playlist?list=PLeZvvhzFi_ZxQaF4u5D_YqqM6_nf974rP'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

