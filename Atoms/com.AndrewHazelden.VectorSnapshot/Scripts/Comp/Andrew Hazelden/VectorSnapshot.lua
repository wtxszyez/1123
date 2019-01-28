--[[--
----------------------------------------------------------------------------
VectorSnapshot v1 2019-01-27
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com
----------------------------------------------------------------------------

## Overview ##

The VectorSnapshot script generates an SVG vector traced version of an image. This is handy if you want to convert a raster based rotoscoping mask back into a vector SVG image that you can import into Fusion.


## Install ##

Step 1. Use the WSL Reactor package manager to add the "Scripts/Comp/VectorSnapshot" atom.

## Usage ##

Step 1. Load a node into the Fusion's left image viewer.

Step 2. Select the "Script > Andrew Hazelden > VectorSnapshot" menu item.

Step 3. Open the SVG image that was exported to the "Temp:/Fusion/" PathMap folder.


## POTRACE CLI OPTIONS ##

You can fully customize the potrace CLI commands used to vectorize the output by editing the line of Lua code that starts with:

potraceOptions = '--group --invert'


Usage: potrace [options] [filename...]
General options:
 -h, --help                 - print this help message and exit
 -v, --version              - print version info and exit
 -l, --license              - print license info and exit
File selection:
 <filename>                 - an input file
 -o, --output <filename>    - write all output to this file
 --                         - end of options; 0 or more input filenames follow
Backend selection:
 -b, --backend <name>       - select backend by name
 -b svg, -s, --svg          - SVG backend (scalable vector graphics)
 -b pdf                     - PDF backend (portable document format)
 -b pdfpage                 - fixed page-size PDF backend
 -b eps, -e, --eps          - EPS backend (encapsulated PostScript) (default)
 -b ps, -p, --postscript    - PostScript backend
 -b pgm, -g, --pgm          - PGM backend (portable greymap)
 -b dxf                     - DXF backend (drawing interchange format)
 -b geojson                 - GeoJSON backend
 -b gimppath                - Gimppath backend (GNU Gimp)
 -b xfig                    - XFig backend
Algorithm options:
 -z, --turnpolicy <policy>  - how to resolve ambiguities in path decomposition
 -t, --turdsize <n>         - suppress speckles of up to this size (default 2)
 -a, --alphamax <n>         - corner threshold parameter (default 1)
 -n, --longcurve            - turn off curve optimization
 -O, --opttolerance <n>     - curve optimization tolerance (default 0.2)
 -u, --unit <n>             - quantize output to 1/unit pixels (default 10)
 -d, --debug <n>            - produce debugging output of type n (n=1,2,3)
Scaling and placement options:
 -P, --pagesize <format>    - page size (default is letter)
 -W, --width <dim>          - width of output image
 -H, --height <dim>         - height of output image
 -r, --resolution <n>[x<n>] - resolution (in dpi) (dimension-based backends)
 -x, --scale <n>[x<n>]      - scaling factor (pixel-based backends)
 -S, --stretch <n>          - yresolution/xresolution
 -A, --rotate <angle>       - rotate counterclockwise by angle
 -M, --margin <dim>         - margin
 -L, --leftmargin <dim>     - left margin
 -R, --rightmargin <dim>    - right margin
 -T, --topmargin <dim>      - top margin
 -B, --bottommargin <dim>   - bottom margin
 --tight                    - remove whitespace around the input image
Color options, supported by some backends:
 -C, --color #rrggbb        - set foreground color (default black)
 --fillcolor #rrggbb        - set fill color (default transparent)
 --opaque                   - make white shapes opaque
SVG options:
 --group                    - group related paths together
 --flat                     - whole image as a single path
Postscript/EPS/PDF options:
 -c, --cleartext            - do not compress the output
 -2, --level2               - use postscript level 2 compression (default)
 -3, --level3               - use postscript level 3 compression
 -q, --longcoding           - do not optimize for file size
PGM options:
 -G, --gamma <n>            - gamma value for anti-aliasing (default 2.2)
Frontend options:
 -k, --blacklevel <n>       - black/white cutoff in input file (default 0.5)
 -i, --invert               - invert bitmap
Progress bar options:
 --progress                 - show progress bar
 --tty <mode>               - progress bar rendering: vt100 or dumb

Dimensions can have optional units, e.g. 6.5in, 15cm, 100pt.
Default is inches (or pixels for pgm, dxf, and gimppath backends).
Possible input file formats are: pnm (pbm, pgm, ppm), bmp.
Backends are: svg, pdf, pdfpage, eps, postscript, ps, dxf, geojson, pgm,
gimppath, xfig.

--]]--


-- Find out if we are running Fusion 7, 8, 9, or 15
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Get the file extension from a filepath
function getExtension(mediaDirName)
	local extension = ''
	if mediaDirName then
		extension = string.match(mediaDirName, '(%..+)$')
	end
	
	return extension or ''
end

