
SWEP.Type                  = "anim"
SWEP.Base                  = "weapon_base"

SWEP.PrintName          = "DC-15A"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.Category           = "Falcon's SWEPs"

SWEP.Primary = {}
SWEP.Primary.Damage = {}
SWEP.Primary.Damage.min = 4
SWEP.Primary.Damage.max = 13

SWEP.ViewModel = "models/jajoff/sps/cgiweapons/tc13j/dc15a.mdl"
SWEP.Primary.Tracer = "lfs_laser_blue"
SWEP.Primary.Recoil = 0.5
SWEP.Primary.NumberofShots = 1 
SWEP.Primary.Spread = 0.75
SWEP.Primary.ClipSize = 40 
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.125
SWEP.Primary.Force = 1
SWEP.Primary.Ammo = "AR2"




-- audio stuff
SWEP.Sounds = {}
SWEP.Sounds.Init = "weapons/"
SWEP.Sounds.FirePath = 'weapons/dc15a/fire/'
SWEP.Sounds.Fire = 4
SWEP.Sounds.Deploy = "weapons/"
SWEP.Sounds.Reserve = "weapons/"
-- positioniing stuff
SWEP.StandardSightPos = function( ang )
   return (ang:Forward()*0) - (ang:Up()*14 ) + (ang:Right() * 4.675)
end
SWEP.IronSightsPos  = function( ang )
   return -ang:Forward() * 15 + ang:Up() * 7.25 - ang:Right()*6
end

SWEP.WorldOffsetPos = Vector(-6, -2.25, -1.5)
SWEP.WorldOffsetAng = Angle(174, 181, -3)

-- -- non editables
SWEP.Secondary = {}
SWEP.Secondary.Ammo = -1
SWEP.Primary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.ViewModelFOV       = 90
SWEP.ViewModelFlip      = false
SWEP.Spawnable             = false
SWEP.UseHands              = true
SWEP.WorldModel            = SWEP.ViewModel
SWEP.HoldType = "ar2" 


-- Falcon = Falcon or {}

function SWEP:Initialize()
   util.PrecacheSound("") 
   self:SetWeaponHoldType( self.HoldType )
   self.DefaultSpread = self.Primary.Spread
end 

function SWEP:PrimaryAttack( bullet )
   if ( !self:CanPrimaryAttack() ) then return end
   local pos = self:GetAttachment( 2 ).Pos

   local bullet = bullet or {} 
   bullet.Num = bullet.Num or self.Primary.NumberofShots 
   bullet.Src = bullet.Src or pos+self.Owner:GetViewModel():GetAngles():Forward()*22
   local aim
   if self.Owner:IsPlayer() then
      if self.Owner:KeyDown(IN_ATTACK2) then
         bullet.Src = bullet.Src + self.Owner:EyeAngles():Right()*-7
      end

      if self.Owner:KeyDown(IN_DUCK) then
         bullet.Src = bullet.Src + self.Owner:EyeAngles():Up()*-14
      end
      aim = self.Owner:GetViewModel():GetAngles():Forward()
      -- if CLIENT then
      --    aim = self.Owner:GetAimVector()
      -- end   
   end




   bullet.Dir = bullet.Dir or aim
   bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
   bullet.Tracer = 1
   bullet.Force = self.Primary.Force 
   bullet.Damage = math.random( self.Primary.Damage.min, self.Primary.Damage.max ) 
   bullet.AmmoType = self.Primary.Ammo 
   bullet.TracerName = self.Primary.Tracer

   local rnda = self.Primary.Recoil * -1 
   local rndb = self.Primary.Recoil * math.random(-1, 1) 
   
   self:ShootEffects()
   
   self.Owner:FireBullets( bullet ) 
   self:EmitSound( Sound(self.Sounds.FirePath .. math.random(1, self.Sounds.Fire) .. '.mp3') )
   if self.Owner:IsPlayer() then
      self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
      self._Shot = true
   end
   self:TakePrimaryAmmo(self.Primary.TakeAmmo) 

   
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
end 

function SWEP:OnRemove()
   self.Scope:Remove()
end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
   if not IsValid(self.Owner) then return end
   if self:Clip1() >= self:GetMaxClip1() then return end
   local prevHoldType = self:GetHoldType()
   self:SetWeaponHoldType( "ar2" )
   self:EmitSound(Sound('weapons/misc/reload/before/' .. math.random(1, 12) .. '.mp3')) 
   self:DefaultReload( ACT_VM_RELOAD );
   self:SetWeaponHoldType( prevHoldType )
   timer.Simple(2.1, function()
      if not IsValid(self) then return end
      self:EmitSound(Sound('weapons/misc/reload/after/' .. math.random(1, 9) .. '.mp3')) 
   end)
end

function SWEP:DoImpactEffect()
   return false
end

function SWEP:Think()
   if not self.Owner:IsPlayer() then return end
   if self.Owner:KeyDown(IN_ATTACK2) or self.Owner:Crouching() then
      self:SetHoldType( "ar2" )
      if self.Owner:KeyDown(IN_ATTACK2) then
         self.Primary.Spread = self.DefaultSpread / 5
         if not self._Ironsights and CLIENT then
            surface.PlaySound( "weapons/misc/zoom_in/" .. math.random(1, 20) .. '.mp3' )
         end
         self._Ironsights = true
      else
         self.Primary.Spread = self.DefaultSpread / 2
         if self._Ironsights and CLIENT then
            surface.PlaySound( "weapons/misc/zoom_out/" .. math.random(1, 20) .. '.mp3' )
         end
         self._Ironsights = false
      end

   else
      self:SetHoldType( "shotgun" )
      self.Primary.Spread = self.DefaultSpread
      if self._Ironsights and CLIENT then
         surface.PlaySound( "weapons/misc/zoom_out/" .. math.random(1, 20) .. '.mp3' )
      end
      self._Ironsights = false
   end
