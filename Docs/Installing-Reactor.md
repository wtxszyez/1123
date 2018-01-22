# Table Of Contents #

- [Installing Reactor](Installing-Reactor.md#installing-reactor)
	- [Installing Reactor Visually](Installing-Reactor.md#installing-reactor-visually)
	- [Installing Reactor Manually](Installing-Reactor.md#installing-reactor-manually)
	- [Uninstalling Reactor Manually](Installing-Reactor.md#uninstalling-reactor-manually)

# <a name="installing-reactor"></a>Installing Reactor #

## <a name="installing-reactor-visually"></a>Installing Reactor Visually##

The `Reactor-Installer.lua` script makes it quick and easy to set up Reactor.

**Step 1.** Drag the Reactor-Installer.lua script from your desktop into the Fusion Console tab to run it. Alternatively, you can also copy/paste the script into the Console text entry area to run it. An Install Reactor window will open. 

![Ready to Install](Images/reactor-installer-ready-to-install.png)

**Step 2.** Click the "Install and Relaunch" button. After a few seconds the Reactor Installer progress bar will appear and the installation will proceed.

![Reactor Installer Script](Images/reactor-installer-complete.png)

A Reactor.fu file will be downloaded from the Reactor GitLab repository and is saved to the Fusion user prefs location at `Config:/Reactor.fu`. The GitLab repository address string is then written into a new `AllData:Reactor:/System/Reactor.cfg` file that is used to control what GitLab repositories are used with Reactor.

When the installer finishes, Fusion will restart automatically and the Reactor Package Manager will be displayed.

![Reactor Window](Images/reactor-gui.png)

## <a name="installing-reactor-manually"></a>Installing Reactor Manually ##

If you are a studio system admin/pipeline TD and need more control over the Reactor install process you can manually download files from the GitLab repo and install the tool by yourself.

Step 1. To install Reactor, download "Reactor.fu" and place it in your Fusion `Config:/` directory.

Windows `Config:/` Installation Path:

`%appdata%\Blackmagic Design\Fusion\Config\Reactor.fu`

Mac `Config:/` Installation Path:

`$HOME/Library/Application Support/Blackmagic Design/Fusion/Config/Reactor.fu`

Linux `Config:/` Installation Path:

`$HOME/.fusion/BlackmagicDesign/Fusion/Config/Reactor.fu`

Note: `$HOME` represents your current user account's home folder.

Step 2. The next time Fusion is launched a new "Reactor" menu will be added. Selecting the Reactor > Open Reactor... menu item will open the "Fusion Reactor" Package Manager window.

![Reactor Menu](Images/reactor-menu.png)

## <a name="uninstalling-reactor-manually"></a>Uninstalling Reactor Manually ##

![Reactor Folder](Images/reactor-pathmap-folder.png)

Step 1. To uninstall Reactor from your system you need to remove the downloaded Reactor "atom" content by deleting the Reactor folder that is located in your shared Fusion `AllData:/Reactor:/` folder. 

The `AllData:/Reactor:/` folder is located here:

**Windows Reactor Path:**

`C:\ProgramData\Blackmagic Design\Fusion\Reactor\`

**Mac Reactor Path:**

`/Library/Application Support/Blackmagic Design/Fusion/Reactor/`

**Linux Reactor Path:**

`/var/BlackmagicDesign/Fusion/Reactor/`

Step 2. You should also remove the `Reactor.fu` file from your Fusion user preferences `Config:/` directory. This will stop the Reactor menu item from being added to Fusion.

Step 3. Open the Fusion Preferences window and switch to the "Global and Default Settings > PathMap" section.

![Fusion PathMap Preferences](Images/uninstall-pathmap-entries.png)

In the "User" section of the PathMap view click on the entry for the "Reactor:" PathMap. Then press the Delete button.

Scroll up to the "Defaults" section and click on the "UserPaths:" entry. Edit the text in the "To" field and remove the words ";Reactor:Deploy". Be sure to keep the rest of the settings in textfield.

Scroll up in the "Defaults" section and click on the "Scripts:" entry. Edit the text in the "To" field and remove the words ";Reactor:System/Scripts". Be sure to keep the rest of the settings that are in textfield.

Step 4. Restart Fusion. Reactor will have been cleanly removed from your system.

Last Revised 2018-01-21
