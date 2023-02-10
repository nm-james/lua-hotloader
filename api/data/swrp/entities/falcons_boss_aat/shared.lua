-- TEST


ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.PrintName 		= "AAT [STATIONARY]"
ENT.Name = "AAT"
ENT.Category = "FALCON'S TANKS"

ENT.Spawnable		= true


if SERVER then return end

function ENT:Initialize()
    self.CopyModel = ClientsideModel(self:GetModel())
    self.CopyModel:SetPos( self:GetPos() )
    self.CopyModel:SetAngles( self:GetAngles() )

    self.ShieldModel = ClientsideModel( self:GetModel() )
    self.ShieldModel:SetParent( self.CopyModel )
    self.ShieldModel:AddEffects( EF_BONEMERGE )
    self.ShieldModel:SetMaterial( 'Models/effects/comball_sphere' )
    self.ShieldModel:SetModelScale( 1.1 )
    self.ShieldModel:SetColor( Color( 100, 100, 185 ) )

    self.ENG = CreateSound( self, "lfsAAT_ENGINE" )
    self.ENG:Play()

    self.MaxHP = 25000
    self.MaxShield = 10000
    self.DelayThink = CurTime() + 2
end

function ENT:OnRemove()
    if IsValid( self.CopyModel ) then
        self.CopyModel:Remove()
    end
    if IsValid( self.ShieldModel ) then
        self.ShieldModel:Remove()
    end
    self.ENG:Stop()
end

function ENT:Think()
    if self.DelayThink and self.DelayThink > CurTime() then return end
    local shield = self:GetNWInt('FALCON:SHIELD', 0)
    if shield <= 0 then
        self.ShieldModel:Remove()
    end
    if self:Health() == 0 and IsValid(self.CopyModel) then
        self.ENG:Stop()
        self:SetColor( Color(75, 75, 75) )
        local bone = self:LookupBone('turret_yaw')
        self:ManipulateBoneAngles( bone, self.CopyModel:GetManipulateBoneAngles(bone) )
        self.CopyModel:Remove()
    end
end

function ENT:Draw()
    if self:Health() == 0 then 
        self:DrawModel()
        return 
    end
    local enemy = self:GetNWEntity('FALCON:TOP:PLAYER')
    local copy = self.CopyModel
    copy:SetPos( self:GetPos() )
    if IsValid(enemy) and enemy:GetPos():Distance(self:GetPos()) < 7500 and not enemy:IsFlagSet( FL_NOTARGET ) then 
        local bone = copy:LookupBone('turret_yaw')
        local entAngles = copy:GetAngles()
        local angle = (copy:GetBonePosition( bone ) - (enemy:GetPos() + enemy:OBBCenter())):Angle()
        angle.p = angle.y - entAngles.y + 180
        angle.y = 0
    
        copy:ManipulateBoneAngles( bone, LerpAngle(FrameTime() * 0.7, copy:GetManipulateBoneAngles( bone ), angle ) )
    end

    local enemy = self:GetNWEntity('FALCON:BOTTOM:PLAYER')
    if IsValid(enemy) and enemy:GetPos():Distance(self:GetPos()) < 5000 and not enemy:IsFlagSet( FL_NOTARGET ) then 
        local angle = (self:GetPos() - (enemy:GetPos() + enemy:OBBCenter())):Angle()
        angle.p = 0
        copy:SetAngles( LerpAngle(FrameTime() * 1, copy:GetAngles(), angle - Angle( 0, 180, 0 ) ) )
    end

    local ply = LocalPlayer()

    if ply:GetPos():Distance( self:GetPos() ) > 2500 then return end

    local mins, maxs = self:GetCollisionBounds()
    local pos = self:GetPos()

    local ang = ply:EyeAngles()
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

    local hp = self:Health()
    local maxHp = 5000

    cam.Start3D2D( Vector( pos.x, pos.y, pos.z + maxs.z + 15 ), ang, 0.1 )
        draw.SimpleTextOutlined( self.Name .. ' [BOSS]', "F300", -68, -18, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black )
    cam.End3D2D()
end