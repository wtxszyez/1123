-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://documents.blackmagicdesign.com/DaVinciResolve/20180419-520cf4/DaVinci_Resolve_15_New_Features_Guide.pdf'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
