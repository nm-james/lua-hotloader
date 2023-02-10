
SWEP.Base                  = "falcon_weapon_base"

SWEP.PrintName          = "E-9DR"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.Category           = "Falcon's SWEPs"
SWEP.Spawnable = true

SWEP.Primary = {}
SWEP.Primary.Damage = {}
SWEP.Primary.Damage.min = 3
SWEP.Primary.Damage.max = 10

SWEP.ViewModel = "models/jajoff/sps/cgiweapons/tc13j/e9dr.mdl"
SWEP.Primary.Tracer = "lfs_laser_red"
SWEP.Primary.Recoil = 0.6
SWEP.Primary.NumberofShots = 1 
SWEP.Primary.Spread = 0.5
SWEP.Primary.ClipSize = 25 
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.25
SWEP.Primary.Force = 1
SWEP.Primary.Ammo = "AR2"


-- audio stuff
SWEP.Sounds = {}
SWEP.Sounds.Init = "weapons/"
SWEP.Sounds.FirePath = 'weapons/e9dr/'
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

SWEP.WorldOffsetPos = Vector(-6, -2.25, -0.6)
SWEP.WorldOffsetAng = Angle(174, 181, -3)


-- DO NOT TOUCH
SWEP.WorldModel = SWEP.ViewModel
