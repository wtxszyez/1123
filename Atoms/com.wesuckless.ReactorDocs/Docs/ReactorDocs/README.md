# Reactor Documentation #


## <a name="overview"></a>Overview ##
Reactor is a package manager created by the [We Suck Less Community](https://www.steakunderwater.com/wesuckless/viewforum.php?f=32) for Fusion and Resolve. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.


![Reactor GUI](Images/reactor-gui.png)


## Table Of Contents ##

- [Overview](#overview)
- [Installing Reactor](Installing-Reactor.html#installing-reactor)
	- [Installing Reactor Visually](Installing-Reactor.html#installing-reactor-visually)
	- [Installing Reactor Manually](Installing-Reactor.html#installing-reactor-manually)
	- [Using Reactor Content on a Render Node](Installing-Reactor.html#using-reactor-content-on-a-rendernode)
		- [Fusion Render Node Preference File](Installing-Reactor.html#fusion-render-node-preference-file)
	- [Uninstalling Reactor Manually](Installing-Reactor.html#uninstalling-reactor-manually)
- [Using Reactor](Using-Reactor.html)
	- [Overview](Using-Reactor.html#overview)
	- [Opening Reactor Window](Using-Reactor.html#opening-reactor-window)
	- [Using the Reactor Package Manager](Using-Reactor.html#using-the-reactor-package-manager)
	- [Installing Atom Packages](Using-Reactor.html#installing-atom-packages)
	- [Updating Atom Packages](Using-Reactor.html#updating-atom-packages)
	- [Removing Atom Packages](Using-Reactor.html#removing-atom-packages)
		- [Removing Plugins on Windows](Using-Reactor.html#removing-plugins-on-windows)
	- [Searching for Atom Packages](Using-Reactor.html#searching-for-atom-packages)
	- [Reactor Categories Explained](UsingReactor.html#reactor-categories-explained)
	- [Resync Repository](Using-Reactor.html#resync-repository)
		- [What is a PrevCommitID Value](Using-Reactor.html#what-is-a-prevcommitid-value)
	- [Creating the AllData Folder](Using-Reactor.html#creating-the-alldata-folder)
- [Creating Atom Packages](Creating-Atom-Packages.html#creating-atom-packages)
	- [Adding a Description to an Atom Package](Creating-Atom-Packages.html#adding-a-description-to-an-atom-package)
	- [HTML Encoded Entity Characters](Creating-Atom-Packages.html#html-encoded-entity-characters)
	- [Adding Emoticon Images to the Description](Creating-Atom-Packages.html#adding-emoticon-images-to-the-description)
	- [Using Atomizer to Edit Your Atoms](Creating-Atom-Packages.html#using-atomizer-to-edit-your-atoms)
	- [Adding a Category to an Atom Package](Creating-Atom-Packages.html#adding-a-category-to-an-atom-package)
	- [Adding a Required Donation to an Atom Package](Creating-Atom-Packages.html#adding-a-required-donation-to-an-atom-package)
		- [PayPal.me Links](Creating-Atom-Packages.html#paypal-me-links)
		- [WWW Links](Creating-Atom-Packages.html#www-links)
		- [Email Links](Creating-Atom-Packages.html#email-links)
		- [Bitcoin Links](Creating-Atom-Packages.html#bitcoin-links)
	- [Adding a Deploy Platform Requirement](Creating-Atom-Packages.html#adding-a-deploy-platform-requirement)
		- [Platform Specific Deploy Entries](Creating-Atom-Packages.html#platform-specific-deploy-entries)
		- [Host App Specific Deploy Entries](Creating-Atom-Packages.html#host-app-specific-deploy-entries)
	- [Adding a Package Dependency](Creating-Atom-Packages.html#adding-a-package-dependency)
	- [Adding Documentation](Creating-Atom-Packages.html#adding-documentation)
	- [Adding Fusion Minimum/Maximum Compatibility](Creating-Atom-Packages.html#adding-fusion-minimum-maximum-compatibility)
	- [InstallScripts and UninstallScript](Creating-Atom-Packages.html#installscripts-and-uninstallscripts)
		- [UI Manager GUIs](Creating-Atom-Packages.html#ui-manager-guis)
		- [Create Shortcut Function](Creating-Atom-Packages.html#create-shortcut)
- [Creating Environment Variables](Creating-Environment-Variables.md)
	- [Reactor Environment Variables](Creating-Environment-Variables.html#reactor-environment-variables)
		- [Viewing the Reactor Log File](Creating-Environment-Variables.html#viewing-the-reactor-log-file)
	- [Using the Windows System Control Panel](Creating-Environment-Variables.html#using-the-windows-system-control-panel)
	- [Using a Linux BASH Profile](Creating-Environment-Variables.html#using-a-linux-bash-profile)
	- [Using MacOS Launch Agent PLIST Files](Creating-Environment-Variables.html#using-macos-launch-agent-plist-files)

Last Revised 2019-12-02