end

if CLIENT then
   function SWEP:Initialize()
      self.ScopeID = 1
      self.WorldModelEnt = ClientsideModel(self.WorldModel)
      self.WorldModelEnt:SetNoDraw(true)
      self.DefaultSpread = self.Primary.Spread

         
      local scopeModel = 'models/jajoff/sps/cgiweapons/tc13j/dc19_scope.mdl'
      if self.ScopeID > 0 then
         scopeModel = self.Attachments['Scopes'][self.ScopeID][1]
      end
      self.Scope = ClientsideModel(scopeModel)
      self.Scope:SetNoDraw( true )
      self.Scope:SetSubMaterial( #self.Scope:GetMaterials()-1, 'models/props_combine/tprings_globe' )
   end

   function SWEP:DrawWorldModel()
      local WorldModel = self.WorldModelEnt
      local _Owner = self:GetOwner()
      local pos, ang = self:GetPos(), self:GetAngles()
      if _Owner:IsValid() and (_Owner:IsPlayer() and _Owner:Alive() or _Owner:IsNextBot()) then
         local offsetVec = self.WorldOffsetPos
         local offsetAng = self.WorldOffsetAng
         
         local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand")
         if !boneid then return end
   
         local matrix = _Owner:GetBoneMatrix(boneid)
         if !matrix then return end
   
         pos, ang = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
         WorldModel:SetupBones()
      end
      WorldModel:SetPos( pos )
      WorldModel:SetAngles( ang )

      local scopeEnt = self.Scope
      local data = self.Attachments['Scopes'][self.ScopeID]

      scopeEnt:SetPos(pos + (ang:Forward() * data[2].x + ang:Right() * data[2].y + ang:Up() * data[2].z))
      scopeEnt:SetAngles( ang )
      WorldModel:DrawModel()
      scopeEnt:DrawModel()

   end

   function SWEP:PostDrawViewModel( vm, weapon, ply )
      local pos, ang = vm:GetPos(), vm:GetAngles()
      local scopeEnt = self.Scope
      local data = self.Attachments['Scopes'][self.ScopeID]

      scopeEnt:SetPos(pos + (ang:Forward() * data[2].x + ang:Right() * data[2].y + ang:Up() * data[2].z))
      scopeEnt:SetAngles( ang )
      self.Scope:DrawModel()

     
   end
   
   function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
      local _Owner = self:GetOwner()
      local EyeAng, EyePos = ang, pos
      local pos = pos + self.StandardSightPos(EyeAng)

      if self._Shot then
         self.LastPos = self.LastPos + EyeAng:Forward()*-2
         self._Shot = false
      end
     
      local endVector = Vector()
      if _Owner:KeyDown(IN_DUCK) then
         endVector = Vector(0, 0, 8)
      end

      if _Owner:GetVelocity().z > 0 then
         endVector = Vector(0, 0, 4)
      end

      if self._Ironsights then
         local newIronsightPos = LerpVector(FrameTime() * 4, self.LastPos or endVector, self.IronSightsPos( EyeAng ) )
         pos = pos + newIronsightPos
         self.LastPos = newIronsightPos
      else
         
         EyeAng = EyeAng - Angle(1, 0, 0)
         local newIronsightPos = LerpVector(FrameTime() * 2.7, self.LastPos or Vector(0, 0, 0), endVector )
         pos = pos + newIronsightPos
         self.LastPos = newIronsightPos
      end
      
      local newAng = LerpAngle(FrameTime()*5.8, (self.CurrentEyeAng or EyeAng), EyeAng)
      self.CurrentEyeAng = newAng

      return pos, self.CurrentEyeAng
   end

   local diagonal = Material("weapons/crosshair1.png")
   local w, h = ScrW(), ScrH()
   local color_white = Color( 255, 255, 255 )
   local color_red = Color( 255, 30, 30 )
   function SWEP:DrawHUD()
      local ply = LocalPlayer()
      local vm = ply:GetViewModel()
      local aim = vm:GetAngles():Forward()
      local tr = util.TraceLine( util.GetPlayerTrace( ply, aim ) )

      if tr.HitPos then
         local trOnScreen = tr.HitPos:ToScreen()
         local color = color_white

         if tr.Entity then
            if string.find(tr.Entity:GetClass(), "falcon_h") then
               color = color_red
            end
         end
         surface.SetDrawColor( color )

         surface.SetMaterial(diagonal)
         surface.DrawTexturedRect( trOnScreen.x - (w * 0.01), trOnScreen.y, w * 0.02, w * 0.02 )
      end

      if ply:KeyDown(IN_DUCK) then
         local w = ScrW()
         local rang = vm:GetAngles()
         render.RenderView( {
            origin = util.TraceLine({
               start = ply:EyePos(),
               endpos = ply:EyePos() + rang:Forward()*4000,
               filter = function( ent )
                  return ent:IsWorld()
               end
            }).HitPos - rang:Forward()*25,
            angles = rang,
            x = 0, y = 0,
            w = w * 0.1, h = w * 0.1,
            fov = 80
         } )

         
      end
   end
end
