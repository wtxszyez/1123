-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'http://documents.blackmagicdesign.com/DaVinciResolve/20180404-10399d/DaVinci_Resolve_15_Feature_Comparison.pdf'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end
