print('INIT')

-- function GM:PlayerSwitchFlashlight()
--     return true
-- end

-- function GM:PlayerDeath( ply )
--     local chance = math.Rand(0, 1.5)
--     if chance > 1 then return end
--     ply:EmitSound('pa/player/death' .. math.random(1, 3) .. '.mp3', 75, 100, 1, CHAN_AUTO)
-- end

-- function GM:PlayerHurt( ply, att, hp )
--     if ply:Armor() > 0 then return end
--     if hp <= 0 then 
--         return 
--     end
--     if ply.NextHurtSound and ply.NextHurtSound > CurTime() then return end
--     local chance = math.Rand(0, 1.5)
--     if chance > 1 then return end
--     ply:EmitSound('pa/player/pain' .. math.random(1, 12) .. '.mp3', 75, 100, 1, CHAN_AUTO)
--     ply.NextHurtSound = CurTime() + 3
-- end


-- function GM:GetFallDamage( ply, speed )
--     return ( speed / 8 )
-- end

