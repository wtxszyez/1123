-- The URL for the cURL based download:
local sourceURL = [[https://www.steakunderwater.com/wesuckless/index.php]]

-- The filepath for saving the downloaded asset 
local fuDestFile = comp:MapPath("Temp:/") .. "we-suck-less.html"

-- Set up cURL to work with Fusion 9.0.1
ffi = require "ffi"
curl = require "lj2curl"
ezreq = require "lj2curl.CRLEasyRequest"
local req = ezreq(sourceURL)
local body = {}
req:setOption(curl.CURLOPT_SSL_VERIFYPEER, 0)
req:setOption(curl.CURLOPT_WRITEFUNCTION, ffi.cast("curl_write_callback",
 function(buffer, size, nitems, userdata) 
	table.insert(body, ffi.string(buffer, size*nitems))
	return nitems
 end))

-- Download the file from the "sourceURL" address
print('[Downloading] ' .. sourceURL)
ok, err = req:perform()
if ok then
	-- Write the file to disk
	local file = io.open(fuDestFile, "w")
	file:write(table.concat(body));
	file:close();
	
	-- Show the file we just downloaded in the default HTML viewer on your system:
	print('[Opening File] ' .. fuDestFile)
	bmd.openfileexternal('Open', fuDestFile)
end
