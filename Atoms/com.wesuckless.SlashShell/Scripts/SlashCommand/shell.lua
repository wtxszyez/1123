--[[--
A console slash command to execute shell/terminal commands.

## Usage ##

Step 1. Switch to the Fusion Console tab.

Step 2. To run a terminal command type in:
/shell <command> <options>

Print the current directory (Mac/Linux):
/shell pwd

List the directory contents (Mac/Linux):
/shell ls ~/Documents/

List the directory contents (Windows):
/shell dir %USERPROFILE%\Documents\

Print the current environment variables (Windows):
/shell set

Print the current environment variables (Mac/Linux):
/shell env

Open the current folder in a new Explorer folder browsing window (Windows):
/shell explorer .\

Open the current folder in a new Finder folder browsing window (Mac):
/shell open ./

<p>Open the current folder in a new Nautilus folder browsing window (Linux):
/shell nautilus ./

Run wget to download a file (Mac/Linux):
/shell wget 'https://www.steakunderwater.com/wesuckless/images/smilies/icon_e_smile.gif'

--]]--

local cmd = args[0]:gsub("^[^ ]+ ", "")

print(io.popen(cmd):read("*all"))
