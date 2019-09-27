-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://documents.blackmagicdesign.com/Fusion/20160317-c992b2/Fusion_8_Scripting_Guide.pdf'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
