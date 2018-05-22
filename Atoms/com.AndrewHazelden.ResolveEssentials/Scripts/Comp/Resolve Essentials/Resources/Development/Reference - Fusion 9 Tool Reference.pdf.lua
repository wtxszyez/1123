-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://documents.blackmagicdesign.com/Fusion/20170801-2d196b/Fusion_9_Tool_Reference.pdf'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
