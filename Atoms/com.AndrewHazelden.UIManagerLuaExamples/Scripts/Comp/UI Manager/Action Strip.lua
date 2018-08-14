ui = fu.UIManager
disp = bmd.UIDispatcher(ui)

win = disp:AddWindow(
{
	ID = "MyWin",
	WindowTitle = "Blah",
	Geometry = { 100,100,400,300 },
	Composition = comp,
	
	ui:VGroup
	{
		ui:TextEdit
		{
			Weight = 1.0,
			ID = "Description",
		},
		ui:ActionStrip
		{
			Weight = 0.0,
			ID = "Strip",
			ZonesPerSide = 5,
		},
	},
})

itm = win:GetItems()

strip = itm.Strip
sid = strip:GetNextID()

print("[ActionStrip Element]")
dump(strip)

strip:BeginZone(sid, 0, "MyZone", 0, 0)
	strip:AddButton("Comp_New{}", {})
	strip:AddButton("Comp_Open{}", {})
	strip:AddButton("Comp_Save{}", {})
	pup = strip:AddPopup("", {})
		pup:BeginZone(sid, 0, "Z", 0, 0)
		pup:AddButton("Comp_New{}", {})
		pup:AddButton("Comp_Open{}", {})
		pup:AddButton("Comp_Save{}", {})
	pup:EndZone(true)
strip:EndZone(true)

function win.On.MyWin.Close(ev)
	disp:ExitLoop()
end

win:Show()
disp:RunLoop()
win:Hide()
