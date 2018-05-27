# Reactor Documentation #


## <a name="overview"></a>Overview ##
Reactor is a package manager created by the [We Suck Less Community](https://www.steakunderwater.com/wesuckless/viewforum.php?f=32) for Fusion and Resolve. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.


![Reactor GUI](Docs/Images/reactor-gui.png)

## Table Of Contents ##

- [Overview](#overview)
- [Installing Reactor](Docs/Installing-Reactor.md#installing-reactor)
	- [Installing Reactor Visually](Docs/Installing-Reactor.md#installing-reactor-visually)
	- [Installing Reactor Manually](Docs/Installing-Reactor.md#installing-reactor-manually)
	- [Using Reactor Content on a Render Node](Docs/Installing-Reactor.md#using-reactor-content-on-a-rendernode)
		- [Fusion Render Node Preference File](Docs/Installing-Reactor.md#fusion-render-node-preference-file)
	- [Uninstalling Reactor Manually](Docs/Installing-Reactor.md#uninstalling-reactor-manually)
- [Using Reactor](Docs/Using-Reactor.md)
	- [Overview](Docs/Using-Reactor.md#overview)
	- [Opening Reactor Window](Docs/Using-Reactor.md#opening-reactor-window)
	- [Using the Reactor Package Manager](Docs/Using-Reactor.md#using-the-reactor-package-manager)
	- [Installing Atom Packages](Docs/Using-Reactor.md#installing-atom-packages)
	- [Updating Atom Packages](Docs/Using-Reactor.md#updating-atom-packages)
	- [Removing Atom Packages](Docs/Using-Reactor.md#removing-atom-packages)
		- [Removing Plugins on Windows](Docs/Using-Reactor.md#removing-plugins-on-windows)
	- [Searching for Atom Packages](Docs/Using-Reactor.md#searching-for-atom-packages)
	- [Reactor Categories Explained](Docs/UsingReactor.md#reactor-categories-explained)
	- [Resync Repository](Docs/Using-Reactor.md#resync-repository)
		- [What is a PrevCommitID Value](Docs/Using-Reactor.md#what-is-a-prevcommitid-value)
- [Creating Atom Packages](Docs/Creating-Atom-Packages.md#creating-atom-packages)
	- [Adding a Description to an Atom Package](Docs/Creating-Atom-Packages.md#adding-a-description-to-an-atom-package)
	- [HTML Encoded Entity Characters](Docs/Creating-Atom-Packages.md#html-encoded-entity-characters)
	- [Adding Emoticon Images to the Description](Docs/Creating-Atom-Packages.md#adding-emoticon-images-to-the-description)
	- [Using Atomizer to Edit Your Atoms](Docs/Creating-Atom-Packages.md#using-atomizer-to-edit-your-atoms)
	- [Adding a Category to an Atom Package](Docs/Creating-Atom-Packages.md#adding-a-category-to-an-atom-package)
	- [Adding a Required Donation to an Atom Package](Docs/Creating-Atom-Packages.md#adding-a-required-donation-to-an-atom-package)
		- [PayPal.me Links](Docs/Creating-Atom-Packages.md#paypal-me-links)
		- [WWW Links](Docs/Creating-Atom-Packages.md#www-links)
		- [Email Links](Docs/Creating-Atom-Packages.md#email-links)
		- [Bitcoin Links](Docs/Creating-Atom-Packages.md#bitcoin-links)
	- [Adding a Deploy Platform Requirement](Docs/Creating-Atom-Packages.md#adding-a-deploy-platform-requirement)
		- [Platform Specific Deploy Entries](Docs/Creating-Atom-Packages.md#platform-specific-deploy-entries)
	- [Adding a Package Dependency](Docs/Creating-Atom-Packages.md#adding-a-package-dependency)
	- [Adding Documentation](Docs/Creating-Atom-Packages.md#adding-documentation)
	- [Adding Fusion Minimum/Maximum Compatibility](Docs/Creating-Atom-Packages.md#adding-fusion-minimum-maximum-compatibility)
	- [InstallScripts and UninstallScript](Docs/Creating-Atom-Packages.md#installscripts-and-uninstallscripts)
		- [UI Manager GUIs](Docs/Creating-Atom-Packages.md#ui-manager-guis)
		- [Create Shortcut Function](Docs/Creating-Atom-Packages.md#create-shortcut)
- [Creating Environment Variables](Docs/Creating-Environment-Variables.md)
	- [Reactor Environment Variables](Docs/Creating-Environment-Variables.md#reactor-environment-variables)
		- [Viewing the Reactor Log File](Docs/Creating-Environment-Variables.md#viewing-the-reactor-log-file)
	- [Using the Windows System Control Panel](Docs/Creating-Environment-Variables.md#using-the-windows-system-control-panel)
	- [Using a Linux BASH Profile](Docs/Creating-Environment-Variables.md#using-a-linux-bash-profile)
	- [Using MacOS Launch Agent PLIST Files](Docs/Creating-Environment-Variables.md#using-macos-launch-agent-plist-files)

Last Revised 2018-05-21

