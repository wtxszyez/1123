_VERSION = [[v3.14 2019-10-14]]
--[[--
Reactor Preferences Window
--]]--

-- Reactor GitLab Public Project ID
local reactor_project_id = "5058837"

-- Reactor GitLab Dev Project ID
-- local reactor_project_id = "4405807"

-- Reactor GitLab Test Repo Project ID
-- local reactor_project_id = "5273696"

g_DefaultConfig =
{
	Repos =
	{
		_Core =
		{
			Protocol = "GitLab",
			ID = reactor_project_id,
		},
		Reactor =
		{
			Protocol = "GitLab",
			ID = reactor_project_id,
		},
	},
	Settings =
	{
		Reactor =
		{
			AskForInstallScriptPermissions = true,
			LiveSearch = true,
			MarkAsNew = true,
			NewForDays = 7,
			PrevSyncTime = os.time(),
			ViewLayout = "Balanced View",
		},
	},
}

g_Config = {}

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

-- Check for a pre-existing PathMap preference
local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
	-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
	reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. osSeparator .. "$", "")
end

-- local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local reactor_prefs = reactor_root .. "System/Reactor.cfg"

function ReadPrefs()
	-- Read the "Reactor:/System/Reactor.cfg" preferences file
	g_Config = bmd.readfile(reactor_prefs)

	-- Fallback to a default prefs table if none was found
	if type(g_Config) ~= "table" then
		g_Config = g_DefaultConfig
	end

	print("[Reactor] Preferences Path: " .. tostring(reactor_prefs))
	print("[Reactor] Read Preferences")
	dump(g_Config)

	if g_Config.Settings.Reactor.ViewLayout ~= nil then
		itm.ViewLayoutCombo.CurrentText = g_Config.Settings.Reactor.ViewLayout
	else
		itm.ViewLayoutCombo.CurrentText = "Balanced View"
	end

	if g_Config.Settings.Reactor.ConcurrentTransfers ~= nil then
		itm.ConcurrentTransfersSlider.Value = g_Config.Settings.Reactor.ConcurrentTransfers
	else
		itm.ConcurrentTransfersSlider.Value = 8
	end

	if g_Config.Settings.Reactor.LiveSearch ~= nil then
		itm.LiveSearchCheckbox.Checked = g_Config.Settings.Reactor.LiveSearch
	else
		itm.LiveSearchCheckbox.Checked = true
	end

	if g_Config.Settings.Reactor.AskForInstallScriptPermissions ~= nil then
		itm.AskForInstallScriptPermissionsCheckbox.Checked = g_Config.Settings.Reactor.AskForInstallScriptPermissions
	else
		itm.AskForInstallScriptPermissionsCheckbox.Checked = true
	end

	if g_Config.Settings.Reactor.MarkAsNew ~= nil then
		itm.MarkAsNewCheckbox.Checked = g_Config.Settings.Reactor.MarkAsNew
	else
		itm.MarkAsNewCheckbox.Checked = true
	end

	if g_Config.Settings.Reactor.NewForDays ~= nil and g_Config.Settings.Reactor.NewForDays ~= "" then
		itm.NewForDaysLineEdit.Text = tostring(g_Config.Settings.Reactor.NewForDays)
	else
		itm.NewForDaysLineEdit.Text = tostring(7)
	end
end

function SavePrefs()
	-- Store the preferences
	g_Config.Settings.Reactor.ViewLayout = itm.ViewLayoutCombo.CurrentText
	g_Config.Settings.Reactor.ConcurrentTransfers = itm.ConcurrentTransfersSlider.Value
	g_Config.Settings.Reactor.LiveSearch = itm.LiveSearchCheckbox.Checked
	g_Config.Settings.Reactor.AskForInstallScriptPermissions = itm.AskForInstallScriptPermissionsCheckbox.Checked
	g_Config.Settings.Reactor.MarkAsNew = itm.MarkAsNewCheckbox.Checked
	g_Config.Settings.Reactor.NewForDays = tonumber(itm.NewForDaysLineEdit.Text)

	-- Write the "Reactor:/System/Reactor.cfg" preferences file
	result = bmd.writefile(reactor_prefs, g_Config)

	print("[Reactor] Preferences Path: " .. tostring(reactor_prefs))
	print("[Reactor] Saved Preferences: " .. tostring(result))
	dump(g_Config)
end

function DisplayPrefs()
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 442,200

	win = disp:AddWindow({
		ID = "PrefsWin",
		TargetID = "PrefsWin",
		WindowTitle = "Reactor Preferences ",
		Geometry = {100, 100, width, height},
		Spacing = 10,

		ui:VGroup{
			ID = 'root',

			-- Add your GUI elements here:
			ui:HGroup{
				ui:Label{ID = "ViewLayoutLabel", Text = "View Layout",},
				ui:ComboBox{ID = "ViewLayoutCombo", Text = "View Layout",},
			},
			
			ui:HGroup{
				ui:Label{ID = "ConcurrentTransfersLabel", Text = "Concurrent cURL Transfers",},
				-- ui:Slider{ID = 'ConcurrentTransfersSlider', Minimum = 1, Maximum = 32},
				ui:SpinBox{ID = 'ConcurrentTransfersSlider', Minimum = 1, Maximum = 32},
			},

			ui:CheckBox{ID = "LiveSearchCheckbox", Text = "Live Search",},
			ui:CheckBox{ID = "AskForInstallScriptPermissionsCheckbox", Text = "Always Ask for InstallScript Permissions",},

			ui:HGroup{
				ui:CheckBox{ID = "MarkAsNewCheckbox", Text = [[Mark Atoms as "New" for]],},
				ui:LineEdit{ID = 'NewForDaysLineEdit', PlaceholderText = '#',},
				ui:Label{ID = 'DaysLabel', Text = 'Days',},
			},

			ui:HGroup{
				ui:HGap(0, 2),
				ui:Button{ID = "OKButton", Text = "OK",},
			},
		},
	})

	-- The window was closed
	function win.On.PrefsWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The OK Button saves the preferences
	function win.On.OKButton.Clicked(ev)
		print("OK")
		SavePrefs()

		disp:ExitLoop()
	end

	-- Add the items to the ComboBox menu
	itm.ViewLayoutCombo:AddItem("Balanced View")
	itm.ViewLayoutCombo:AddItem("Larger Atom View")
	itm.ViewLayoutCombo:AddItem("Larger Description View")


	-- The app:AddConfig() command that will capture the 'Control + W' or 'Control + F4' hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("PrefsWin", {
		Target {
			ID = "PrefsWin",
		},

		Hotkeys {
			Target = "PrefsWin",
			Defaults = true,

			CONTROL_W  = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
			CONTROL_F4 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
		},
	})

	-- Read the preferences
	ReadPrefs()

	-- Display the GUI
	win:Show()
	disp:RunLoop()
	win:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig("PrefsWin")
	collectgarbage()
end

DisplayPrefs()
print("[Done]")
