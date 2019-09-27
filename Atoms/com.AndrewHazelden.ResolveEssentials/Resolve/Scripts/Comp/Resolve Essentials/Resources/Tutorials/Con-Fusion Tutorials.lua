-- Open a webpage URL in the default web browser
if bmd.openurl then
	url = 'https://www.youtube.com/channel/UCL-EHsqaMSF28Fmo-m3Ja8Q'
	bmd.openurl(url)
	print('[Opening URL] ' .. url .. '\n')
end

