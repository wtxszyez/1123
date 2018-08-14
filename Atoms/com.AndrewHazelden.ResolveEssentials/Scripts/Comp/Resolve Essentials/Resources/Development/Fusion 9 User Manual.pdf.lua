-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://documents.blackmagicdesign.com/Fusion/20170801-677839/Fusion_9_User_Manual.pdf'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
