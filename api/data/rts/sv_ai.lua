-- Battle AI
local BATTLE_AI = {}



-- AI for logistical stuff
local AI = {}

function AI:Think()
    if self.DelayAIThink and self.DelayAIThink > CurTime() then return end
    self.DelayAIThink = CurTime() + 1

    -- do stuff
    -- move fleets and all
end

hook.Add("Think", "FALCON:NAVY:AI", function()
    AI:Think()
end)