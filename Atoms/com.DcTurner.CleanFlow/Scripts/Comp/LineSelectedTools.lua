fl = comp.CurrentFrame.FlowView

comp:StartUndo("Align Tools Horizontally")
comp:Lock()
_SEL = comp:GetToolList(true)
_A = comp.ActiveTool
if (_A == nil) then
	_A = _SEL[1]
end
_AX,_AY = fl:GetPos(_A)

for k,v in pairs(_SEL) do
	if (v~= _A) then
		_TEMP_X, _TEMP_Y = fl:GetPos(v)
		fl:SetPos(v, _TEMP_X, _AY)
	end
end
comp:Unlock()
comp:EndUndo()