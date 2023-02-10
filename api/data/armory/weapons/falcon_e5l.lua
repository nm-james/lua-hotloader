
SWEP.Base                  = "falcon_weapon_base"

SWEP.PrintName          = "E-5L"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.Category           = "Falcon's SWEPs"
SWEP.Spawnable = true

SWEP.Primary = {}
SWEP.Primary.Damage = {}
SWEP.Primary.Damage.min = 3
SWEP.Primary.Damage.max = 7

SWEP.ViewModel = "models/jajoff/sps/cgiweapons/tc13j/e5rlr.mdl"
SWEP.Primary.Tracer = "lfs_laser_red"
SWEP.Primary.Recoil = 0.65
SWEP.Primary.NumberofShots = 1 
SWEP.Primary.Spread = 0.7
SWEP.Primary.ClipSize = 40 
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.12
SWEP.Primary.Force = 1
SWEP.Primary.Ammo = "AR2"


-- audio stuff
SWEP.Sounds = {}
SWEP.Sounds.Init = "weapons/"
SWEP.Sounds.FirePath = 'weapons/e5l/'
SWEP.Sounds.Fire = 8
SWEP.Sounds.Deploy = "weapons/"
SWEP.Sounds.Reserve = "weapons/"

-- positioniing stuff
SWEP.StandardSightPos = function( ang )
   return (ang:Forward()*0) - (ang:Up()*14 ) + (ang:Right() * 4.675)
end
SWEP.IronSightsPos  = function( ang )
   return -ang:Forward() * 15 + ang:Up() * 7.25 - ang:Right()*6
end

SWEP.WorldOffsetPos = Vector(-6, -2.25, -0.6)
SWEP.WorldOffsetAng = Angle(174, 181, -3)


-- DO NOT TOUCH
SWEP.WorldModel = SWEP.ViewModel
