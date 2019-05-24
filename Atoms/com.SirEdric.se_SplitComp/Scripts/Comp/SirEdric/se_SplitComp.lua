--[[

Split the current comp into segments and deploy those to Fusion's RM.
Written by eric 'SirEdric' Westphal (eric@siredric.de)
If you like it, buy me a coffee for 5,- € https://www.paypal.me/SirEdric
www.fusiontrainer.com

Big thanks to pauln (https://www.steakunderwater.com/wesuckless/memberlist.php?mode=viewprofile&u=2311) for supplying me with a whole week of coffee!

ToDo: 
	"Render on" a Textfield to put Groups or Slave Names into.

--]]

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 600,350
--master = fusion:GetPrefs()["Global"]["Network"]["ServerName"] 
master = "localhost"

info = [[<h3 align="center">Split Comp and Render</h3><p align="center">Split the current comp into segments and send those segments to the default Render Manager.<br><br>If you find this script useful, please consider to buy me a coffee at <a href=https://www.paypal.me/SirEdric>www.paypal.me/SirEdric</a></p>]]

seToolsWin = disp:AddWindow({
  ID = 'seTools',
  WindowTitle = '[se] SplitComp 1.0',
  Geometry = {100, 100, width, height},
  Spacing = 0,
  
  ui:VGroup{
    ID = 'root',
		ui:TextEdit{ID = 'scriptInfo',OpenExternalLinks = true,  IconSize = {128,128}, Text = info, ReadOnly = true,},
		
		ui:HGroup{
		Weight = 0.001,	
			ui:VGroup{
				ID = 'labels', Weight = 0.3,
				ui:Label{ID = 'mName', Text = [[Rendermanger on]], Alignment = {AlignHLeft = true, AlignMiddle = true},},	
				ui:Label{ID = 'lName',  Text = 'Comps Name ', Alignment = {AlignHLeft = true, AlignTop = true},},
				ui:Label{ID = 'lStart', Text = 'Render Start Frame ', Alignment = {AlignHLeft = true, AlignTop = true},},	
				ui:Label{ID = 'lEnd',  Text = 'Render End Frame ', Alignment = {AlignHLeft = true, AlignTop = true},},
				ui:Label{ID = 'lTotal', Text = 'Total Frames ', Alignment = {AlignHLeft = true, AlignTop = true},},
				ui:CheckBox{ID = 'cSegLen',  Text = 'Frames per Segment ', Checked = true, Alignment = {AlignHLeft = true, AlignTop = true},},
				ui:CheckBox{ID = 'cSegNum',  Text = 'Number of Segments ', Alignment = {AlignHLeft = true, AlignTop = true},},
				
			},
			ui:VGroup{
				ID = 'controls', Weight = 0.7,
					ui:HGroup{ Weight = 0.001,
						ui:LineEdit{ID='mNameEdit', Weight = 0.75, Text = master, PlaceholderText = 'localhost, IP-Address, or hostname',},
						ui:Button{ID = 'butConnect', Weight = 0.25, Text = 're-connect',},
					},
					ui:HGroup{ Weight = 0.001,
						ui:LineEdit{ID='eName', Weight = 0.75, Text = '', PlaceholderText = "Please save the current comp.", ReadOnly = true},
						ui:Button{ID = 'butRefresh', Weight = 0.25, Text = 're-fresh',},
					},
					ui:LineEdit{ID='eStart', Weight = 0.9, Text = '', PlaceholderText = "-",},
					ui:LineEdit{ID='eEnd', Weight = 0.9, Text = '', PlaceholderText = "-",},
					ui:LineEdit{ID='eTotal', Weight = 0.9, Text = '', PlaceholderText = "-", ReadOnly = true},
					ui:LineEdit{ID='eSegLen', Weight = 0.9, Text = '100', PlaceholderText = "100",},
					ui:LineEdit{ID='eSegNum', Weight = 0.9, Text = '-', PlaceholderText = "-", ReadOnly = true },
				},
		},
		ui:HGroup{
		Weight = 0.01,
			ui:Button{ID = 'butOkay', Text = 'Send to Render Manager',},
			ui:Button{ID = 'butCncl', Text = 'Close Window',},
		},
		ui:HGroup{
		Weight = 0.01,
			ui:Label{ID = 'status', Text = 'status', Alignment = {AlignHLeft = true, AlignTop = true},},
		},
	},
})

-- The window was closed
function seToolsWin.On.seTools.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = seToolsWin:GetItems()
--itm.cSegLen.Checked = true


function getFusionEnv()
	--qm = fusion.RenderManager
	masterConnect()
	compAttrs = comp:GetAttrs()
	compName = compAttrs.COMPS_FileName
	rnStart = compAttrs.COMPN_RenderStartTime
	rnEnd = compAttrs.COMPN_RenderEndTime
	totalFrames = rnEnd - rnStart + 1
end

function masterConnect()
	print("connecting...")
	itm.status.Text = [[<p style="color:#d8cf6a;">Trying to connect to  ]] .. master .. [[</p>]] 
	rm = Fusion(master, 5.0, nil, "RenderManager")
		if rm then
		--if rm:IsAppConnected() == true then 
			print("[Fusion found]")
			qm = rm.RenderManager
			if qm then
				print("[connected]")
				itm.status.Text = [[<p style="color:#779a70;">Successfully connected to ]] .. master .. [[</p>]]
				return true
			else
				itm.status.Text = [[<p style="color:#d45558;">FAILED to connect to RenderManager on ]] .. master .. [[. Try a different IP and re-connect.</p>]]
				return false
			end
		else
			--errorConnect()
			itm.status.Text = [[<p style="color:#d45558;">Cannot find Fusion on ]] .. master .. [[. Try a different IP and re-connect.</p>]]
			return nil		
		end
end

function splitCompRM()
	print("Render Start: " .. rnStart .. " | Render End: " .. rnEnd .. " | Total Frames: " .. totalFrames)
	print("Segments: " .. mySegs)
	for n = 1, math.ceil(totalFrames / segLength) do
		if rnStart <= rnEnd then
			segEnd = rnStart + segLength - 1
			print("segEnd1: " .. segEnd)
			if segEnd > rnEnd then segEnd = rnEnd end
			print("segment " .. n .. " from " .. rnStart  .. " to " .. segEnd)

			qm:AddJob(compName, "all", rnStart..'..' .. segEnd)
			
			rnStart = rnStart + segLength 
		end
	end
end

function calcSegs()
		totalFrames = rnEnd - rnStart + 1
		segLength = tonumber(itm.eSegLen.Text) or 1
		mySegs = math.ceil(totalFrames / segLength)
end

function calcLength()
		totalFrames = rnEnd - rnStart + 1
		mySegs = tonumber(itm.eSegNum.Text) or 1
		segLength = math.floor(totalFrames / mySegs)
end

function updateItems()
	--itm.allRM:AddItem(qm)
	itm.eStart.Text = tostring(rnStart)
	itm.eEnd.Text = tostring(rnEnd)
	itm.eTotal.Text = tostring(totalFrames)
	itm.eName.Text = compName
	itm.eSegLen.Text = tostring(segLength)
	itm.eSegNum.Text = tostring(mySegs)
end

function seToolsWin.On.eStart.TextChanged(ev)
	rnStart = tonumber(itm.eStart.Text) or 0
	calcSegs()
	updateItems()
end

function seToolsWin.On.eEnd.TextChanged(ev)
	rnEnd = tonumber(itm.eEnd.Text) or 1000
	calcSegs()
	updateItems()
end

function seToolsWin.On.eSegLen.TextChanged(ev)
	if itm.cSegLen.Checked == true then
		calcSegs()
		updateItems()
	end
end

function seToolsWin.On.eSegNum.TextChanged(ev)
	if itm.cSegNum.Checked == true then
		calcLength()
		updateItems()
	end
end

function seToolsWin.On.cSegNum.Clicked(ev)
	if itm.cSegNum.Checked == true then
		itm.eSegNum.ReadOnly = false
		itm.cSegLen.Checked = false
		itm.eSegLen.ReadOnly = true
	else
		itm.eSegNum.ReadOnly = true
		itm.cSegLen.Checked = true
		itm.eSegLen.ReadOnly = false
	end
end

function seToolsWin.On.cSegLen.Clicked(ev)
	if itm.cSegLen.Checked == true then
		itm.eSegLen.ReadOnly = false
		itm.cSegNum.Checked = false
		itm.eSegNum.ReadOnly = true
	else
		itm.cSegNum.Checked = true
		itm.eSegLen.ReadOnly = true
		itm.eSegNum.ReadOnly = false
	end
end

function seToolsWin.On.butOkay.Clicked(ev)
	splitCompRM()
end

function seToolsWin.On.butRefresh.Clicked(ev)
	print("[refreshing]")
	comp = fusion.CurrentComp
	getFusionEnv()
	calcSegs()
	updateItems()
	dump(qm)
end

function seToolsWin.On.butConnect.Clicked(ev)
	master = tostring(itm.mNameEdit.Text)
	masterConnect()
end

function seToolsWin.On.butCncl.Clicked(ev)
	disp:ExitLoop()
	seToolsWin:Hide()
end

--segLength = 50 --length of each segment

getFusionEnv()
calcSegs()
updateItems()
dump(qm)

--splitCompRM()
seToolsWin:Show()
disp:RunLoop()
seToolsWin:Hide()