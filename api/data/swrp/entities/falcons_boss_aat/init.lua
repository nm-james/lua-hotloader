AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:Initialize()
	self:SetModel( 'models/blu/aat.mdl' )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )

    self:SetHealth( 25000 )
    self:SetNWInt('FALCON:SHIELD', 10000 )
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos + Vector( 0, 0, 15 ) )
    ent:SetAngles( Angle(0, ply:GetAngles().y, 0) )
	ent:Spawn()
    ent:Activate()

	return ent

end

function ENT:FindPlayer()
    if self.NextCheck and self.NextCheck > CurTime() then return end
    local p = player.GetAll()
    local upPlayer = self:GetNWEntity('FALCON:TOP:PLAYER')
    local downPlayer = self.Player

    local potentialPlayersBottom = {}
    local potentialPlayersTop = {}

    for _, ply in pairs( p ) do
        if ply:IsFlagSet( FL_NOTARGET ) then continue end
        local dist = ply:GetPos():Distance( self:GetPos() )
        if dist > 5000 then continue end
        if not ply:Alive() then continue end
        if dist < 7500 and not IsValid(upPlayer) then
            table.insert( potentialPlayersTop, ply )
        end
        if dist < 1000 and not IsValid(downPlayer) then
            table.insert( potentialPlayersBottom, ply )
        end
    end


    if #potentialPlayersTop ~= 0 then
        self:SetNWEntity('FALCON:TOP:PLAYER', potentialPlayersTop[math.random(1, #potentialPlayersTop)])
    end

    if #potentialPlayersBottom ~= 0 then
        local bot = potentialPlayersBottom[math.random(1, #potentialPlayersBottom)]
        self:SetNWEntity('FALCON:BOTTOM:PLAYER', bot)
        self.Player = bot
    end

    self.NextCheck = CurTime() + 1
end

function ENT:HasPlayers()
    if IsValid( self.Player ) and self.Player:Alive() then
        local dist = self.Player:GetPos():Distance( self:GetPos() )
        if dist > 5000 or IsValid(self.Player) and self.Player:IsFlagSet( FL_NOTARGET ) then
            self:SetNWEntity('FALCON:BOTTOM:PLAYER', nil)
            self.Player = nil
        end
    end 

    local upPlayer = self:GetNWEntity('FALCON:TOP:PLAYER')
    if IsValid( upPlayer ) and upPlayer:Alive() then
        local dist = upPlayer:GetPos():Distance( self:GetPos() )
        if dist > 7500 or IsValid(upPlayer) and upPlayer:IsFlagSet( FL_NOTARGET ) then
            self:SetNWEntity('FALCON:TOP:PLAYER', nil)
        end
    end
    self:FindPlayer()
end

function ENT:ManipulateSelf()
    local enemy = self.Player
    local angle = (self:GetPos() - (enemy:GetPos() + enemy:OBBCenter())):Angle()
    angle.p = 0
    
    self:SetAngles( angle - Angle(0, 180, 0) )
end

function ENT:ManipulateTurret()
    local enemy = self:GetNWEntity('FALCON:TOP:PLAYER')
    local bone = self:LookupBone('turret_yaw')
    local entAngles = self:GetAngles()
    local angle = (self:GetBonePosition( bone ) - (enemy:GetPos() + enemy:OBBCenter())):Angle()
    angle.p = angle.y - entAngles.y + 180
    angle.y = 0

    self:ManipulateBoneAngles( bone, LerpAngle(FrameTime() * 0.7, self:GetManipulateBoneAngles( bone ), angle ) )
end

local MissileAttach = {
    [1] = {
        left = "missile_1l",
        right = "missile_1r"
    },
    [2] = {
        left = "missile_2l",
        right = "missile_2r"
    },
    [3] = {
        left = "missile_3l",
        right = "missile_3r"
    },
}
function ENT:MissleAttack()
    if self.NextMissile and self.NextMissile > CurTime() then return end
    local enemy = self.Player
    for i = 1, 3 do
		timer.Simple( (i / 5) * 0.75, function()
			if not IsValid( self ) then return end

			self:EmitSound( "lfsAAT_FIREMISSILE" )

			local ID_L = self:LookupAttachment( MissileAttach[i].left )
			local ID_R = self:LookupAttachment( MissileAttach[i].right )
			local MuzzleL = self:GetAttachment( ID_L )
			local MuzzleR= self:GetAttachment( ID_R )

			local swap = false

			for i = 1, 2 do
				local Pos = swap and MuzzleL.Pos or MuzzleR.Pos
                local Dir = ((enemy:GetPos() + enemy:OBBCenter()) - Pos):Angle()
	
				swap = not swap

				local ent = ents.Create( "lfs_aat_missile" )
				ent:SetPos( Pos + Dir:Forward()*20 )
				ent:SetAngles( Dir )
				ent:Spawn()
				ent:Activate()
				ent:SetAttacker( self )
				ent:SetInflictor( self )
			end
		end)
	end

    self.NextMissile = CurTime() + 15
end

function ENT:LaserAttack()
    if self.NextLaser and self.NextLaser > CurTime() then return end
    local enemy = self.Player

    local ID_L = self:LookupAttachment( "muzzle_left" )
	local ID_R = self:LookupAttachment( "muzzle_right" )
	local MuzzleL = self:GetAttachment( ID_L )
	local MuzzleR= self:GetAttachment( ID_R )
	
	if not MuzzleL or not MuzzleR then return end

	self:EmitSound( "lfsAAT_FIRE" )

	self.MirrorPrimary = not self.MirrorPrimary

	local Pos = self.MirrorPrimary and MuzzleL.Pos or MuzzleR.Pos
    local Dir = ((enemy:GetPos() + enemy:OBBCenter()) - Pos)
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Pos
	bullet.Dir 	= Dir
	bullet.Spread 	= Vector( 0.05, 0.05, 0.05 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_red"
	bullet.Force	= 100
	bullet.HullSize 	= 2
	bullet.Damage	= 30
	bullet.Attacker 	= self
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )

    local shouldContinue = math.random(1, 5)

    if shouldContinue == 1 then
        self.NextLaser = CurTime() + 6
    else
        self.NextLaser = CurTime() + 0.1
    end
end

function ENT:TurretAttack()
    if self.NextTurret and self.NextTurret > CurTime() then return end
    local enemy = self:GetNWEntity('FALCON:TOP:PLAYER')

    local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )

	self:EmitSound( "lfsAAT_FIRECANNON" )

	if Muzzle then
		local effectdata = EffectData()
        effectdata:SetEntity( self )
		util.Effect( "lfs_aat_muzzle", effectdata )
        local Pos = Muzzle.Pos

        local Dir = ((enemy:GetPos() + enemy:OBBCenter()) - Pos):Angle()
		local ent = ents.Create( "lfs_aat_maingun_projectile" )
		ent:SetPos( Pos )
		ent:SetAngles( Dir )
		ent:Spawn()
		ent:Activate()
		ent:SetAttacker( self )
		ent:SetInflictor( self )

		local PhysObj = self:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -Muzzle.Ang:Up() * 20000, Muzzle.Pos )
		end
	end
    self.NextTurret = CurTime() + 8
end

function ENT:Think()
    if self:Health() == 0 then return end
    if self:Health() < 25000/5 and (not self.NextSpark or self.NextSpark and self.NextSpark < CurTime()) then
        local effectdataspk = EffectData()
        effectdataspk:SetOrigin(self:GetPos())
        effectdataspk:SetScale( 900 )
        util.Effect( "ManhackSparks", effectdataspk )
        self.NextSpark = CurTime() + 2
    end

    self:HasPlayers()
    local enemy = self.Player
    if IsValid( enemy ) and enemy:Alive() then
        self:ManipulateSelf()
        self:MissleAttack()
        self:LaserAttack()
    end

    local enemy = self:GetNWEntity('FALCON:TOP:PLAYER')
    if IsValid( enemy ) and enemy:Alive() then
        self:ManipulateTurret()
        self:TurretAttack()
    end
end

function ENT:OnTakeDamage( dmg )
    if ( not self.m_bApplyingDamage ) then
		self.m_bApplyingDamage = true
		-- self:TakeDamageInfo( dmginfo )
        if dmg:GetAttacker() ~= self then
            local shield = self:GetNWInt('FALCON:SHIELD', 0)
            local currentDamage = dmg:GetDamage()
            if shield > 0 then
                local difference = shield - currentDamage
                if difference > 0 then
                    self:SetNWInt('FALCON:SHIELD', difference)
                else
                    self:SetNWInt('FALCON:SHIELD', 0)
                    local difference = difference * -1
                    dmg:SetDamage( difference )
                    self:SetHealth( math.Clamp(self:Health() - dmg:GetDamage(), 0, 30000) )
                end
            else
                if self:Health() ~= 0 then
                    if dmg:GetDamageType() == DMG_BLAST then
                        dmg:ScaleDamage( 8 )
                    end
                    self:SetHealth( math.Clamp(self:Health() - dmg:GetDamage(), 0, 30000) )
                    if self:Health() == 0 then
                        local effectdataexp = EffectData()
                        effectdataexp:SetOrigin(self:GetPos())
                        effectdataexp:SetScale(700)
                        util.Effect( "Explosion", effectdataexp )
                        self:PhysicsInit( SOLID_VPHYSICS )

                        local phys = self:GetPhysicsObject()

                        if IsValid( phys ) then
                            phys:Wake()
                        end


                        timer.Simple(60, function()
                            if not IsValid( self ) then return end
                            self:Remove()
                        end)
                    end
                end
            end
        end
		self.m_bApplyingDamage = false
	end
end