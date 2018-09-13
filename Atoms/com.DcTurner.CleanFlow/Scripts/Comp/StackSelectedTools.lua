fl = comp.CurrentFrame.FlowView

comp:StartUndo("Stack Tools")
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
		fl:SetPos(v, _AX, _TEMP_Y)
	end
end
comp:Unlock()
comp:EndUndo()