-- Get the base filename from a filepath
function getFilename(mediaDirName)
	local path, basename = ''
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	
	return basename or ''
end

-- Get the base filename without the file extension or frame number from a filepath
function getFilenameNoExt(mediaDirName)
	local path, basename,name, extension, barename, sequence = ''
	if mediaDirName then
	path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
		if basename then
			name, extension = string.match(basename, '^(.+)(%..+)$')
			if name then
				barename, sequence = string.match(name, '^(.-)(%d+)$')
			end
		end
	end
	
	return barename or ''
end

-- Get the base filename with the frame number left intact
function getBasename(mediaDirName)
	local path, basename,name, extension, barename, sequence = ''
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
		if basename then
			name, extension = string.match(basename, '^(.+)(%..+)$')
			if name then
				barename, sequence = string.match(name, '^(.-)(%d+)$')
			end
		end
	end
	
	return name or ''
end

-- Get the file path
function getPath(mediaDirName)
	local path, basename
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	
	return path or ''
end

-- Remove the trailing file extension off a filepath
function trimExtension(mediaDirName)
	local path, basename
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	return path or '' .. basename or ''
end

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end

-- Open a folder window up using your desktop file browser
function openDirectory(mediaDirName)
	command = nil
	dir = dirname(mediaDirName)
	
	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. dir .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. dir .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'nautilus "' .. dir .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
print('[VectorSnapshot]')

-- Four digit frame padding
padding = '%04d'

-- Lock the comp flow area
comp:Lock()

-- List the selected Node in Fusion 
if not tool then
	tool = comp.ActiveTool
end

local selectedNode = tool
if selectedNode then
	toolAttrs = selectedNode:GetAttrs()
	
	-- Write out a temporary viewer snapshot so the script can send any kind of node to the viewer tool
	viewportSnapshotImageFormat = 'bmp'
	
	-- Get the timeline frame
	currentFrame = comp:GetAttrs().COMPN_CurrentTime
	
	-- Image name with extension.
	imageFilename = 'vector_export_' .. selectedNode.Name .. '.' .. string.format(padding, currentFrame) .. '.' .. viewportSnapshotImageFormat
	
	-- Find out the Fusion temporary directory path
	-- dirName = comp:MapPath('Comp:/SVG/')
	dirName = comp:MapPath('Temp:/Fusion/')
	
	-- Create the temporary directory
	os.execute('mkdir "' .. dirName .. '"')
	
	-- Create the image filepath for the temporary view snapshot
	localFilepath = dirName .. imageFilename
	
	if fu_major_version >= 15 then
		-- Resolve 15 workflow for saving an image
		comp:GetPreviewList().LeftView.View.CurrentViewer:SaveFile(localFilepath)
	elseif fu_major_version >= 8 then
		-- Fusion 8 workflow for saving an image
		comp:GetPreviewList().Left.View.CurrentViewer:SaveFile(localFilepath)
	else
		-- Fusion 7 workflow for saving an image
		-- Save the image in the Viewer A buffer
		comp.CurrentFrame.LeftView.CurrentViewer:SaveFile(localFilepath)
	end
	
	-- Everything worked fine and an image was saved
	print('[Saved Image] ', localFilepath ,' [Selected Node] ', selectedNode.Name)
	
	-- This is the image on disk
	imageFilename = localFilepath

	-- Output filename
	vectorFilename = getPath(imageFilename) .. getBasename(imageFilename) .. '.svg'
	
	-- Verify the file exists
	if eyeon.fileexists(imageFilename) then
		-- potrace CLI Executable path
		potracePath = ''
		potraceOptions = ''
		if platform == 'Windows' then
			potracePath = 'start "" "' ..  app:MapPath('Reactor:/Deploy/Bin/potrace/bin/potrace.exe') .. '" '
		else
			potracePath = '"' .. app:MapPath('Reactor:/Deploy/Bin/potrace/bin/potrace') .. '" '
		end
		
		-- Group the output and invert the black and white regions
		potraceOptions = '--group --invert'
		
		potraceCommand = potracePath .. ' --debug 3 --tty dumb ' .. potraceOptions .. ' -b svg "' .. imageFilename .. '" --output "' .. vectorFilename .. '"'
		
		print('[Launch Command] ' .. potraceCommand)
		os.execute(potraceCommand)
	else
		print('[Viewport Exported File Missing] ', imageFilename)
	end
	
	-- Open the output folder
	if fu_major_version >= 8 then
		-- The script is running on Fusion 8+ so we will use the fileexists command
		if eyeon.fileexists(dirName) then
			openDirectory(dirName)
		else
			print('[Temporary Directory Missing] ', dirName)
			err = true
		end
	else
		-- The script is running on Fusion 6/7 so we will use the direxists command
		if eyeon.direxists(dirName) then
			openDirectory(dirName)
		else
			print('[Temporary Directory Missing] ', dirName)
			err = true
		end
	end
end

-- Unlock the comp flow area
comp:Unlock()

print('[Done]')
