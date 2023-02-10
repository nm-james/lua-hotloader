
SWEP.Base                  = "falcon_weapon_base"

SWEP.PrintName          = "E-5C"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.Category           = "Falcon's SWEPs"
SWEP.Spawnable = true

SWEP.Primary = {}
SWEP.Primary.Damage = {}
SWEP.Primary.Damage.min = 2
SWEP.Primary.Damage.max = 9

SWEP.ViewModel = "models/jajoff/sps/cgiweapons/tc13j/e5c.mdl"
SWEP.Primary.Tracer = "lfs_laser_red"
SWEP.Primary.Recoil = 0.6
SWEP.Primary.NumberofShots = 1 
SWEP.Primary.Spread = 0.85
SWEP.Primary.ClipSize = 50 
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.09
SWEP.Primary.Force = 1
SWEP.Primary.Ammo = "AR2"


-- audio stuff
SWEP.Sounds = {}
SWEP.Sounds.Init = "weapons/"
SWEP.Sounds.FirePath = 'weapons/e5c/'
SWEP.Sounds.Fire = 7
SWEP.Sounds.Deploy = "weapons/"
SWEP.Sounds.Reserve = "weapons/"

-- positioniing stuff
SWEP.StandardSightPos = function( ang )
   return (ang:Forward()*0) - (ang:Up()*14 ) + (ang:Right() * 4.675)
end
SWEP.IronSightsPos  = function( ang )
   return -ang:Forward() * 15 + ang:Up() * 7.25 - ang:Right()*6
end

SWEP.WorldOffsetPos = Vector(-6.3, -2.25, -1.2)
SWEP.WorldOffsetAng = Angle(174, 181, -3)


-- DO NOT TOUCH
SWEP.WorldModel = SWEP.ViewModel
