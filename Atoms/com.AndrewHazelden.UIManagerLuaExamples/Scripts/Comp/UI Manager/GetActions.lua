-- List all of the actions available in Fusion
local act = fu.ActionManager:GetActions()
for i,v in ipairs(act) do
  if not v:Get('Parent') then
    print(v.ID)
  end
end
